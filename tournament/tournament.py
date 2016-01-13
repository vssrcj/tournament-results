#!/usr/bin/env python
"""tournament.py -- implementation of a Swiss-system tournament"""

import psycopg2
#import random


def connect():
    """Connect to the PostgreSQL database.  Returns a database connection."""
    return psycopg2.connect("dbname=tournament")


def deleteMatches():
    """Remove all the match records from the database."""
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("delete from results;")
    connection.commit()
    connection.close()


def deletePlayers():
    """Remove all the player records from the database."""
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("delete from people;")
    connection.commit()
    connection.close()


def countPlayers():
    """Returns the number of players currently registered."""
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("select count(*) from people;")
    row = cursor.fetchone()
    connection.close()
    return row[0]


def registerPlayer(name):
    """Adds a player to the tournament database.

    The database assigns a unique serial id number for the player.  (This
    should be handled by your SQL database schema, not in your Python code.)

    Args:
      name: the player's full name (need not be unique).
    """
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("insert into people(name) values(%s);", (name,))
    connection.commit()
    connection.close()


def playerStandings():
    """Returns a list of the players and their win records, sorted by wins.

    The first entry in the list should be the player in first place, or a player
    tied for first place if there is currently a tie.

    Returns:
      A list of tuples, each of which contains (id, name, wins, matches):
        id: the player's unique id (assigned by the database)
        name: the player's full name (as registered)
        wins: the number of matches the player has won
        matches: the number of matches the player has played
    """
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("select id, name, wins, matches from playerStandings;")
    rows = cursor.fetchall()
    connection.close()
    return rows


def reportMatch(winner, loser, draw=False):
    """Records the outcome of a single match between two players.

    Args:
      winner:  the id number of the player who won
      loser:  the id number of the player who lost
    """
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("insert into results(winner_id, loser_id, draw) "
        "values(%s,%s,%s);", (winner, loser, draw))
    connection.commit()
    connection.close()


def byePlayer(paired_players):
    """Gets the player that hasn't been paired up yet.

    Args:
        paired_players: a list that contains all the players that have been
                        paired up

    Returns:
        A tuple of in the form of (id, name)
    """
    if not paired_players:
        return None
    connection = connect()
    cursor = connection.cursor()
    cursor.execute("select id, name from people where id not in %s;",
        (tuple(paired_players),))
    bye_player = cursor.fetchone()

    connection.close()

    return bye_player


def swissPairings():
    """Returns a list of pairs of players for the next round of a match.

    Assuming that there are an even number of players registered, each player
    appears exactly once in the pairings.  Each player is paired with another
    player with an equal or nearly-equal win record, that is, a player adjacent
    to him or her in the standings.

    Returns:
      A list of tuples, each of which contains (id1, name1, id2, name2)
        id1: the first player's unique id
        name1: the first player's name
        id2: the second player's unique id
        name2: the second player's name
    """
    player_count = countPlayers()

    connection = connect()
    cursor = connection.cursor()
    cursor.execute("select id1, name1, id2, name2 from matchupsRemaining;")

    pairings = [] #the return list of tuples
    paired_players = [] #the ids of paired players

    for row in cursor:
        if row[0] not in paired_players and row[2] not in paired_players:
            paired_players.extend([row[0], row[2]])
            pairings.append(row)
            if len(paired_players) >= player_count - 1:
                break

    connection.close()

    if player_count % 2 != 0:
        bye_player = byePlayer(paired_players)
        if bye_player is None:
            return []
        else: pairings.extend([bye_player, bye_player])

    return pairings


#def sampleTournament():
#    """This is a test to run a full tournament with data already in the db"""
#    pairings = swissPairings()
#    current_round = 1
#
#    while pairings != []:
#        print 'Round ' + str(current_round)
#        print 'Pairings ' + str(pairings)
#        for pair in pairings:
#            if pair[0] == pair[1]:
#                reportMatch(pair[0], pair[0])
#            else:
#                first_win = True if random.getrandbits(1) == 1 else False
#                draw = True if random.getrandbits(1) == 1 else False
#                if first_win:
#                    reportMatch(pair[0], pair[2], draw)
#                else:
#                    reportMatch(pair[2], pair[0], draw)
#        print 'Standings ' + str(playerStandings())
#        pairings = swissPairings()
#        current_round = current_round + 1

