extends Node

# GatewayServer on GatewayServer project
#note: this is a singleton!

var network := ENetMultiplayerPeer.new()
var gateway_api = MultiplayerAPI.new()
var port := 1910
var max_players := 100
var cert = load("res://Certificate/X509_Certificate.crt")
var key = load("res://Certificate/X509_Key.key")


func _ready():
	StartServer()


func StartServer():
	network.create_server(port, max_players)
	network.host.dtls_server_setup(key, cert)
	
	get_tree().set_multiplayer(gateway_api, "/root/GatewayServer")
	multiplayer.set_multiplayer_peer(network)
	print ("Gateway server started!")
	
	network.peer_connected.connect(peer_connected)
	network.peer_disconnected.connect(peer_disconnected)


func peer_connected(game_client_id):
	print ("GameClient connected to GatewayServer! player_id: ", game_client_id)


func peer_disconnected(game_client_id):
	print ("GameClient disconnected from GatewayServer! player_id: ", game_client_id)


#--------------------------- Logging in ------------------------------

# this is called from GameClient
@rpc(any_peer)
func LoginRequest(username: String, password: String):
	print("LoginRequest on GatewayServer with: ", username, ": ", password)
	
	var game_client_id = multiplayer.get_remote_sender_id()
	print ("game_client_id (remote sender id) at LoginRequest: ", game_client_id)
	AuthenticationServer.AuthenticatePlayer(username, password, game_client_id)


# this local func is called after Auth server returns results
func ReturnLoginRequest(result: bool, game_client_id: int, token: String):
	print ("GatewayServer ReturnLoginRequest ",result,"... send to: ", game_client_id)
	rpc_id(game_client_id, "LoginRequestResponse", result, game_client_id, token) # func on client 
	
	network.get_peer(game_client_id).peer_disconnect_later()

# this function is implemented on GameClient
@rpc(any_peer) func LoginRequestResponse(_result: bool, _game_client_id: int, _token: String): pass


#--------------------------- New account creation ------------------------------

# This is called from GameClient
@rpc(any_peer)
func CreateAccountRequest(username: String, password: String):
	var game_client_id = multiplayer.get_remote_sender_id()
	AuthenticationServer.CreateAccount(game_client_id, username, password)

# Called when AuthenticationServer oks the account creation.
func ReturnCreateAccountRequest(result: bool, game_client_id: int, message: int):
	rpc_id(game_client_id, "CreateAccountResponse", result, message)
	network.get_peer(game_client_id).peer_disconnect_later()

# This is implemented on GameClient.
@rpc func CreateAccountResponse(_result, _message): pass

