use bracket_match::next_match_id;
use chrono::{DateTime, Local, NaiveDateTime, TimeZone};
use diesel::{prelude::{AsChangeset, Insertable}, Associations, Identifiable, Queryable, Selectable};
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
    #[serde(skip_serializing)] 
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

#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize, AsChangeset
)]
#[diesel(table_name = bracket_match)]
pub struct BracketMatch {
    pub id: u64,
    pub tournament_id: u64,
    pub player1_id: Option<u64>,
    pub player2_id: Option<u64>,
    pub ref_id: Option<u64>,
    pub next_match_id: Option<u64>, 
    pub winner_id: Option<u64>,

    pub score_1: u32,
    pub score_2: u32,

    pub round: u32,
    pub starting_round: bool,
    pub final_round: bool,
    pub semi_final_round: bool,
}

#[derive(
    Queryable, Eq, Insertable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = bracket_match)]
pub struct NewBracketMatch {
    pub tournament_id: u64,
    pub player1_id: Option<u64>,
    pub player2_id: Option<u64>,
    pub ref_id: Option<u64>,
    pub next_match_id: Option<u64>, 
    pub winner_id: Option<u64>,

    pub score_1: u32,
    pub score_2: u32,

    pub round: u32,
    pub starting_round: bool,
    pub final_round: bool,
    pub semi_final_round: bool,
}

impl NewBracketMatch {
    pub fn empty_for(tournament_id: u64, next_match: Option<u64>, starting_round: bool) -> Self {
        NewBracketMatch{
            tournament_id: tournament_id,
            player1_id: None,
            player2_id: None,
            ref_id: None, 
            next_match_id: next_match,
            winner_id: None,
            score_1: 0,
            score_2: 0,
            round: 0,
            starting_round: starting_round,
            final_round: false,
            semi_final_round: false,
        }
    }
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