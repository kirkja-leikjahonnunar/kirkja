extends Node

#AuthenticationServer on GatewayServer project
#note: this is a singleton!

var auth_network := ENetMultiplayerPeer.new()
var ip := "127.0.0.1"
var port := 1911 # of AuthenticationServer


func _ready():
	ConnectToServer()


func ConnectToServer():
	auth_network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(auth_network)
	
	auth_network.connection_failed.connect(connection_failed)
	auth_network.connection_succeeded.connect(connection_succeeded)
	auth_network.server_disconnected.connect(ServerDisconnected)


func connection_failed():
	print ("AuthenticateServer Connection failed!")


func connection_succeeded():
	print ("AuthenticateServer Connection succeeded!")
	
	# ping for debugging, gateway pings auth:
	#get_tree().create_timer(1.0).timeout.connect(PingAuthServer)

func ServerDisconnected():
	print ("Auth server disconnected. Oh no!")


#-------------------------- Player Authentication -------------------------------

# local function to initiate auth call
func AuthenticatePlayer(username: String, password: String, game_client_id: int):
	print("calling AuthenticatePlayer from GatewayServer to authenticate ", username)
	
	rpc_id(1, "RequestAuthentication", username, password, game_client_id)

# this is implemented on AuthenticationServer
@rpc(any_peer)
func RequestAuthentication(_username: String, _password: String, _game_client_id: int): pass


# This is returned from Authenticate server
@rpc
func AuthenticationResponse(result: bool, game_client_id: int, token: String):
	print("Auth result: ", result, " for ", game_client_id)
	print ("token: ", token)
	GatewayServer.ReturnLoginRequest(result, game_client_id, token)


#------------------------- New Account Creation ------------------------------------

func CreateAccount(game_client_id: int, username: String, password: String):
	print ("Calling auth server to create new account for ", username, ": ", password)
	rpc_id(1, "CreateAccountRequest", game_client_id, username, password)

# This is implemented on AuthenticationServer
@rpc(any_peer) func CreateAccountRequest(_game_client_id: int, _username: String, _password: String): pass

# This is called from AuthenticationServer.
@rpc
func CreateAccountResponse(result: bool, game_client_id: int, message: int):
	print ("Auth create account: ", result, ", message: ", message, ", client: ", game_client_id)
	GatewayServer.ReturnCreateAccountRequest(result, game_client_id, message)


##----------------------- Ping test -------------------------
#var last_ping_time := 0
#var do_pings := false
#
## for debugging rpc calls..
#func PingAuthServer():
#	do_pings = true
#	print ("Trying to ping auth server from GatewayServer...")
#	last_ping_time = Time.get_ticks_usec()
#	rpc_id(1, "PingAuthenticateServer")
#
#@rpc func PingAuthenticateServer(): pass
#@rpc func AuthPingResponse():
#	print ("Auth server ping returned! elapsed time (ms): ", (Time.get_ticks_usec()-last_ping_time)/1000.0)
#	last_ping_time = 0
#	if do_pings:
#		get_tree().create_timer(1.0).timeout.connect(PingAuthServer)
#
##------------ ping test: auth to gateway
#@rpc(any_peer)
#func PingGatewayServer():
#	var gateway_id = multiplayer.get_remote_sender_id()
#	print ("Sending ping response to gateway: ", gateway_id)
#	rpc_id(gateway_id, "GatewayPingResponse")
#@rpc func GatewayPingResponse(): pass

