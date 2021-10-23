--4
SELECT COUNT(p.f_codedesc) 
		FROM popp p, rivers r
			WHERE ST_Contains(ST_buffer(r.geom,1000),p.geom);
			
SELECT p.*
	INTO tableB
		FROM popp p, rivers r
			WHERE ST_Contains(ST_buffer(r.geom,1000),p.geom);

--5
--a
CREATE TABLE airportsNew AS
	SELECT name,geom,elev
		FROM airports
		WHERE name IN 
		(
				--wschod
				SELECT name 
					FROM airports
						WHERE ST_Y(geom) = (SELECT MAX(ST_Y(geom)) 
												FROM airports)
				UNION
				--zachod
				SELECT name
					FROM airports
						WHERE ST_Y(geom) = (SELECT MIN(ST_Y(geom)) 
												FROM airports)
		);		
--b
INSERT INTO airportsNEW(name,geom,elev) VALUES
	(
		'airportB',
		
		(SELECT ST_Centroid(ST_ShortestLine(a.geom,b.geom))
			FROM airportsNew a, airportsNew b
				WHERE a.name = 'NOATAK' and b.name = 'NIKOLSKI AS'),
		
		123
	);

SELECT * FROM airportsNew;

--6
SELECT ST_Area(ST_buffer(ST_ShortestLine(a.geom,b.geom),1000))
	FROM lakes a, airports b
		WHERE a.names = 'Iliamna Lake' AND b.name = 'AMBLER';
				
--7
SELECT tre.vegdesc, SUM(ST_Area(tre.geom))
	FROM trees tre, tundra tun, swamp swa
 		WHERE ST_Within(tre.geom, tun.geom) OR ST_Within(tre.geom, swa.geom)
		GROUP BY tre.vegdesc;




