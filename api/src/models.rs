use chrono::{DateTime, Local, NaiveDateTime, TimeZone};
use diesel::{prelude::Insertable, Associations, Identifiable, Queryable, Selectable};
use serde::{Deserialize, Serialize};

use crate::schema::*;

// |*********************|
// |     DB RELATED      |
// |*********************|

#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = user)]
pub struct User {
    pub id: u64,
    pub email: String,
    pub username: String,
    #[serde(skip_serializing)] // Avoid sending the password back to the user by never serializing it.
    pub password: String
}

impl User {
    pub fn default() -> User {
        return User {
            id: 0,
            username: "".to_owned(),
            email: "".to_owned(),
            password: "".to_owned()
        };
    }
}

#[derive(
    Eq, Insertable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = user)]
pub struct NewUser {
    pub email: String,
    pub username: String,
    pub password: String
}

#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = tournament)]
pub struct Tournament {
    pub id: u64,
    pub name: String,
    pub slots: u32,
    pub start_datetime: NaiveDateTime,
    pub owner_id: u64,
}

#[derive(
    Queryable, Eq, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = tournament)]
pub struct TournamentWithOwnerUser {
    pub id: u64,
    pub name: String,
    pub slots: u32,
    pub start_datetime: NaiveDateTime,
    pub owner_id: u64,
    pub owner: Option<User>,
}

#[derive(
    Deserialize, Serialize,
)]
pub struct NewTournament {
    pub name: String,
    pub slots: u32,
    pub start_datetime: NaiveDateTime,
}
#[derive(
    Eq, Insertable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = tournament)]
pub struct NewTournamentWithOwner {
    pub name: String,
    pub slots: u32,
    pub start_datetime: NaiveDateTime,
    pub owner_id: u64
}

impl NewTournamentWithOwner {
    pub fn fromNewTournament(new_tournament: NewTournament, owner_id: u64) -> Self {
        return Self {
            name: new_tournament.name,
            slots: new_tournament.slots,
            start_datetime: new_tournament.start_datetime,
            owner_id: owner_id,
        }
    }
}


#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = referee)]
pub struct Referee {
    pub id: u64,
    pub user_id: u64,
    pub tournament_id: u64,
}
#[derive(
    Eq, Insertable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = referee)]
pub struct NewReferee {
    pub user_id: u64,
    pub tournament_id: u64,
}

#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = participant)]
pub struct Participant {
    pub id: u64,
    pub user_id: u64,
    pub tournament_id: u64,
}
#[derive(
    Eq, Insertable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = participant)]
pub struct NewParticipant {
    pub user_id: u64,
    pub tournament_id: u64,
}


// |*********************|
// |   NOT DB RELATED    |
// |*********************|


use rocket::Responder;
#[derive(Responder, Debug)]
pub enum NetworkResponse {
    #[response(status = 201)]
    Created(String),
    #[response(status = 400)]
    BadRequest(String),
    #[response(status = 401)]
    Unauthorized(String),
    #[response(status = 404)]
    NotFound(String),
    #[response(status = 409)]
    Conflict(String),
}

#[derive(Serialize)]
pub enum ResponseBody {
    Message(String),
    AuthToken(String),
}

#[derive(Serialize)]
#[serde(crate = "rocket::serde")]
pub struct Response {
    pub body: ResponseBody,
}

#[derive(Debug, Deserialize, Serialize)]
pub struct Claims {
    pub subject_id: u64,
    pub exp: usize
}