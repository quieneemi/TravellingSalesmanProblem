CREATE TABLE IF NOT EXISTS nodes
(
    point1 varchar NOT NULL,
    point2 varchar NOT NULL,
    cost   integer NOT NULL
);

COPY nodes FROM 'data.csv' DELIMITER ',' CSV HEADER;

WITH RECURSIVE
    TSP("from", "to", route, "cost", i) AS
        ((SELECT point1, point2, format('%s,%s', nodes.point1, nodes.point2), cost, 0
          FROM nodes
          WHERE point1 = 'a')
         UNION
         (SELECT TSP.to,
                 nodes.point2,
                 format('%s,%s', TSP.route, nodes.point2),
                 TSP.cost + nodes.cost,
                 i + 1
          FROM TSP
                   INNER JOIN nodes on TSP.to = nodes.point1
          WHERE POSITION(nodes.point2 IN TSP.route) = 0
             OR (i =
                 (SELECT count(*) FROM (SELECT DISTINCT point1 FROM nodes) AS points) -
                 2 AND nodes.point2 = 'a'))),
    all_routes as (SELECT cost                AS total_cost,
                          '{' || route || '}' AS tour
                   FROM TSP
                   WHERE i = (SELECT count(*) FROM (SELECT DISTINCT point1 FROM nodes) AS t1) - 1)

SELECT *
FROM all_routes
WHERE (SELECT max(total_cost) FROM all_routes) = total_cost
   OR (SELECT min(total_cost) FROM all_routes) = total_cost
ORDER BY total_cost, tour;
