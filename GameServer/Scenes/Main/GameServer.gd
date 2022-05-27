extends Node
class_name GameServer


# GameServer on GameServer project
#note: this is a singleton!

@onready var server_player_scene := preload("res://Scenes/Instances/ServerPlayer.tscn")

var network := ENetMultiplayerPeer.new()
var port := 1909
var max_players := 100

# dictionary that has:
# packet_post[game_client_id] = { "P", "T" }
#  "P": player position
#  "T": cient time. THIS GETS REMOVED before being sent back out in SendWorldState()!!
var packet_post = {} # Note: player states are collected here from clients


var expected_tokens := ["aaoeuauaoueoa"]


@onready var player_verification_process : PlayerVerification = get_node("PlayerVerification") as PlayerVerification


func _ready():
	StartServer()


func StartServer():
	network.create_server(port, max_players)
	multiplayer.set_multiplayer_peer(network)
	print ("GameServer started!")
	
	network.peer_connected.connect(peer_connected)
	network.peer_disconnected.connect(peer_disconnected)


func peer_connected(game_client_id):
	print ("GameServer: client connected! ", game_client_id)
	await get_tree().process_frame
	player_verification_process.Start(game_client_id)


func peer_disconnected(game_client_id: int):
	print ("GameServer: client disconnected! ", game_client_id)
	#todo: probably need to store any unsaved data on the client's node
	if has_node(str(game_client_id)):
		get_node(str(game_client_id)).queue_free()
		packet_post.erase(game_client_id)
		rpc_id(0, "DespawnPlayer", game_client_id) # tell everyone this one's gone


#------------ Player Maintenance ----------------------

# This is implemented on GameClients when another one disconnects.
@rpc func DespawnPlayer(game_client_id): pass


#-------------- Testing random data retrieval -----------------

## This is called by any GameClient.
# requestor is an id internal to GameClient.
@rpc(any_peer)
func PlayerDataRequest(what:String, requestor:int):
	var game_client_id = multiplayer.get_remote_sender_id()
	
	if what == "GameTime":
		rpc_id(game_client_id, "PlayerDataResponse", what, "THE TIME IS NOW!!", requestor)
	else:
		# ...RETRIEVE DATA...
		print_debug("TODO: implement retrieve player data")
		var data = "STUFF"
		
		# send data back to client
		rpc_id(game_client_id, "PlayerDataResponse", what, data, requestor)


# this is implemented on GameClient
@rpc func PlayerDataResponse(_what:String, _data, _requestor:int): pass



#------------------------------------------------------------------------------
# Player Verification
#------------------------------------------------------------------------------
# Called from "PlayerVerification.gd".
func FetchPlayerToken(game_client_id):
	print ("Trying to call gameClient with PlayerTokenRequest, client id: ", game_client_id)
	print("GameServer currently has peers: ", multiplayer.get_peers())
	rpc_id(game_client_id, "PlayerTokenRequest") # RPC to GameClient.

# this is implemented on GameClient
@rpc func PlayerTokenRequest(): pass

# this is called from GameClient
@rpc(any_peer)
func PlayerTokenResponse(token: String):
	var game_client_id = multiplayer.get_remote_sender_id()
	print ("received token from game client: ", game_client_id)
	print ("  client token: ", token)
	player_verification_process.Verify(game_client_id, token)


# Called from PlayerVerification.Verify(), sends verification results to GameClient.
func VerificationResponse(game_client_id: int, is_authorized: bool, player_node):
	rpc_id(game_client_id, "VerificationResponseToClient", is_authorized)
	if is_authorized: # tell everyone there's a new birth
		rpc_id(0, "SpawnNewPlayer", game_client_id, player_node.position)

# This is implemented on GameClient.
@rpc func SpawnNewPlayer(_game_client_id: int, _spawn_point: Vector2): pass

# this is implemented on GameClient
@rpc func VerificationResponseToClient(_is_authorized): pass


#------------------------------------------------------------------------------
# Create player object
#------------------------------------------------------------------------------

# Called from PlayerVerification.Verify(). Returns new player node.
func CreatePlayerContainer(game_client_id):
	var new_player = server_player_scene.instantiate()
	new_player.name = str(game_client_id)
	get_node("../World/Players").add_child(new_player, true)
	new_player.position = Vector2(randf_range(50,400), randf_range(50,400))
	FillPlayerContainer(new_player)
	return new_player

# Fill new player with their last state, such as map/position, model, skin, color, inventory, etc
func FillPlayerContainer(_player_container):
	#player_container.player_stats = ServerData.test_data.Stats
	pass


#------------------------------------------------------------------------------
# Invalidate player tokens after 30 seconds.
#------------------------------------------------------------------------------

func _on_TokenExpiration_timeout():
	var current_time = Time.get_unix_time_from_system()
	var token_time
	
	if expected_tokens.size() == 0:
		pass
	else:
		for i in range(expected_tokens.size() -1, -1, -1):
			print ("Checking token: ", expected_tokens[i])
			#print ("  right(64): ", expected_tokens[i].right(64))
			#print ("  right(-64): ", expected_tokens[i].right(-64))
			token_time = expected_tokens[i].right(-64).to_int()
			if current_time - token_time >= 31:
				expected_tokens.remove_at(i)
				print("REMOVED expected_token: " + str(i))
	
	print("Expected Tokens:")
	print(expected_tokens)


#------------------------------------------------------------------------------
# Client/Server time syncing
#------------------------------------------------------------------------------

# This is called from GameClients right after server connected
@rpc(any_peer)
func ServerTimeRequest(client_time):
	var game_client_id = multiplayer.get_remote_sender_id()
	rpc_id(game_client_id, "ServerTimeResponse", Time.get_unix_time_from_system(), client_time)

# This is implemented on GameClient.
@rpc func ServerTimeResponse(_server_time, _client_time): pass

# This is Called from GameClient
@rpc(any_peer)
func LatencyRequest(client_time):
	var game_client_id = multiplayer.get_remote_sender_id()
	rpc_id(game_client_id, "LatencyResponse", client_time)

@rpc func LatencyResponse(client_time): pass


#------------------------------------------------------------------------------
# Player data syncing
#------------------------------------------------------------------------------

# See also StateProcessing.

# This is called frequently from GameClient. GameServer deals with it 20 times a second, and sends 
# updates back to GameClient with SendWorldState().
@rpc(any_peer, unreliable)
func ReceivePlayerState(player_state):
	var game_client_id = multiplayer.get_remote_sender_id()
	if packet_post.has(game_client_id):
		if packet_post[game_client_id]["T"] < player_state["T"]:
			packet_post[game_client_id] = player_state
	else:
		packet_post[game_client_id] = player_state


# This is called from StateProcessing._physics_process().
func SendWorldState(world_state):
	rpc_id(0, "ReceiveWorldState", world_state)

# This is implemented on GameClient
@rpc(unreliable) func ReceiveWorldState(_world_state): pass

