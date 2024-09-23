use diesel::{dsl::insert_into, Insertable, RunQueryDsl, QueryDsl};

use crate::{establish_connection, get_last_insert_id, models::{NewBracketMatch, Tournament}, schema::{bracket_match::dsl::bracket_match, participant::tournament_id, tournament::dsl::tournament as tournament_table}};

pub fn generate_brackets(tournament: &Tournament) {
    match tournament.slots {
        32 => generate_32_player_tournament(tournament),
        4 => generate_4_player_tournament(tournament),
        n => println!("Cannot generate bracket for {:?} slots", n)
    }
    
}

pub fn generate_32_player_tournament(_tournament: &Tournament) {
    todo!()
}

pub fn generate_4_player_tournament(tournament: &Tournament) {
    let finale = NewBracketMatch::empty_for(tournament.id, None, false);
    let connection = &mut establish_connection();
    insert_into(bracket_match).values(finale).execute(connection).expect("Unable to save bracket final");
    let bracket_id = get_last_insert_id(connection);
    println!("{:?}", bracket_id);
    let match1 = NewBracketMatch::empty_for(tournament.id, Some(bracket_id), true);
    let match2 = NewBracketMatch::empty_for(tournament.id, Some(bracket_id), true);
    insert_into(bracket_match).values(vec![match1, match2]).execute(connection).expect("Unable to save bracket final");
}