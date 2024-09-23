#[macro_use] extern crate rocket;
use std::env;
use crate::guards::validated_user::ValidatedUser;
use rocket::http::Method;


use diesel::{define_sql_function, dsl::select, Connection, MysqlConnection, RunQueryDsl};
use dotenvy::dotenv;
use rocket_cors::{AllowedOrigins, CorsOptions};

mod schema;
mod models;
mod routes;
mod utils;
mod guards;

define_sql_function!(fn last_insert_id() -> Unsigned<BigInt>;);

fn get_last_insert_id(conn: &mut MysqlConnection) -> u64 {
    select(last_insert_id()).first::<u64>(conn).expect("Could not get last insert id")
}

fn establish_connection() -> MysqlConnection {
    let database_url = env::var("DATABASE_URL").expect("DATABASE_URL must be set");
    return MysqlConnection::establish(&database_url).expect("Could not connect to database");
}

#[get("/")]
fn index() -> &'static str {
    "Welcome to The Fighting Pit"
}

// Here is an example of an endpoint that requires an authorized user.
// The user most supply a JWT token via the JWT_TOKEN header,
// this JWT token is the automatically validated by the ValidatedUser guard.
// These guards automatically apply if the endpoint has a parameter of ValidatedUser, which is not in the path.
#[get("/hidden")]
fn hidden(vuser: ValidatedUser) -> &'static str {
    "Logged IN!"
}

#[launch]
fn rocket() -> _ {
    dotenv().ok();

    let cors = CorsOptions::default()
    .allowed_origins(AllowedOrigins::all())
    .allowed_methods(
        vec![Method::Get, Method::Post, Method::Patch, Method::Delete]
            .into_iter()
            .map(From::from)
            .collect(),
    )
    .allow_credentials(true);

    rocket::build()
    .attach(cors.to_cors().unwrap())
    .mount("/", routes![index, hidden])
    .mount("/account", routes![
        routes::account::new,
        routes::account::login,
        routes::account::get_user,
        ])
    .mount("/tournament", routes![
        routes::tournament::new,
        routes::tournament::get,
        routes::tournament::get_brackets,
        routes::tournament::get_players,
        routes::tournament::list,
        routes::tournament::get_referees,
        routes::tournament::add_referee,
        routes::tournament::del_referee,
        routes::tournament::add_participant,
        routes::tournament::permissions,
        routes::tournament::update_score,
    ])
}