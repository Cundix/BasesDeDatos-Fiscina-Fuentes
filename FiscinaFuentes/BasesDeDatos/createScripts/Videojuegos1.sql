create database if not exists FirstQuintoExercise;
use FirstQuintoExercise;



CREATE TABLE IF NOT EXISTS Players (
	id INT PRIMARY KEY,
	nombre VARCHAR(20),
	date_of_birth DATE,
	email VARCHAR(20) UNIQUE,
	pais VARCHAR(20)
);

CREATE TABLE IF NOT EXISTS Teams (
	id INT PRIMARY KEY,
	nombre VARCHAR(20),
	capitan INT,
	FOREIGN KEY (capitan) REFERENCES Players (id)
);

CREATE TABLE IF NOT EXISTS Player_belongs_to_team(
	id INT,
	player_id INT,
	team_id INT, 
	PRIMARY KEY (player_id, team_id),
	FOREIGN KEY (player_id) REFERENCES Players (id),
	FOREIGN KEY (team_id) REFERENCES Teams (id)
	
);

CREATE TABLE IF NOT EXISTS Games(
	id INT PRIMARY KEY,
	nombre VARCHAR(20),
	genero VARCHAR(20),
	edad_minima INT
);

CREATE TABLE IF NOT EXISTS Tournament (
	id INT PRIMARY KEY,
	nombre VARCHAR(20),
	premio_en_usd float CHECK (premio_en_usd > 0),
	inicio DATE,
	fin DATE,
	juego_de_competencia INT,
	CONSTRAINT fechas CHECK (fin > inicio),
	FOREIGN KEY (juego_de_competencia) REFERENCES Games (id)
);

CREATE TABLE IF NOT EXISTS tournament_has_teams(
	fecha_inscripcion DATE,
	posicion_final INT,
	id_torneo INT,	
	id_equipo INT,
	PRIMARY KEY (id_torneo, id_equipo),
	FOREIGN KEY (id_torneo) REFERENCES Tournament (id),
	FOREIGN KEY (id_equipo) REFERENCES Teams (id)
);




