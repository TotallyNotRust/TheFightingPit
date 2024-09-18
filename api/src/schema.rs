// @generated automatically by Diesel CLI.

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

diesel::joinable!(participant -> tournament (tournament_id));
diesel::joinable!(participant -> user (user_id));
diesel::joinable!(referee -> tournament (tournament_id));
diesel::joinable!(referee -> user (user_id));
diesel::joinable!(tournament -> user (owner_id));

diesel::allow_tables_to_appear_in_same_query!(
    participant,
    referee,
    tournament,
    user,
);
