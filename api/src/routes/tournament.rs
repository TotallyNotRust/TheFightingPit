use diesel::{
    dsl::{delete, insert_into}, update, BoolExpressionMethods, ExpressionMethods, OptionalExtension, QueryDsl, RunQueryDsl
};
use rocket::{http::Status, serde::json::Json};
use serde::{Deserialize, Serialize};

use crate::{
    establish_connection, get_last_insert_id,
    guards::validated_user::ValidatedUser,
    models::{
        BracketMatch, NewParticipant, NewReferee, NewTournament, NewTournamentWithOwner,
        Participant, Referee, Tournament, User,
    },
    schema::{
        bracket_match::{
            dsl::{bracket_match, id as b_id, starting_round, tournament_id as bt_id},
            player1_id, player2_id, score_1, score_2, winner_id,
        },
        participant::dsl::{participant, tournament_id as pt_id, user_id as pu_id},
        referee::dsl::{id as r_id, referee, tournament_id as rt_id, user_id as ru_id},
        tournament::{
            dsl::{id as t_id, tournament},
            owner_id,
        },
        user::{dsl::user, email, id as u_id},
    },
    utils::bracket_generator::generate_brackets,
};

#[post("/new", format = "application/json", data = "<new_tournament_json>")]
pub fn new(
    new_tournament_json: Json<NewTournament>,
    validated_user: ValidatedUser,
) -> Result<Json<Tournament>, Status> {
    let new_tournament =
        NewTournamentWithOwner::fromNewTournament(new_tournament_json.0, validated_user.user.id);
    let conn = &mut establish_connection();
    insert_into(tournament)
        .values(new_tournament.clone())
        .execute(conn)
        .expect("Unable to save tournament");
    let saved_tournament_id = get_last_insert_id(conn);
    let saved_tournament = tournament
        .filter(t_id.eq(saved_tournament_id))
        .first::<Tournament>(conn)
        .expect("Could not load inserted tournament");

    // Now generate brackets
    generate_brackets(&saved_tournament);

    Ok(Json(saved_tournament))
}

#[get("/<tournament_id>")]
pub fn get(tournament_id: u64) -> Result<Json<(Tournament, Option<User>)>, Status> {
    return match tournament
        .left_join(user)
        .filter(t_id.eq(tournament_id))
        .first::<(Tournament, Option<User>)>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}

#[get("/<id>/brackets")]
pub fn get_brackets(id: u64) -> Result<Json<Vec<BracketMatch>>, Status> {
    return match bracket_match
        .filter(bt_id.eq(id))
        .load::<BracketMatch>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}
#[get("/<id>/bracket/<bracket_id>")]
pub fn get_bracket(id: u64, bracket_id: u64) -> Result<Json<BracketMatch>, Status> {
    return match bracket_match
        .filter(bt_id.eq(id).and(b_id.eq(bracket_id)))
        .first::<BracketMatch>(&mut establish_connection())
    {
        Ok(n) => Ok(Json(n)),
        Err(_) => Err(Status::NotFound),
    };
}

#[get("/<id>/players")]
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
pub fn list(
    validated_user: ValidatedUser,
) -> Result<Json<Vec<(Tournament, Option<User>)>>, Status> {
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

#[post("/<tournament_id>/referee", format = "application/json", data = "<email_list>")]
pub fn add_referee(
    tournament_id: u64,
    email_list: Json<Vec<String>>,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    if !can_edit_tournament(tournament_id, validated_user.user.id) {
        return Err(Status::Unauthorized);
    }

    let conn = &mut establish_connection();

    let mut referees: Vec<NewReferee> = vec![];

    // Create list of new referess, and fail if one is not found
    'emails: for u_email in email_list.0 {
        let Ok(user_id) = user.filter(email.eq(u_email)).select(u_id).first::<u64>(conn) else {
            return Err(Status::BadRequest);
        };

        println!("Got user {:?}", user_id);

        // Ensure user is not already registered
        match referee.filter(rt_id.eq(tournament_id).and(ru_id.eq(user_id))).first::<Referee>(conn).optional() {
            Ok(None) => {} // The user has not yet been registered.
            _ => {
                println!("User already registered as ref, skipping");
                continue 'emails;
            }
        }

        referees.push(NewReferee {
            user_id,
            tournament_id: tournament_id,
        });
    }

    println!("Adding referees: {:?}", referees);
    
    insert_into(referee)
        .values(referees)
        .execute(conn)
        .expect("Could not add referee");

    Ok("")
}

#[get("/<tournament_id>/referee")]
pub fn get_referees(tournament_id: u64) -> Result<Json<Vec<(Referee, Option<User>)>>, Status> {
    return match referee
        .left_join(user)
        .filter(rt_id.eq(tournament_id))
        .load::<(Referee, Option<User>)>(&mut establish_connection())
    {
        Ok(n) => {
            println!("💥 {:?}", n);
            Ok(Json(n))
        },
        Err(_) => Err(Status::NotFound),
    };
}

#[delete("/<tournament_id>/referee/<referee_id>")]
pub fn del_referee(
    tournament_id: u64,
    referee_id: u64,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    if !can_edit_tournament(tournament_id, validated_user.user.id) {
        return Err(Status::Unauthorized);
    }

    delete(referee.filter(r_id.eq(referee_id))).execute(&mut establish_connection());

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
    match participant
        .filter(pu_id.eq(user_id).and(pt_id.eq(tournament_id)))
        .first::<Participant>(conn)
        .optional()
    {
        Ok(None) => {
            // User is not already signed up.
        }
        Err(n) => {
            println!("{:?}", n);
            return Err(Status::NotAcceptable);
        }
        Ok(Some(n)) => {
            println!(
                "{:?}, {:?}, {:?}",
                n, validated_user.user.id, validated_user.user.username
            );
            return Err(Status::NotAcceptable);
        }
    }

    let player;
    // Find bracket with open slot.
    // Prioritize ones with slot one open.
    let mut bracket: BracketMatch = match bracket_match
        .filter(
            player1_id
                .is_null()
                .and(bt_id.eq(tournament_id).and(starting_round.eq(true))),
        )
        .first::<BracketMatch>(conn)
        .optional()
    {
        Ok(Some(bracket)) => {
            player = 1;
            bracket
        }
        Ok(None) => {
            match bracket_match
                .filter(
                    player2_id
                        .is_null()
                        .and(bt_id.eq(tournament_id).and(starting_round.eq(true))),
                )
                .first::<BracketMatch>(conn)
                .optional()
            {
                Ok(Some(bracket)) => {
                    player = 2;
                    bracket
                }
                Ok(None) => {
                    return Err(Status::Conflict);
                }
                Err(_) => {
                    return Err(Status::InternalServerError);
                }
            }
        }
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

    let _ = update(bracket_match)
        .filter(b_id.eq(bracket.id))
        .set(bracket)
        .execute(conn);

    Ok("")
}

#[derive(Deserialize)]
pub struct Scoreline {
    pub score_1: u32,
    pub score_2: u32,
    pub final_score: bool
}

// TODO: It may be nice to implement some kind of lock to avoid dataraces in the future, but for now it is only intended to have
#[post(
    "/<id>/brackets/<bracket_id>/updatescore",
    format = "application/json",
    data = "<scoreline>"
)]
pub fn update_score(
    id: u64,
    bracket_id: u64,
    scoreline: Json<Scoreline>,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    let conn = &mut establish_connection();
    let user_id = validated_user.user.id;
    // Get the bracket
    let Ok(Some(bracket)) = bracket_match
        .filter(b_id.eq(bracket_id).and(bt_id.eq(id)))
        .first::<BracketMatch>(conn)
        .optional()
    else {
        return Err(Status::NotFound);
    };

    // // Ensure user is referee for tournament
    let Ok(Some(_referee)) = referee
        .filter(ru_id.eq(user_id).and(rt_id.eq(id)))
        .first::<Referee>(conn)
        .optional()
    else {
        return Err(Status::Unauthorized);
    };

    // Update the brackets
    let _ = update(bracket_match)
        .filter(b_id.eq(bracket_id))
        .set((
            score_1.eq(scoreline.0.score_1),
            score_2.eq(scoreline.0.score_2),
        ))
        .execute(conn);

    if scoreline.final_score && bracket.next_match_id != None {
        let winner: Option<u64>;
        // Determine the winner
        if bracket.player1_id == None && bracket.player2_id == None {
            return Ok(""); // If no players, then do not move forward
        }

        if bracket.player1_id != None && bracket.player2_id != None {
            if scoreline.0.score_1 > scoreline.0.score_2 {
                winner = bracket.player1_id;
            } else {
                winner = bracket.player2_id;
            }
        } else if bracket.player1_id != None {
            winner = bracket.player1_id;
        } else if bracket.player2_id != None {
            winner = bracket.player2_id;
        } else {
            winner = None;  
        }


        let mut next_match: BracketMatch = 
            bracket_match.filter(b_id.eq(bracket.next_match_id.expect("Next match id is both None and Some"))).first::<BracketMatch>(conn).expect("Couldn't load next match");


        if next_match.player1_id == None {
            next_match.player1_id = winner;
        } else if next_match.player2_id == None {
            next_match.player2_id = winner;
        } else {
            println!("Warning, could not move player forward");
        }

        let _ = update(bracket_match)
        .filter(b_id.eq(bracket.next_match_id.expect("Next match id is both None and Some")))
        .set(next_match)
        .execute(conn); 
    }

    Ok("")
}

#[derive(Serialize)]
pub struct TournamentPermissions {
    pub is_referee: bool,
}

#[get("/<id>/permissions")]
pub fn permissions(id: u64, validated_user: ValidatedUser) -> Result<Json<TournamentPermissions>, Status> {
    let is_referee = match referee.filter(ru_id.eq(validated_user.user.id).and(rt_id.eq(id))).first::<Referee>(&mut establish_connection()).optional() {
        Ok(Some(_)) => true,
        _ => false,
    };

    return Ok(Json(TournamentPermissions {
        is_referee
    }));
}