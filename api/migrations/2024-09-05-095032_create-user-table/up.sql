-- Your SQL goes here
CREATE TABLE user (
	id bigint unsigned not null auto_increment,
    email varchar(255) unicode not null,
    username varchar(64) unique not null,
    password varchar(72) not null,
    PRIMARY KEY (id)
);