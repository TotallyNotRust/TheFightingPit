// @generated automatically by Diesel CLI.

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
