-- Table definitions for the tournament project.
--
-- Put your SQL 'create table' statements in this file; also 'create view'
-- statements if you choose to use it.
--
-- You can write comments in this file by starting them with two dashes, like
-- these lines here.

DROP TABLE IF EXISTS results CASCADE;
DROP TABLE IF EXISTS people CASCADE;
    
CREATE TABLE people
( 
    id serial primary key,
    name text not null
);

CREATE TABLE results
(   
    winner_id int references people(id),
    loser_id int references people(id),
    draw boolean not null,
    check (draw = false or winner_id != loser_id),
    primary key (winner_id, loser_id)
);

--CREATE TABLE tournament
--(
--	id serial primary key,
--	name text not null
--);

--Because the relationship between people and tournament is many-to-many the
--following mapping table would be used

--CREATE TABLE tournamentPlayers
--(
--	tournament_id int references tournament(id),
--	people_id int references people(id),
--	primary key(tournament_id, people_id)
--);

-- Add tournament.id to results as another primary key


INSERT INTO people (name) VALUES('CJ');
INSERT INTO people (name) VALUES('Pa');
INSERT INTO people (name) VALUES('Ma');
INSERT INTO people (name) VALUES('Wes');
INSERT INTO people (name) VALUES('CJ2');
INSERT INTO people (name) VALUES('Pa2');
INSERT INTO people (name) VALUES('Ma2');
INSERT INTO people (name) VALUES('Wes2');
INSERT INTO people (name) VALUES('CJ3');
INSERT INTO people (name) VALUES('Pa3');
INSERT INTO people (name) VALUES('Ma3');
INSERT INTO people (name) VALUES('Wes3');
INSERT INTO people (name) VALUES('CJ4');
INSERT INTO people (name) VALUES('Pa4');
INSERT INTO people (name) VALUES('Ma4');
INSERT INTO people (name) VALUES('Wes4');
--INSERT INTO people (name) VALUES('Ann');
--INSERT INTO people (name) VALUES('Ben');
--INSERT INTO people (name) VALUES('Dan');
--INSERT INTO people (name) VALUES('Elkl');

--INSERT INTO results VALUES(1,2); 
--INSERT INTO results VALUES(3,4);
--INSERT INTO results VALUES(5,5);

--1 1,2 0,3 1,4 0,5*1

--INSERT INTO results VALUES(1,1); 
--INSERT INTO results VALUES(2,4);
--INSERT INTO results VALUES(3,5);

--1*2,2 1,3 2,4 0,5*1

--INSERT INTO results VALUES(2,2); 
--INSERT INTO results VALUES(1,3);
--INSERT INTO results VALUES(4,5);

--1*3,2*2,3 2,4 1,5*1

--INSERT INTO results VALUES(1,5);
--INSERT INTO results VALUES(2,4);
--INSERT INTO results VALUES(3,3);*



--INSERT INTO results VALUES(1,3);
--INSERT INTO results VALUES(2,5);
--INSERT INTO results VALUES(4,4);*
--INSERT INTO results VALUES(4,5);
--INSERT INTO results VALUES(2,3);
--INSERT INTO results VALUES(1,1);*


--INSERT INTO results VALUES(5,6);
--INSERT INTO results VALUES(7,8);
--INSERT INTO results VALUES(1,3);
--INSERT INTO results VALUES(5,7);
--INSERT INTO results VALUES(2,4);
--INSERT INTO results VALUES(6,8);

CREATE VIEW matchesWon AS
-- Returns the id and the amount of matches won
-- (will only return if at least one match is won)

    SELECT 
        winner_id id, 
        count(*) count
    FROM results
    WHERE draw = false
    GROUP BY winner_id;


CREATE VIEW matchesPlayed AS

    SELECT 
	id, 
	name, 
	(SELECT count(*)
 	 FROM results
 	 WHERE results.winner_id != results.loser_id 
	 AND (results.winner_id = people.id
 	 OR results.loser_id = people.id)) count
    FROM people
	ORDER BY count DESC;


CREATE VIEW omw AS

    SELECT 
        people.id, 
        sum((SELECT count 
             FROM matchesWon 
             WHERE matchesWon.id = 
                CASE WHEN people.id = winner_id THEN loser_id
                ELSE winner_id 
                END)) count
    FROM people LEFT JOIN results
    ON people.id = winner_id OR people.id = loser_id 
    WHERE winner_id != loser_id
    GROUP BY people.id;


CREATE VIEW playerStandings AS 

    SELECT 
        matchesPlayed.id, 
        matchesPlayed.name, 
        coalesce(matchesWon.count,0) wins, 
        coalesce(omw.count,0) omw,
        matchesPlayed.count matches
    FROM matchesPlayed
    LEFT JOIN matchesWon 
 	ON matchesPlayed.id = matchesWon.id
    LEFT JOIN omw
    ON matchesWon.id = omw.id
	ORDER BY wins DESC, omw DESC, matches DESC, id;

CREATE VIEW matchups AS
-- This returns all the possible matchups/pairings that can occur

	SELECT a.id id1, a.name name1, b.id id2, b.name name2, 
        abs(a.wins - b.wins) as winDifference,
        (a.matches + b.matches) matchesCombined
	FROM playerStandings a, playerStandings b
	WHERE a.id < b.id;


CREATE VIEW matchupsRemaining AS
-- Returns matchups/pairings that haven't occured yet.  It does so by returning
-- the matchups that exists in the matchups VIEW, but does not occur
-- in the results TABLE.  The LEFT JOIN acts as a EXCEPT statement.,

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






	
