-- Your SQL goes here
CREATE TABLE tournament (
	id bigint unsigned not null auto_increment,
    name varchar(64) unique not null,
    slots int unsigned not null,
    start_datetime datetime not null,
    owner_id bigint unsigned not null,
    PRIMARY KEY (id),
    FOREIGN KEY (owner_id) REFERENCES user(id)
)