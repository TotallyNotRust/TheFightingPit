use crate::guards::validated_user::ValidatedUser;
use crate::schema::user::dsl::user;
use crate::schema::user::{email, id};
use crate::utils::hashing::bcrypt_hash;
use crate::utils::jwt::create_jwt;
use crate::{establish_connection, models::*};
use bcrypt::verify;
use diesel::dsl::insert_into;
use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
use regex::Regex;
use rocket::http::Status;
use rocket::serde::json::Json;
use serde::Deserialize;

#[derive(Deserialize, Debug)]
pub struct Login {
    email: String,
    password: String,
}

#[post("/new", format = "application/json", data = "<new_user_json>")]
pub fn new(new_user_json: Json<NewUser>) -> Result<String, Status> {
    let mut new_user = new_user_json.0;

    if new_user.username.len() <= 0 {
        return Err(Status::BadRequest);
    }

    if new_user.email.len() <= 0
        || !Regex::new(r"^[\w\-\.]+@([\w-]+\.)+[\w\-]{2,4}$")
            .unwrap()
            .is_match(&new_user.email)
    {
        println!("Invalid email: {:?}", new_user.email);
        return Err(Status::BadRequest);
    }

    new_user.password = match bcrypt_hash(&new_user.password) {
        Some(n) => n,
        None => return Err(Status::InternalServerError),
    };

    insert_into(user)
        .values(new_user.clone())
        .execute(&mut establish_connection())
        .expect("Unable to save new user");
    // Diesel doesnt have a good way to get the id from an insert, so we must fetch the user id ourselves.
    let users_with_email = user
        .select(id)
        .filter(email.eq(new_user.email))
        .first::<u64>(&mut establish_connection())
        .expect("Could not find user");
    let new_id = users_with_email.to_owned();

    Ok(create_jwt(new_id).expect("Could not generate JWT token"))
}

#[post("/login", format = "application/json", data = "<login>")]
pub fn login(login: Json<Login>) -> Result<String, Status> {
    let submitted_email = login.0.email;

    let acc_user: User = match user
        .filter(email.eq(submitted_email.to_owned()))
        .load::<User>(&mut establish_connection())
    {
        Ok(n) => {
            if n.len() == 0 {
                return Err(Status::Unauthorized);
            }
            n[0].clone()
        }
        _ => return Err(Status::Unauthorized),
    };

    match verify(login.0.password, &acc_user.password) {
        Ok(true) => {
            return match create_jwt(acc_user.id) {
                Ok(n) => Ok(n),
                _ => Err(Status::InternalServerError),
            }
        }
        _ => return Err(Status::Unauthorized),
    }
}

#[get("/user")]
pub fn get_user(validated_user: ValidatedUser) -> Result<Json<UserWithEmail>, Status> {
    match user
        .filter(id.eq(validated_user.user.id))
        .first::<UserWithEmail>(&mut establish_connection())
    {
        Ok(u) => return Ok(Json(u)),
        Err(_) => return Err(Status::Unauthorized),
    }
}
