// Query 1: Thriller movies with average rating above 4.0
MATCH (m:Movie)-[:HAS_GENRE]->(g:Genre {name: 'Thriller'})
MATCH (u:User)-[r:RATED]->(m)
WITH m, avg(r.rating) AS avgRating, count(r) AS ratingCount
WHERE avgRating > 4.0
RETURN
    m.title AS movie,
    round(avgRating, 2) AS avgRating,
    ratingCount
ORDER BY avgRating DESC, ratingCount DESC
LIMIT 10;


// Query 2: Users who gave more than 50 five-star ratings
MATCH (u:User)-[r:RATED]->(m:Movie)
WHERE r.rating = 5
WITH u, count(m) AS fiveStarCount
WHERE fiveStarCount > 50
RETURN
    u.userId AS userId,
    fiveStarCount
ORDER BY fiveStarCount DESC
LIMIT 10;


// Query 3: Movies highly rated by both users
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)
MATCH (u2:User {userId: 2})-[r2:RATED]->(m)
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN
    m.title AS movie,
    r1.rating AS user1Rating,
    r2.rating AS user2Rating
ORDER BY movie
LIMIT 10;


// Query 4: Genres with consistently high ratings
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(u:User)
WITH
    g,
    avg(r.rating) AS avgRating,
    count(r) AS ratingCount
RETURN
    g.name AS genre,
    round(avgRating, 2) AS avgRating,
    ratingCount
ORDER BY avgRating DESC, ratingCount DESC;


// Query 5: Collaborative movie recommendations
MATCH (target:User {userId: 1})-[r1:RATED]->(shared:Movie)
WHERE r1.rating >= 4

MATCH (similar:User)-[r2:RATED]->(shared)
WHERE similar <> target AND r2.rating >= 4

WITH target, similar, count(DISTINCT shared) AS commonMovies
WHERE commonMovies >= 3

MATCH (similar)-[r3:RATED]->(recommended:Movie)
WHERE r3.rating >= 4
  AND NOT EXISTS {
      MATCH (target)-[:RATED]->(recommended)
  }

WITH
    recommended,
    count(DISTINCT similar) AS supportingUsers,
    avg(r3.rating) AS avgRating

RETURN
    recommended.title AS movie,
    supportingUsers,
    round(avgRating, 2) AS avgRating
ORDER BY supportingUsers DESC, avgRating DESC
LIMIT 10;


// Query 6: Shortest path between two users
MATCH (u1:User {userId: 1})
MATCH (u2:User {userId: 2})

MATCH p = shortestPath(
    (u1)-[:RATED*..6]-(u2)
)

RETURN
    p,
    length(p) AS pathLength;
