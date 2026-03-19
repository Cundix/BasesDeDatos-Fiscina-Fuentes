use FirstQuintoExercise;

SELECT * FROM Players p 
WHERE p.pais = 'Argentina'
ORDER BY p.nombre;

SELECT nombre FROM Games g 
WHERE g.edad_minima >= 16;

SELECT t.nombre as NombreEquipo, p.nombre as NombreCapitan FROM Teams t 
JOIN Players p ON t.capitan = p.id;

SELECT * FROM tournament_has_teams tht ;

SELECT COUNT(*) as CantidadPorPais FROM Players p 
Group by p.pais;

SELECT SUM(t.premio_en_usd) FROM Tournament t
GROUP BY t.juego_de_competencia;

SELECT AVG(g.edad_minima) FROM Games g
GROUP BY g.genero;

SELECT t.nombre as NombreEquipo FROM Teams t
WHERE (
		SELECT COUNT(*) as CANTIDAD FROM tournament_has_teams tht
		GROUP BY tht.id_equipo
		ORDER BY CANTIDAD DESC
		LIMIT 1
		)>= 5;

#11

#13
UPDATE Tournament t
SET t.premio_en_usd = t.premio_en_usd * 2
WHERE t.id in (SELECT tht.id_torneo as TORNEOID
		FROM tournament_has_teams tht
		GROUP BY tht.id_torneo
		HAVING COUNT(tht.id_torneo) <3 );
#14
		
UPDATE Games g
SET g.Nombre = '[Popular]' + g.Nombre
WHERE g.id in (SELECT tht.id_torneo as TORNEOID
		FROM tournament_has_teams tht
		GROUP BY tht.id_torneo
		HAVING COUNT(tht.id_torneo) >2 );
		
#16
DELETE FROM Players p
WHERE p.id not in (SELECT pbt.player_id as IDEQUIPO
		FROM Player_belongs_to_team pbt
		GROUP BY pbt.player_id)	

