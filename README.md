# Project 2

*By [CJ](https://github.com/vssrcj)*

This project utilizes [Python](www.python.org) and [PostgreSQL](www.postgresql.org) to make a simple tournament system.

## What's included

```
├── tournament/
│   ├── tournament.py
│   ├── tournament.sql
│   ├── tournament_test.py
├── Vagrantfile
├── bootstrap.sh
```

## Get the files

Clone a copy of this repository on your local machine

```
git clone git://github.com/vssrcj/udacity-fullstack-project2.git
```

## Requirements

Python and PostgreSQL is needed.  A vagrant file is included that satisfies these requirements.

### Install Vagrant

Virtualbox (or another supported provider) is needed to run vagrant.
A guid is found [here](www.udacity.com/wiki/ud197/install-vagrant) to install both virtualbox and vagrant.

### Launch Vagrant

Navigate to the cloned repository.
Run:
```
vagrant up
vagrant ssh
```

Once Vagrant is booted up, and logged into, navigate to the tournament directory with:
```
cd /vagrant/tournament
```

Description
-----------

* **tournament.py** is a python contains all the functions that you can call for the tournament.
* **tournament.sql** contains the database structure and view.  It must be executed with postgresql before the python functions can work.

### To test the tournament

Run
```
python tournament_test.py
```
This will test the functionality of the of tournament.py and tournament.sql.

### Tournament functionality

* The method *swissPairings* will return a list of the next round of matchups
* There are no rematches
* There needn't be an even amount of players.  If so, a single player will receive
  a bye each round, that counts as a win (but not a match played)
* Draws are possible, it just needs to be added to the optional parameter in *reportMatch*
* Players are ranked according to wins, then opponent match wins
* A single tournament is supported per turn
