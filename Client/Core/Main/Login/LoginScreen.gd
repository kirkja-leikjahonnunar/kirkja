extends Control

# Main Login Controls.
@onready var USERNAME_IN := $MainLoginWindow/VBoxContainer/Username
@onready var PASSWORD_IN := $MainLoginWindow/VBoxContainer/Password
@onready var BACKTOLOGIN_BUTTON = $MainLoginWindow/VBoxContainer/BackToLogin
@onready var LOGIN_BUTTON = $MainLoginWindow/VBoxContainer/Login
@onready var REGISTER_BUTTON = $MainLoginWindow/VBoxContainer/Register
@onready var REGISTER_NAME = $MainLoginWindow/VBoxContainer/RegisterScreenName
@onready var REGISTER_EMAIL = $MainLoginWindow/VBoxContainer/RegisterEmail
@onready var SERVER_IP = $MainLoginWindow/VBoxContainer/IP/LineEdit
@onready var OPINE = $MainLoginWindow/VBoxContainer/Opine

var server_ip: String = "127.0.0.1"
var gateway_port: int = 1910

# this will be activated on escape
var parent_menu

#-------------------------- Widget state helpers ----------------------------

enum LoginState { PreLogin, LoggingIn, Register, Registering }
var login_state := LoginState.PreLogin

func SetWindowState(state):
	login_state = state
	match state:
		LoginState.PreLogin:
			BACKTOLOGIN_BUTTON.visible = false
			LOGIN_BUTTON.visible = true
			LOGIN_BUTTON.disabled = false
			REGISTER_BUTTON.disabled = false
			#REGISTER_BUTTON.text = "Register"
			REGISTER_NAME.visible = false
			#REGISTER_EMAIL.visible = false
		
		LoginState.LoggingIn:
			BACKTOLOGIN_BUTTON.visible = false
			LOGIN_BUTTON.visible = true
			LOGIN_BUTTON.disabled = true
			REGISTER_BUTTON.disabled = true
			REGISTER_NAME.visible = false
			#REGISTER_EMAIL.visible = false
		
		LoginState.Register:
			BACKTOLOGIN_BUTTON.visible = true
			BACKTOLOGIN_BUTTON.disabled = false
			LOGIN_BUTTON.visible = false
			LOGIN_BUTTON.disabled = true
			REGISTER_BUTTON.disabled = false
			REGISTER_NAME.visible = true
			#REGISTER_EMAIL.visible = true
		
		LoginState.Registering:
			BACKTOLOGIN_BUTTON.disabled = true
			LOGIN_BUTTON.visible = false
			LOGIN_BUTTON.disabled = true
			REGISTER_BUTTON.disabled = true
			#REGISTER_BUTTON.text = "Registering..." <- use Opine instead
			REGISTER_NAME.visible = true
			#REGISTER_EMAIL.visible = true


#------------------------ Main ------------------------------

func _ready():
	LoadConnectionSettings()
	SetWindowState(LoginState.PreLogin)
	USERNAME_IN.grab_focus()


# pop up a message for user
func Opine(message: String):
	OPINE.text = message
	print(message)


#----------------- connect signals ---------------------------
func SetupSignals():
	GameServer.logged_on.connect(LoginSucceeded)
	GameServer.logon_failed.connect(LoginRejectedFromGameServer)
	GameServer.gameserver_dropped.connect(GameServerDropped)
	#get_node("/root/Client/LoginScreen").LoginRejectedFromGameServer()


#----------------------- Log in --------------------------------

func _on_login_pressed():
	AttemptLogin()


func AttemptLogin():
	if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
		Opine("Please provide a username and password.")
	else:
		SetWindowState(LoginState.LoggingIn)
		var username = USERNAME_IN.get_text()
		var password = PASSWORD_IN.get_text()
		Opine("Attempting to login...")
		# TODO: Set timer.
		SaveConnectionSettings()
		if SERVER_IP.text != "":
			server_ip = SERVER_IP.text
		else:
			server_ip = "127.0.0.1"
		GatewayServer.ip = server_ip
		GameServer.ip = server_ip
		GatewayServer.ConnectToServer(username, password, false)


func GatewayConnectionFailed():
	Opine("Client connection to gateway failed!")
	if login_state == LoginState.Registering:
		SetWindowState(LoginState.Register)
	else:
		SetWindowState(LoginState.PreLogin)


func LoginSucceeded():
	print ("LoginScreen got logged_on signal")
	if parent_menu != null:
		visible = false
		parent_menu.visible = false
	else:
		visible = false


func LoginRejected():
	Opine("Bad username or password.")
	SetWindowState(LoginState.PreLogin)

func LoginRejectedFromGameServer():
	Opine("Login rejected.")
	SetWindowState(LoginState.PreLogin)


# When a GameServer vanishes for any reason, this turns back on the Login window.
# The game otherwise still needs to be halted elsewhere.
func GameServerDropped():
	visible = true
	SetWindowState(LoginState.PreLogin)
	Opine("Game server dropped!")


#----------------------- Register --------------------------------


func _on_register_pressed():
	if login_state == LoginState.PreLogin:
		SetWindowState(LoginState.Register)
	else:
		if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
			Opine("Please provide a username and password.")
		else:
			if USERNAME_IN.text == "" or PASSWORD_IN.text == "":
				Opine("Please provide a username and password.")
			else:
				SetWindowState(LoginState.Registering)
				var username = USERNAME_IN.get_text()
				var password = PASSWORD_IN.get_text()
				Opine("Registering...")
				
				SaveConnectionSettings()
				if SERVER_IP.text != "":
					server_ip = SERVER_IP.text
				else:
					server_ip = "127.0.0.1"
				GatewayServer.ip = server_ip
				GameServer.ip = server_ip
				GatewayServer.ConnectToServer(username, password, true)

func _input(event):
	if event is InputEventKey:
		if event.physical_keycode == KEY_ESCAPE && event.pressed == false:
			print ("LoginScreen got unhandled escape")
			if login_state == LoginState.Register:
				SetWindowState(LoginState.PreLogin)
				get_viewport().set_input_as_handled()


func CreateAccountResults(result: bool, msg: String):
	Opine(msg)
	SetWindowState(LoginState.Register)
	if result == false:
		print ("Create account failed!")
	else: print ("Create account succeeded!")


# Note this should only be callable during register.
func _on_back_to_login_pressed():
	SetWindowState(LoginState.PreLogin)


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
			SERVER_IP.text = data.ip
	else:
		print_debug("Error parsing connection settings file ", file)

func SaveConnectionSettings():
	var json := JSON.new()
	var data = { "ip": SERVER_IP.text }
	var json_string = json.stringify(data, '  ')
	
	var file = File.new()
	var err = file.open(connection_file, File.WRITE)
	if err != OK:
		return false
	file.store_string(json_string)
	file.close()
	print ("Connection settings saved to file ", connection_file)


