use chrono::Utc;
use jsonwebtoken::{decode, encode, Algorithm, DecodingKey, EncodingKey, Header, Validation}; // 👈 New!
use jsonwebtoken::errors::{Error, ErrorKind};
use std::env;
use dotenvy::dotenv;

use crate::models::Claims;

// Followed this tutorial to make these:
// https://medium.com/@jeynesbrook/jwt-authentication-for-api-routes-using-rocket-rs-and-rust-fe7529792a70

pub fn create_jwt(id: u64) -> Result<String, Error> {
    // Private key used to generate token.
    let secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set.");

    let expiration = Utc::now().checked_add_signed(chrono::Duration::hours(12)).expect("Invalid timestamp").timestamp();
    
    let claims = Claims {
        subject_id: id,
        exp: expiration as usize
    }; 

    let header = Header::new(Algorithm::HS512);

    encode(&header, &claims, &EncodingKey::from_secret(secret.as_bytes()))
}


pub fn decode_jwt(token: String) -> Result<Claims, ErrorKind> {
    let secret = env::var("JWT_SECRET").expect("JWT_SECRET must be set.");
    let token = token.trim_start_matches("Bearer").trim();

    match decode::<Claims>(
        &token,
        &DecodingKey::from_secret(secret.as_bytes()),
        &Validation::new(Algorithm::HS512),
    ) {
        Ok(token) => Ok(token.claims),
        Err(err) => Err(err.kind().to_owned())
    }
}