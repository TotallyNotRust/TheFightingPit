// @generated automatically by Diesel CLI.

diesel::table! {
    bracket_match (id) {
        id -> Unsigned<Bigint>,
        tournament_id -> Unsigned<Bigint>,
        player1_id -> Nullable<Unsigned<Bigint>>,
        player2_id -> Nullable<Unsigned<Bigint>>,
        ref_id -> Nullable<Unsigned<Bigint>>,
        next_match_id -> Nullable<Unsigned<Bigint>>,
        winner_id -> Nullable<Unsigned<Bigint>>,
        score_1 -> Unsigned<Integer>,
        score_2 -> Unsigned<Integer>,
        round -> Unsigned<Integer>,
        starting_round -> Bool,
        final_round -> Bool,
        semi_final_round -> Bool,
    }
}

diesel::table! {
    participant (id) {
        id -> Unsigned<Bigint>,
        tournament_id -> Unsigned<Bigint>,
        user_id -> Unsigned<Bigint>,
    }
}

diesel::table! {
    referee (id) {
        id -> Unsigned<Bigint>,
        tournament_id -> Unsigned<Bigint>,
        user_id -> Unsigned<Bigint>,
    }
}

diesel::table! {
    tournament (id) {
        id -> Unsigned<Bigint>,
        #[max_length = 64]
        name -> Varchar,
        slots -> Unsigned<Integer>,
        start_datetime -> Datetime,
        owner_id -> Unsigned<Bigint>,
    }
}

diesel::table! {
    user (id) {
        id -> Unsigned<Bigint>,
        #[max_length = 255]
        email -> Varchar,
        #[max_length = 64]
        username -> Varchar,
        #[max_length = 72]
        password -> Varchar,
    }
}

diesel::joinable!(bracket_match -> tournament (tournament_id));
diesel::joinable!(bracket_match -> user (ref_id));
diesel::joinable!(participant -> tournament (tournament_id));
diesel::joinable!(participant -> user (user_id));
diesel::joinable!(referee -> tournament (tournament_id));
diesel::joinable!(referee -> user (user_id));
diesel::joinable!(tournament -> user (owner_id));

diesel::allow_tables_to_appear_in_same_query!(
    bracket_match,
    participant,
    referee,
    tournament,
    user,
);
