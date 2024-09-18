use diesel::{dsl::insert_into, BoolExpressionMethods, ExpressionMethods, QueryDsl, RunQueryDsl};
use rocket::{http::Status, serde::json::Json};

use crate::{
    establish_connection,
    guards::validated_user::ValidatedUser,
    models::{NewParticipant, NewReferee, NewTournament, NewTournamentWithOwner, Tournament, TournamentWithOwnerUser, User},
    schema::{
        participant::dsl::participant,
        referee::dsl::referee,
        tournament::{
            dsl::{id as t_id, tournament},
            name, owner_id,
        }, user::dsl::user,
    },
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
    insert_into(tournament)
        .values(new_tournament.clone())
        .execute(&mut establish_connection())
        .expect("Unable to save tournament");
    let saved_tournament = tournament
        .filter(
            name.eq(new_tournament.name)
                .and(owner_id.eq(validated_user.user.id)),
        )
        .first::<Tournament>(&mut establish_connection())
        .expect("Could not find tournament");
    Ok(Json(saved_tournament))
}

#[get("/get/<id>")]
pub fn get(id: u64) -> Result<Json<Tournament>, Status> {
    return match tournament
        .filter(t_id.eq(id))
        .first::<Tournament>(&mut establish_connection())
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

#[post("/<tournament_id>/participant/<user_id>")]
pub fn add_participant(
    tournament_id: u64,
    user_id: u64,
    validated_user: ValidatedUser,
) -> Result<&'static str, Status> {
    if !can_edit_tournament(tournament_id, validated_user.user.id) {
        return Err(Status::Unauthorized);
    }

    let new_participant = NewParticipant {
        user_id,
        tournament_id: tournament_id,
    };
    insert_into(participant)
        .values(new_participant)
        .execute(&mut establish_connection())
        .expect("Could not add participant");

    Ok("")
}