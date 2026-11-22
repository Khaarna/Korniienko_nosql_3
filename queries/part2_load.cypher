// Create unique constraints for node identifiers

CREATE CONSTRAINT user_id_unique IF NOT EXISTS
FOR (u:User)
REQUIRE u.userId IS UNIQUE;

CREATE CONSTRAINT movie_id_unique IF NOT EXISTS
FOR (m:Movie)
REQUIRE m.movieId IS UNIQUE;

CREATE CONSTRAINT genre_name_unique IF NOT EXISTS
FOR (g:Genre)
REQUIRE g.name IS UNIQUE;

SHOW CONSTRAINTS;


// Import users from CSV
LOAD CSV WITH HEADERS FROM 'file:///users.csv' AS row
MERGE (u:User {userId: toInteger(row.userId)})
SET
    u.gender = row.gender,
    u.age = toInteger(row.age),
    u.occupation = toInteger(row.occupation);


// Import movies from CSV
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MERGE (m:Movie {movieId: toInteger(row.movieId)})
SET
    m.title = row.title,
    m.year = toInteger(
        substring(row.title, size(row.title) - 5, 4)
    );


// Create genres and movie-genre relationships
LOAD CSV WITH HEADERS FROM 'file:///movies.csv' AS row
MATCH (m:Movie {movieId: toInteger(row.movieId)})
UNWIND split(row.genres, '|') AS genreName
MERGE (g:Genre {name: genreName})
MERGE (m)-[:HAS_GENRE]->(g);


// Import ratings in batches using APOC
CALL apoc.periodic.iterate(
    "
    LOAD CSV WITH HEADERS FROM 'file:///ratings.csv' AS row
    RETURN row
    ",
    "
    MATCH (u:User {userId: toInteger(row.userId)})
    MATCH (m:Movie {movieId: toInteger(row.movieId)})
    MERGE (u)-[r:RATED]->(m)
    SET
        r.rating = toInteger(row.rating),
        r.timestamp = toInteger(row.timestamp)
    ",
    {
        batchSize: 5000,
        parallel: false,
        retries: 3
    }
)
YIELD batches, total, failedBatches, failedOperations, errorMessages
RETURN
    batches,
    total,
    failedBatches,
    failedOperations,
    errorMessages;
