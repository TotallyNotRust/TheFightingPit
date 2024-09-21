use diesel::{dsl::insert_into, update, BoolExpressionMethods, ExpressionMethods, OptionalExtension, QueryDsl, RunQueryDsl};
use rocket::{http::Status, serde::json::Json};

use crate::{
    establish_connection, get_last_insert_id, guards::validated_user::ValidatedUser, models::{BracketMatch, NewParticipant, NewReferee, NewTournament, NewTournamentWithOwner, Participant, Tournament, TournamentWithOwnerUser, User}, schema::{
        bracket_match::{dsl::{bracket_match, id as b_id, starting_round, tournament_id as bt_id}, player1_id, player2_id}, participant::dsl::{id as p_id, participant, tournament_id as pt_id}, referee::dsl::referee, tournament::{
            dsl::{id as t_id, tournament},
            name, owner_id,
        }, user::dsl::user
    }, utils::bracket_generator::generate_brackets
};

#[post("/new", format = "application/json", data = "<new_tournament_json>")]
pub fn new(
    new_tournament_json: Json<NewTournament>,
    validated_user: ValidatedUser,
) -> Result<Json<Tournament>, Status> {
    let new_tournament = NewTournamentWithOwner::fromNewTournament(
        new_tournament_json.0,
        validated_user.user.id,
    );
    let conn = &mut establish_connection();
    insert_into(tournament)
        .values(new_tournament.clone())
        .execute(conn)
        .expect("Unable to save tournament");
    let saved_tournament_id = get_last_insert_id(conn);
    let saved_tournament = tournament.filter(t_id.eq(saved_tournament_id)).first::<Tournament>(conn).expect("Could not load inserted tournament");

    // Now generate brackets
    generate_brackets(&saved_tournament);

    Ok(Json(saved_tournament))
}

#[get("/get/<id>")]
pub fn get(id: u64) -> Result<Json<(Tournament, Option<User>)>, Status> {
    return match tournament
        .left_join(user)
        .filter(t_id.eq(id))
        .first::<(Tournament, Option<User>)>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}

#[get("/get/<id>/brackets")]
pub fn get_brackets(id: u64) -> Result<Json<Vec<BracketMatch>>, Status> {
    return match bracket_match
        .filter(bt_id.eq(id))
        .load::<BracketMatch>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}


#[get("/get/<id>/players")]
pub fn get_players(id: u64) -> Result<Json<Vec<(Participant, Option<User>)>>, Status> {
    return match participant
        .left_join(user)
        .filter(pt_id.eq(id))
        .load::<(Participant, Option<User>)>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}


#[get("/list")]
pub fn list(validated_user: ValidatedUser) -> Result<Json<Vec<(Tournament, Option<User>)>>, Status> {
    return match tournament
        .left_join(user)
        .filter(owner_id.eq(validated_user.user.id))
        .load::<(Tournament, Option<User>)>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}

//
pub fn can_edit_tournament(tournament_id: u64, user_id: u64) -> bool {
    let _tournament: Tournament = tournament
        .filter(t_id.eq(tournament_id))
        .first::<Tournament>(&mut establish_connection())
        .expect("Could not find tournament");

    if _tournament.owner_id == user_id {
        return true;
    }
    // For now only owner can edit
    return false;
}

#[post("/<tournament_id>/referee/<user_id>")]
pub fn add_referee(
    tournament_id: u64,
    user_id: u64,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    if !can_edit_tournament(tournament_id, validated_user.user.id) {
        return Err(Status::Unauthorized);
    }

    let new_referee = NewReferee {
        user_id,
        tournament_id: tournament_id,
    };
    insert_into(referee)
        .values(new_referee)
        .execute(&mut establish_connection())
        .expect("Could not add referee");

    Ok("")
}

#[post("/<tournament_id>/signup")]
pub fn add_participant(
    tournament_id: u64,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    let conn = &mut establish_connection();
    let user_id = validated_user.user.id;
    // Check if user is signed up already
    match participant.filter(p_id.eq(user_id).and(pt_id.eq(tournament_id))).first::<Participant>(conn).optional() {
        Ok(None) => {
            // User is not already signed up.
        },
        Err(_) | Ok(Some(_)) => {
            return Err(Status::NotAcceptable); 
        }
    }

    let player;
    // Find bracket with open slot.
    // Prioritize ones with slot one open.
    let mut bracket: BracketMatch = match bracket_match.filter(player1_id.is_null().and(bt_id.eq(tournament_id).and(starting_round.eq(true)))).first::<BracketMatch>(conn).optional() {
        Ok(Some( bracket)) => {
            player = 1;
            bracket
        },
        Ok(None) => {
            match bracket_match.filter(player2_id.is_null().and(bt_id.eq(tournament_id).and(starting_round.eq(true)))).first::<BracketMatch>(conn).optional() {
                Ok(Some(bracket)) => {
                    player = 2;
                    bracket
                },
                Ok(None) => {
                    return Err(Status::Conflict);
                },
                Err(_) => {
                    return Err(Status::InternalServerError);
                }
            }
        },
        Err(_) => {
            return Err(Status::InternalServerError);
        }
    };
    

    let new_participant = NewParticipant {
        user_id: user_id,
        tournament_id: tournament_id,
    };
    insert_into(participant)
        .values(new_participant)
        .execute(conn)
        .expect("Could not add participant");

    let saved_participant_id = get_last_insert_id(conn);

    match player {
        1 => bracket.player1_id = Some(saved_participant_id),
        2 => bracket.player2_id = Some(saved_participant_id),
        _ => return Err(Status::InternalServerError),
    }

    let _ = update(bracket_match).filter(b_id.eq(bracket.id)).set(bracket).execute(conn);

    Ok("")
}