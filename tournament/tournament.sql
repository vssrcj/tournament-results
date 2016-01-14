-- Table definitions for the tournament project.

DROP TABLE IF EXISTS results CASCADE;
DROP TABLE IF EXISTS people CASCADE;
    
CREATE TABLE people
( 
    id serial primary key,
    name text not null
);

CREATE TABLE results
(   
-- If a draw occurs, then it doesn't matter if which person is stored under
-- winner_id or loser_id
--
-- If there an uneven amount of players, then one person receives a bye.
-- This means that winner_id and loser_id is both the id of the person who
-- receives a bye and the draw must be false.
--
    winner_id int references people(id),
    loser_id int references people(id),
    draw boolean not null,
    check (draw = false or winner_id != loser_id),
    primary key (winner_id, loser_id)
);

-- The following is how a multiple tournament setup would've worked
--
-- CREATE TABLE tournament
-- (
--	 id serial primary key,
--	 name text not null
-- );
--
-- Because the relationship between people and tournament is many-to-many the
-- following mapping table would be used
--
-- CREATE TABLE tournamentPlayers
-- (
--	 tournament_id int references tournament(id),
--	 people_id int references people(id),
--	 primary key(tournament_id, people_id)
-- );
--
-- Add tournament.id to the table results as another primary key


CREATE VIEW matchesWon AS

    SELECT 
        winner_id id,   -- player's id
        count(*) count  -- amount of matches won (will not return anything if 0)
    FROM results
    WHERE draw = false
    GROUP BY winner_id;


CREATE VIEW matchesPlayed AS

    SELECT 
	id, 
	name, 
	(SELECT count(*)
 	 FROM results
 	 WHERE results.winner_id != results.loser_id    -- discount byes
	 AND (results.winner_id = people.id             -- match as winner
 	 OR results.loser_id = people.id)) count        -- match as loser
    FROM people
	ORDER BY count DESC;


CREATE VIEW omw AS -- opponent match wins

    SELECT 
        people.id,              -- player's id
        sum((SELECT count 
             FROM matchesWon 
             WHERE matchesWon.id = 
                CASE WHEN people.id = winner_id THEN 
                    loser_id    -- if player was the winner, count loser's wins
                ELSE winner_id  -- if player was the loser, count winner's wins
                END)) count
    FROM people LEFT JOIN results
    ON people.id = winner_id OR people.id = loser_id 
    WHERE winner_id != loser_id -- discount byes
    GROUP BY people.id;


CREATE VIEW playerStandings AS 

    SELECT 
        matchesPlayed.id, 
        matchesPlayed.name, 
        coalesce(matchesWon.count,0) wins,  -- 0 if null
        coalesce(omw.count,0) omw,          -- 0 if null
        matchesPlayed.count matches
    FROM matchesPlayed
    LEFT JOIN matchesWon 
 	ON matchesPlayed.id = matchesWon.id
    LEFT JOIN omw
    ON matchesWon.id = omw.id
	ORDER BY wins DESC, omw DESC, matches DESC, id;

CREATE VIEW matchups AS
-- This returns all the possible matchups/pairings that can occur
-- (excluding byes)

	SELECT a.id id1, a.name name1, b.id id2, b.name name2, 
        abs(a.wins - b.wins) as winDifference,
        (a.matches + b.matches) matchesCombined
	FROM playerStandings a, playerStandings b
	WHERE a.id < b.id;


CREATE VIEW matchupsRemaining AS
-- Returns matchups/pairings that haven't occured yet.  It does so by returning
-- the matchups that exists in the matchups VIEW, but does not occur
-- in the results TABLE.  The LEFT JOIN acts as an EXCEPT statement.,

	SELECT id1, name1, id2, name2, winDifference, matchesCombined
	FROM matchups
	LEFT JOIN results a 
	ON matchups.id1 = a.winner_id
	AND matchups.id2 = a.loser_id
    LEFT JOIN results b 
	ON matchups.id1 = b.loser_id
	AND matchups.id2 = b.winner_id
	WHERE a.winner_id IS NULL
    AND b.loser_id IS NULL
    ORDER BY winDifference, matchesCombined, id1, id2;
