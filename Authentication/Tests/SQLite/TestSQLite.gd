extends Node2D


var db #: SQLite
var db_path = "res://DataStore/kirkja_authentication.db"
var db_user_table = "users"
var db_verbose := true #TODO: FOR DEBUGGING ONLY! SET TO FALSE IN PRODUCTION CODE! It will output data to console otherwise.

# users:
#   username
#   password
#   salt
#   status:
#     0 ok
#     1 disabled
#     2 must_verify
#     3 banned
#   last_login:  "20220518-18:23:56"


# Tests:
# - [ ] If you are logged in, you should not be able to log in again
# - [ ] Create new user
# - [ ] 

# Called when the node enters the scene tree for the first time.
func _ready():
	InitializeDB_SQLite()
	
	#var data = UserData_SQLite("freyak")
	#print ("data: ", data)
	
	print ("has unblinky: ", HasPlayer_SQLite("unblinky"))
	print ("has 242342: ", HasPlayer_SQLite("242342"))
	
	print ("-------------")
	SetUserPassword_SQLite("unblinky", "fake-hash", "some salt", false)
	SetUserPassword_SQLite("notauser", "fake-hash", "some salt", false)
	SetUserPassword_SQLite("notauser", "fake-hash", "some salt", true)
	
	RemoveUser("notauser")



func InitializeDB_SQLite():
	db = SQLite.new()
	db.path = db_path
	db.verbose_mode = db_verbose
	db.open_db()

# Use with caution!!
func RemoveUser(username: String) -> bool:
	print ("Remove user "+username+"...")
	var user = SanitizeUsername(username)
	if user != username: # we were passed an invalid username
		print ("Bad username.")
		return false
	# DELETE FROM users WHERE username = "username"
	var status = db.delete_rows(db_user_table, "username = \""+username+"\"")
	if status:
		print ("User removed!")
		return true
	print ("Removal failed with: ", db.error_message)
	return false


func SetUserPassword_SQLite(username: String, hashed_password: String, salt: String, is_new_user: bool):
	print ("Set password for "+username+"...")
	var user = SanitizeUsername(username)
	if user != username: # we were passed an invalid username
		print ("Bad username, not updating password")
		return false
	
	if not HasPlayer_SQLite(user):
		if is_new_user:
			# INSERT INTO users (username,password,salt) VALUES (?,?,?)
			var dict = { "username": user, "password": hashed_password, "salt": salt }
			var status = db.insert_row(db_user_table, dict)
			if !status:
				print ("Error adding user to database")
				return false
			print ("Added user to database!")
			return true
		else:
			print ("Unknown username "+user)
			return false
	
	# check that hashed_password and salt are hex strings
	if not IsHexString(hashed_password) || not IsHexString(salt):
		print ("Password or salt not hex string. Possible attack!")
		return false
	
	# UPDATE users SET password=? salt=? WHERE username = "user"
	var success = db.update_rows(db_user_table, "username = \""+user+"\"", { "password": hashed_password, "salt": salt })
	if success:
		print ("Password updated for "+user)
	else:
		print ("Error updating password for "+user)
		
	return success


func HasPlayer_SQLite(username: String) -> bool:
	print ("HasPlayer ", username, "...")
	username = SanitizeUsername(username)
	if username == null || username == "":
		print ("username had bad characters")
		return false
	
	var select_condition := "username = '%s'" % [username]
	var selected_array = db.select_rows(db_user_table, select_condition, ["username", "password", "salt"])
	
	var success = db.query_with_bindings("SELECT username, password, salt FROM "+db_user_table+" WHERE username == ?;", [username])
	var selected_array2 : Array = db.query_result
	print ("query result2: ", success, ", data: ", selected_array2)
	
	print ("query result: ", selected_array)
	return selected_array.size() > 0


# Return the user's (hashed) password.
func UserData_SQLite(username: String):
	username = SanitizeUsername(username)
	if username == null || username == "":
		return null
	var success : bool = db.query("SELECT [username, password, salt] FROM %s WHERE username = '%s'" % [db_user_table, username])
	if !success || db.query_result.size() != 1:
		return null
	
	return db.query_result[0]


#-------------------- Helper functions -------------------------------

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

