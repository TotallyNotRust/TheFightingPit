use chrono::{Local, NaiveDateTime};
use diesel::{prelude::Insertable, Associations, Identifiable, Queryable, Selectable};
use serde::{Deserialize, Serialize};

use crate::schema::*;

#[derive(
    Queryable, Eq, Insertable, Identifiable, Debug, PartialEq, Clone, Deserialize, Serialize,
)]
#[diesel(table_name = user)]
pub struct User {
    pub id: u64,
    pub email: String,
    pub username: String,
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