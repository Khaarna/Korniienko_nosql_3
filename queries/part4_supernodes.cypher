// Find movies with the highest number of ratings
MATCH (m:Movie)
WITH m, COUNT { (m)<-[:RATED]-(:User) } AS degree
RETURN
    m.title AS movie,
    degree
ORDER BY degree DESC
LIMIT 10;


// Find users with the highest number of ratings
MATCH (u:User)
WITH u, COUNT { (u)-[:RATED]->(:Movie) } AS degree
RETURN
    u.userId AS userId,
    degree
ORDER BY degree DESC
LIMIT 10;


// Find genres with the highest number of movie relationships
MATCH (g:Genre)
WITH g, COUNT { (g)<-[:HAS_GENRE]-(:Movie) } AS degree
RETURN
    g.name AS genre,
    degree
ORDER BY degree DESC
LIMIT 18;
