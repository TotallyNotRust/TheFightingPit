-- Your SQL goes here
CREATE TABLE bracket_match (
    id bigint unsigned not null auto_increment,
    tournament_id bigint unsigned not null,
    player1_id bigint unsigned,
    player2_id bigint unsigned,
    ref_id bigint unsigned, -- Id of referee
    next_match_id bigint unsigned,
    winner_id bigint unsigned,

    score_1 int unsigned not null default 0, -- Score for player 1
    score_2 int unsigned not null default 0, -- Score for player 2

    round int unsigned not null default 0, -- Can be used to indicate which round this will be.
    starting_round bool not null default 0, -- Used to mark if a user can be placed into this round; marks first round of tourney.
    final_round bool not null default 0, -- Used to mark the final
    semi_final_round bool not null default 0, -- Used to mark the semi final.

    PRIMARY KEY (id),
    FOREIGN KEY (tournament_id) REFERENCES tournament(id),
    FOREIGN KEY (player1_id) REFERENCES participant(id),
    FOREIGN KEY (player2_id) REFERENCES participant(id),
    FOREIGN KEY (winner_id) REFERENCES participant(id),
    FOREIGN KEY (ref_id) REFERENCES user(id),
    FOREIGN KEY (next_match_id) REFERENCES bracket_match(id)
)