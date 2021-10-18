CREATE EXTENSION postgis;

CREATE TABLE buildings(
	id INT PRIMARY KEY,
	name varchar(30),
	geometry GEOMETRY
);

CREATE TABLE roads(
	id INT PRIMARY KEY,
	name varchar(30),
	geometry GEOMETRY
);

CREATE TABLE poi(
	id INT PRIMARY KEY,
	name varchar(30),
	geometry GEOMETRY
);

INSERT INTO poi(id,name,geometry) VALUES
	(1,'G',ST_GeomFromText('POINT(1 3.5)', -1)),
	(2,'H',ST_GeomFromText('POINT(5.5 1.5)', -1)),
	(3,'I',ST_GeomFromText('POINT(9.5 6)', -1)),
	(4,'J',ST_GeomFromText('POINT(6.5 6)', -1)),
	(5,'K',ST_GeomFromText('POINT(6 9.5)', -1));

INSERT INTO roads(id,name,geometry) VALUES
	(1,'RoadX',ST_GeomFromText('LINESTRING(0 4.5,12 4.5)', -1)),
	(2,'RoadY',ST_GeomFromText('LINESTRING(7.5 10.5,7.5 0)', -1));

INSERT INTO buildings(id,name,geometry) VALUES
	(1,'BuildingA',ST_GeomFromText('POLYGON((8 4,10.5 4,10.5 1.5,8 1.5, 8 4))', -1)),
	(2,'BuildingB',ST_GeomFromText('POLYGON((4 7,6 7,6 5,4 5,4 7))', -1)),
	(3,'BuildingC',ST_GeomFromText('POLYGON((3 8,5 8,5 6,3 6,3 8))', -1)),
	(4,'BuildingD',ST_GeomFromText('POLYGON((9 9,10 9,10 8,9 8,9 9))', -1)),
	(5,'BuildingE',ST_GeomFromText('POLYGON((1 2,2 2,2 1,1 1,1 2))', -1));

--a
SELECT SUM(ST_Length(geometry)) AS calkowita_dlugosc FROM roads;
--b
SELECT ST_AsText(geometry) AS WKT,ST_Area(geometry),ST_Perimeter(geometry) FROM buildings
	WHERE name LIKE 'BuildingA';
--c
SELECT name,ST_Area(geometry) FROM buildings
	ORDER BY name;
--d
SELECT name,ST_Perimeter(geometry) FROM buildings
	ORDER BY ST_Area(geometry) DESC LIMIT 2;
--e
SELECT ST_Distance(buildings.geometry, poi.geometry) AS distance
	FROM buildings, poi
	WHERE buildings.name = 'BuildingC' AND poi.name = 'G';
--f
SELECT ST_Area(ST_Difference((SELECT geometry 
							  FROM buildings 
							  WHERE name = 'BuildingC'),ST_Buffer((SELECT geometry 
																   FROM buildings 
																   WHERE name = 'BuildingB'), 0.5)));
--g
SELECT buildings.name 
	FROM buildings, roads
	WHERE ST_Y(ST_Centroid(buildings.geometry)) > ST_Y(ST_Centroid(roads.geometry)) AND roads.name = 'RoadX';
--h
SELECT ST_Area(ST_SymDifference(geometry,ST_Polygon('LINESTRING(4 7, 6 7, 6 8, 4 8, 4 7)',-1)))
	FROM buildings
	WHERE name LIKE 'BuildingC';


SELECT * FROM buildings;
