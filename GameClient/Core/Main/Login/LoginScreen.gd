extends Control

# Main Login Controls.
@onready var USERNAME_IN := $MainLoginWindow/VBoxContainer/Username
@onready var PASSWORD_IN := $MainLoginWindow/VBoxContainer/Password
@onready var LOGIN_BUTTON = $MainLoginWindow/VBoxContainer/HBoxContainer/Login
@onready var REGISTER_BUTTON = $MainLoginWindow/VBoxContainer/HBoxContainer/Register
@onready var OPINE = $MainLoginWindow/VBoxContainer/Opine

var server_ip: String = "127.0.0.1"
var gateway_port: int = 1910


func _ready():
	USERNAME_IN.grab_focus()
	LoadConnectionSettings()


# pop up a message for user
func Opine(message: String):
	OPINE.text = message
	print(message)


func _on_login_pressed():
	AttemptLogin()


func AttemptLogin():
	if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
		Opine("Please provide a username and password.")
	else:
		LOGIN_BUTTON.disabled = true
		REGISTER_BUTTON.disabled = true
		var username = USERNAME_IN.get_text()
		var password = PASSWORD_IN.get_text()
		Opine("Attempting to login...")
		# TODO: Set timer.
		SaveConnectionSettings()
		if $MainLoginWindow/VBoxContainer/IP/LineEdit.text != "":
			server_ip = $MainLoginWindow/VBoxContainer/IP/LineEdit.text
		else:
			server_ip = "127.0.0.1"
		GatewayServer.ip = server_ip
		GameServer.ip = server_ip
		GatewayServer.ConnectToServer(username, password, false)


func ConnectionFailed():
	Opine("Client connection to gateway failed!")
	LOGIN_BUTTON.disabled = false
	REGISTER_BUTTON.disabled = false


func LoginSucceeded():
	visible = false


func LoginRejected():
	Opine("Bad username or password.")
	LOGIN_BUTTON.disabled = false
	REGISTER_BUTTON.disabled = false

func LoginRejectedFromGameServer():
	Opine("Login rejected.")
	LOGIN_BUTTON.disabled = false
	REGISTER_BUTTON.disabled = false


func _on_register_pressed():
	if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
		Opine("Please provide a username and password.")
	else:
		if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
			Opine("Please provide a username and password.")
		else:
			LOGIN_BUTTON.disabled = true
			REGISTER_BUTTON.disabled = true
			var username = USERNAME_IN.get_text()
			var password = PASSWORD_IN.get_text()
			Opine("Registering...")
			
			SaveConnectionSettings()
			if $MainLoginWindow/VBoxContainer/IP/LineEdit.text != "":
				server_ip = $MainLoginWindow/VBoxContainer/IP/LineEdit.text
			else:
				server_ip = "127.0.0.1"
			GatewayServer.ip = server_ip
			GameServer.ip = server_ip
			GatewayServer.ConnectToServer(username, password, true)

func CreateAccountResults(result: bool, msg: String):
	Opine(msg)
	LOGIN_BUTTON.disabled = false
	REGISTER_BUTTON.disabled = false
	if result == false:
		print ("Create account failed!")
	else: print ("Create account succeeded!")


# When a GameServer vanishes for any reason, this turns back on the Login window.
func GameServerDropped():
	visible = true
	LOGIN_BUTTON.disabled = false
	REGISTER_BUTTON.disabled = false
	Opine("")


#--------------------- Persistent connection settings ---------------------------

var connection_file = "user://connect.json"

func LoadConnectionSettings():
	var file = File.new()
	if file.open(connection_file, File.READ) != OK:
		print("No connection settings file at ", connection_file)
		return

	var json := JSON.new()
	var err = json.parse(file.get_as_text())
	file.close()
	if err == OK:
		var data = json.get_data()
		if "ip" in data && data.ip is String:
			$MainLoginWindow/VBoxContainer/IP/LineEdit.text = data.ip
	else:
		print_debug("Error parsing connection settings file ", file)

func SaveConnectionSettings():
	var json := JSON.new()
	var data = { "ip": $MainLoginWindow/VBoxContainer/IP/LineEdit.text }
	var json_string = json.stringify(data, '  ')
	
	var file = File.new()
	var err = file.open(connection_file, File.WRITE)
	if err != OK:
		return false
	file.store_string(json_string)
	file.close()
	print ("Connection settings saved to file ", connection_file)

