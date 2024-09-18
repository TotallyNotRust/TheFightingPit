use diesel::{ExpressionMethods, QueryDsl, RunQueryDsl};
use rocket::{http::Status, outcome::Outcome, request::{self, FromRequest}, Request};

use crate::{establish_connection, models::{NetworkResponse, User}, schema::user::dsl::{id as user_id, user}, utils::jwt::decode_jwt};

pub struct ValidatedUser {
    pub user: User
}

#[rocket::async_trait]
impl<'r> FromRequest<'r> for ValidatedUser {
    type Error = NetworkResponse;

    async fn from_request(req: &'r Request<'_>) -> request::Outcome<Self, Self::Error> {
        let token = match req.headers().get("JWT_TOKEN").next() {
            Some(n) => n,
            None => return Outcome::Error((Status::BadRequest, NetworkResponse::BadRequest("Missing JWT token".to_owned())))
        };
        let id = match decode_jwt(String::from(token)) {
            Ok(claim) => claim.subject_id,
            Err(err) => {
                return Outcome::Error((Status::Unauthorized, NetworkResponse::Unauthorized(format!("{:?}", err))))
            }
        };

        let validated_user = match user
            .filter(user_id.eq(id))
            .load::<User>(&mut establish_connection())
            .unwrap()
            .first() {
                Some(n) => n.clone(),
                None => return Outcome::Error((Status::Unauthorized, NetworkResponse::Unauthorized("Invalid JWT".to_owned())))
        };

        return Outcome::Success(ValidatedUser { user: validated_user });
    }
}