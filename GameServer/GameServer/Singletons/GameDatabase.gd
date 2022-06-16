class_name GameDatabase
extends Node


# sqlite settings:
var db #: SQLite
var db_path = "res://DataStore/game.db"
var db_player_table = "players"
var db_verbose := true #TODO: FOR DEBUGGING ONLY! SET TO FALSE IN PRODUCTION CODE! It will output data to console otherwise.

# players table:
#   user id, same as in AuthenticationServer db
#   username
#   user nick
#   current map
#   last position
#   last orientation
#   last login time
#   current logged in server id
#   player logged in time
#   player UI prefs
#   player skin id
#   player skin tint
#   player inventory


# map table:
#   event schedule
#   population
