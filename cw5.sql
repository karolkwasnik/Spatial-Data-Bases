--tworze tabele
CREATE TABLE obiekty(
	id INT PRIMARY KEY,
	name varchar(255),
	geometry GEOMETRY
);

--dodaje obiekty
INSERT INTO obiekty(id,name,geometry) VALUES(
	1,'obiekt1',ST_GeomFromText('MULTICURVE(LINESTRING(0 1, 1 1),CIRCULARSTRING(1 1, 2 0, 3 1),
								 CIRCULARSTRING(3 1, 4 2, 5 1),LINESTRING(5 1, 6 1))',-1));

--curvepolygon - pierwszy argument to poligon, drugi to maska wycinajaca
INSERT INTO obiekty(id,name,geometry) VALUES(
	2,'obiekt2',ST_GeomFromText('CURVEPOLYGON(COMPOUNDCURVE(LINESTRING(10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2),
								 CIRCULARSTRING(14 2, 12 0, 10 2),LINESTRING(10 2, 10 6)),CIRCULARSTRING(11 2, 13 2, 11 2))',-1));
							
INSERT INTO obiekty(id,name,geometry) VALUES(
	3,'obiekt3',ST_GeomFromText('POLYGON((10 17, 12 13, 7 15, 10 17))',-1));
	
INSERT INTO obiekty(id,name,geometry) VALUES(
	4,'obiekt4',ST_GeomFromText('MULTILINESTRING((20 20, 25 25),(25 25, 27 24),(27 24, 25 22),(25 22, 26 21),(26 21, 22 19),(22 19, 20.5 19.5))',-1));
	
INSERT INTO obiekty(id,name,geometry) VALUES(
	5,'obiekt5',ST_GeomFromText('MULTIPOINT((30 30 59),(38 32 234))',-1));
	
INSERT INTO obiekty(id,name,geometry) VALUES(
	6,'obiekt6',ST_GeomFromText('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2),POINT(4 2))',-1));

--zapytania
--1
SELECT ST_Area(ST_Buffer(ST_ShortestLine(A.geometry,B.geometry),5))
	FROM obiekty A, obiekty B
		WHERE A.name = 'obiekt3' AND B.name = 'obiekt4';
		
--2
UPDATE obiekty
SET geometry = ST_GeomFromText('POLYGON((20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5, 20 20))',-1)
WHERE name = 'obiekt4';

--3
INSERT INTO obiekty(id,name,geometry) VALUES(
	7,
	'obiekt7',
	(SELECT ST_Union(A.geometry, B.geometry) FROM obiekty A, obiekty B
		WHERE A.name = 'obiekt3' AND B.name = 'obiekt4')
	);
	
--4
SELECT name,ST_Area(ST_Buffer(geometry,5))
FROM obiekty
WHERE NOT ST_HasArc(geometry)
