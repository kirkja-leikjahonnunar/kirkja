extends Node

# GatewayServer on GameClient project
#note: this is a singleton!
#
# This is only active upon a login request, which
# calls ConnectToServer(). On positive results, then we
# connect to the GameServer.

var gateway_network : ENetMultiplayerPeer
var gateway_api : MultiplayerAPI
var ip := "127.0.0.1"
var port := 1910
var cert = load("res://Resources/Certificate/X509_Certificate.crt")

# these should have data only between GatewayServer connect and auth response:
var username : String
var password : String
var register_on_connect : bool = false


# this is called when login button pressed
func ConnectToServer(_username: String, _password: String, register: bool):
	gateway_network = ENetMultiplayerPeer.new()
	gateway_api = MultiplayerAPI.new()
	
	username = _username
	password = _password
	register_on_connect = register
	
	gateway_network.create_client(ip, port)
	gateway_network.connection_failed.connect(connection_failed)
	gateway_network.connection_succeeded.connect(connection_succeeded)
	gateway_network.host.dtls_client_setup(cert, ip, false) #TODO: false is for self signed
	
	get_tree().set_multiplayer(gateway_api, "/root/GatewayServer")
	multiplayer.set_multiplayer_peer(gateway_network)



func connection_failed():
	print ("Client connection to gateway failed!")
	get_node("/root/Client/LoginScreen").ConnectionFailed()


func connection_succeeded():
	print ("Client connection to gateway succeeded! client id: ", multiplayer.get_unique_id())
	if register_on_connect:
		RequestCreateAccount()
	else:
		RequestLogin()


#---------------------------- Logging in -----------------------------------

func RequestLogin():
	print ("calling GatewayServer to request login")
	#print("get_unique_id returns: ", custom_multiplayer.get_unique_id()) #this is game_client_id(?)
	rpc_id(1, "LoginRequest", username, password.sha256_text())
	username = ""
	password = ""


# this is called from GatewayServer
@rpc
func LoginRequestResponse(result: bool, game_client_id: int, token: String):
	print ("Auth result for ", game_client_id, ": ", result)
	print ("Token: ", token)
	if result == true:
		GameServer.token = token
		GameServer.ConnectToServer()
		get_node("/root/Client/LoginScreen").LoginSucceeded()
	else:
		print ("Incorrect login information")
		get_node("/root/Client/LoginScreen").LoginRejected()
	
	gateway_network.connection_failed.disconnect(connection_failed)
	gateway_network.connection_succeeded.disconnect(connection_succeeded)


#this function is run on GatewayServer, called from RequestLogin() above:
@rpc(any_peer) func LoginRequest(_username: String, _password: String): pass


#---------------------------- New Account Creation -----------------------------------

# note: these MUST sync up with messages on AuthenticationServer project!!
enum CREATEACCOUNT { Success=1, UserExists=2, AuthInternalError=3 }

# Called after pressing the "Register" button on login screen.
func RequestCreateAccount():
	print ("calling GatewayServer to request create new account")
	rpc_id(1, "CreateAccountRequest", username, password.sha256_text())
	username = ""
	password = ""

# This is implemented on GatewayServer.
@rpc(any_peer) func CreateAccountRequest(_username, _password): pass


# This is called from GatewayServer.
@rpc
func CreateAccountResponse(result: bool, message: int):
	print ("Create account response: ", result, ", message: ", message)
	var msg: String
	match message:
		CREATEACCOUNT.Success: msg = "Registered! Please log in."
		CREATEACCOUNT.UserExists: msg = "User exists."
		CREATEACCOUNT.AuthInternalError: msg = "Could not register, please tell devs to document errors better."
	get_node("/root/Client/LoginScreen").CreateAccountResults(result, msg)

