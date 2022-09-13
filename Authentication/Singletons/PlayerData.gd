extends Node

#TODO FIXME!!

var use_sql := true # use sqlite, otherwise JSON version


# sqlite settings:
var db
var db_path = "res://DataStore/kirkja_authentication.db"
var db_user_table = "users"
var db_verbose := 2 #TODO: FOR DEBUGGING ONLY! SET TO FALSE IN PRODUCTION CODE! It will output data to console otherwise.



func _ready():
	if use_sql:
		InitializeDB_SQLite()
	else:
		InitializeUserDB_JSON()


#------------------------- Database operations -----------------------------

func HasPlayer(username: String):
	if use_sql:
		return HasPlayer_SQLite(username)
	else:
		return HasPlayer_JSON(username)


# Return the user's (hashed) password.
func UserData(username: String):
	if use_sql:
		return UserData_SQLite(username)
	else:
		return UserData_JSON(username)


func SetUserPassword(username: String, hashed_password: String, salt: String, is_new_user: bool) -> bool:
	if use_sql:
		return SetUserPassword_SQLite(username, hashed_password, salt, is_new_user)
	else:
		return SetUserPassword_JSON(username, hashed_password, salt)




#------------------------ SQLite database -----------------------------

func InitializeDB_SQLite():
	db = SQLite.new()
	db.path = db_path
	db.verbosity_level = db_verbose
	db.open_db() #TODO: figure out why this throws:  _ready: Condition "_instance_bindings != nullptr" is true.


# if not is_new_user, then this will return false if username does not exist. Else it will be added.
func SetUserPassword_SQLite(username: String, hashed_password: String, salt: String, is_new_user: bool):
	DebugLog ("Set password for "+username+"...")
	var user = SanitizeUsername(username)
	if user != username: # we were passed an invalid username
		DebugLog ("Bad username, not updating password")
		return false
	
	if not HasPlayer_SQLite(user):
		if is_new_user:
			# INSERT INTO users (username,password,salt) VALUES (?,?,?)
			var status = db.insert_row(db_user_table, { "username": user, "password": hashed_password, "salt": salt })
			if !status:
				DebugLog ("Error adding user to database")
				return false
			DebugLog ("Added user to database!")
			return true
		else:
			DebugLog ("Unknown username "+user)
			return false
	
	# check that hashed_password and salt are hex strings
	if not IsHexString(hashed_password) || not IsHexString(salt):
		DebugLog ("Password or salt not hex string. Possible attack!")
		return false
	
	# UPDATE users SET password=? salt=? WHERE username = "user"
	var success = db.update_rows(db_user_table, "username = \""+user+"\"", { "password": hashed_password, "salt": salt })
	if success:
		DebugLog ("Password updated for "+user)
	else:
		DebugLog ("Error updating password for "+user)
		
	return success


func HasPlayer_SQLite(username: String) -> bool:
	DebugLog3 ("HasPlayer ", username, "...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		DebugLog ("username had bad characters")
		return false
	
	var success = db.query_with_bindings("SELECT username, password, salt FROM "+db_user_table+" WHERE username == ?;", [username])
	if not success:
		return false
	var selected_array : Array = db.query_result
	DebugLog ("query result: "+ str(success) + ", data: " + str(selected_array))
	
	return selected_array.size() > 0


# Return the user's (hashed) password as { password, salt }.
func UserData_SQLite(username: String):
	DebugLog("Get user data for "+username+"...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		return null
	var success : bool = db.query("SELECT username, password, salt FROM %s WHERE username = '%s';" % [db_user_table, username])
	if !success || db.query_result.size() != 1:
		return null
	
	return db.query_result[0]


# Use with caution!!
#TODO: decide on strategy for user removal
func RemoveUser_SQLite(username: String) -> bool:
	DebugLog ("Remove user "+username+"...")
	var user = SanitizeUsername(username)
	if user != username: # we were passed an invalid username
		DebugLog ("Bad username.")
		return false
	# DELETE FROM users WHERE username = "username"
	var status = db.delete_rows(db_user_table, "username = \""+username+"\"")
	if status:
		DebugLog ("User removed!")
		return true
	DebugLog2 ("Removal failed with: ", db.error_message)
	return false


#------------------------ JSON "database" -----------------------------

var users : Dictionary = {}

func InitializeUserDB_JSON():
	var player_data_file = File.new()
	if player_data_file.open("res://DataStore/UserData.json", File.READ) != OK:
		print ("Could not open user database.")
		return
	
	var json = JSON.new()
	var err = json.parse(player_data_file.get_as_text())
	player_data_file.close()

	if err == OK:
		print ("User database initialized.")
		users = json.get_data()
		print ("users: ", users)
	else:
		print ("Error parsing user database.")


func HasPlayer_JSON(username: String):
	return username in users


func SetUserPassword_JSON(username, hashed_password, salt) -> bool:
	users[username] = { "password": hashed_password, "salt": salt }
	return SaveUserDatabase_JSON()


# Return the user's (hashed) password.
func UserData_JSON(username: String):
	if not (username in users): return null
	return users[username]


func SaveUserDatabase_JSON() -> bool:
	var json = JSON.new()
	var content = json.stringify(users)
	var users_data_file = File.new()
	var err = users_data_file.open("res://DataStore/UserData.json", File.WRITE)
	if err != OK:
		return false
	users_data_file.store_string(content)
	users_data_file.close()
	print ("Users data saved to file.")
	return true # false would be database/sql error for instance


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

# Allow a-zA-Z0-9@#$%^&*()!~
func IsValidPassword(password: String) -> bool:
	for ch in password:
		if not " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$^&*-.".contains(ch):
			return false
	return true

func IsHexString(hex: String) -> bool:
	for ch in hex:
		if not "0123456789abcdefABCDEF".contains(ch):
			return false
	return true
