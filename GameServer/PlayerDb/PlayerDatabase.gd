extends Node


# sqlite settings:
var db : SQLite
var db_path = "res://PlayerDb/player_data.db" #TODO: this can't be in res:// for deployment
var db_user_table = "users"
var db_verbose := 1 #TODO: FOR DEBUGGING ONLY! SET TO FALSE IN PRODUCTION CODE! It will output data to console otherwise.



func _ready():
	InitializeDB_SQLite()


#------------------------- Database operations -----------------------------

func InitializeDB_SQLite():
	db = SQLite.new()
	db.path = db_path
	db.verbosity_level = db_verbose
	db.open_db() #TODO: figure out why this throws:  _ready: Condition "_instance_bindings != nullptr" is true.

func CloseDB_SQLite():
	db.close_db()


func HasPlayer(username: String) -> bool:
	DebugLog3 ("HasPlayer ", username, "...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		DebugLog ("username had bad characters")
		return false
	
	var success = db.query_with_bindings("SELECT user FROM player_data WHERE user == ?;", [username])
	if not success:
		return false
	var selected_array : Array = db.query_result
	#DebugLog ("query result: "+ str(success) + ", data: " + str(selected_array))
	
	return selected_array.size() > 0


# if not is_new_user, then this will return false if username does not exist. Else it will be added.
func SetUserData_SQLite(username: String, what: String, data):
	DebugLog ("Set data for "+username+"...")
	var user = SanitizeUsername(username)
	if user != username: # we were passed an invalid username
		DebugLog ("Bad username, not updating password")
		return false
	
	if not HasPlayer(user):
		DebugLog ("Unknown username "+user)
		return false
	
	# UPDATE users SET password=? salt=? WHERE username = "user"
	var success = db.update_rows("player_data", "user = \""+user+"\"", { what: data })
	if success:
		DebugLog ("Password updated for "+user)
	else:
		DebugLog ("Error updating password for "+user)
		
	return success



# Return the user's basic info it needs right after logging in, like last location, or last skin.
func GetPlayerInitialData(username: String):
	DebugLog("Get initial data for "+username+"...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		DebugLog("Bad username")
		return null
	var success : bool = db.query_with_bindings("SELECT user, screen_name, skin, skin_tint, last_map, last_pos FROM player_data WHERE user == ?;", [username])
	if !success || db.query_result.size() != 1:
		return null
	
	return db.query_result[0]


func GetPlayerData(username: String, what: String):
	DebugLog3("Get ", what, " for "+username+"...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		DebugLog("Bad username")
		return null
	#TODO: should check what against allowed table names
	var success : bool = db.query_with_bindings("SELECT user, "+what+" FROM player_data WHERE user == ?;", [username])
	if !success || db.query_result.size() != 1:
		return null
	
	return db.query_result[0]


# Keep track of how much time a player has 
func AddTimeForPlayer(user: String, time: float):
	var old_time = GetPlayerData(user, "age")
	if old_time is float:
		time += old_time
	SetUserData_SQLite(user, "age", time)


#-------------------- Helper functions -------------------------------

#TODO: Write to a file for convenience later...
func DebugLog(msg: String):  print (msg)
func DebugLog2(msg1: String, msg2: String):  print (msg1, msg2)
func DebugLog3(msg1: String, msg2: String, msg3: String):  print (msg1, msg2, msg3)

func SanitizeUsername(username: String) -> String:
	for ch in username:
		if not ".abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains(ch):
			return ""
	return username


func IsHexString(hex: String) -> bool:
	for ch in hex:
		if not "0123456789abcdefABCDEF".contains(ch):
			return false
	return true
