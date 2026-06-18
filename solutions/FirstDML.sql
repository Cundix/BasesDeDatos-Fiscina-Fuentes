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



#13
UPDATE 
#16