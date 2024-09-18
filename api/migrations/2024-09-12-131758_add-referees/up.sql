-- Your SQL goes here
CREATE TABLE referee (
    id bigint unsigned not null auto_increment,
    tournament_id bigint unsigned not null,
    user_id bigint unsigned not null,
    PRIMARY KEY (id),
    FOREIGN KEY (tournament_id) REFERENCES tournament(id),
    FOREIGN KEY (user_id) REFERENCES user(id)
)