extends Node

# GameServer on GameClient
#note: this is a singleton!

var game_server_network := ENetMultiplayerPeer.new()
var ip := "127.0.0.1"
var port := 1909

var token : String # this gets generated originally by the auth server


func _ready():
	pass


#------------------------------------------------------------------
#------------------ Clock sync and Interpolation ------------------
#------------------------------------------------------------------

var client_clock := 0.0

var latency := 0.0  # approximated packet travel time between server and client
var delta_latency := 0.0 # latency and delta_latency are refreshed every 9 timer ping backs
var latency_array := []
var decimal_collector := 0.0


func _physics_process(delta):
	#TODO: this probably needs to be int to preserve millisecond accuracy when float precision gets low with high numbers
	client_clock += delta + delta_latency
	delta_latency = 0
	#---
#	client_clock += int(delta*1000) + delta_latency
#	delta_latency = 0
#	if decimal_collector >= 1.00:
#		client_clock += 1
#		decimal_collector -= 1.00


# Timer callback to request ping from GameServer.
# This is initialized upon server connection.
func RequestLatency():
	#print ("DetermineLatency...... host: ", game_server_network.host)
	if game_server_network.host != null:
		rpc_id(1, "LatencyRequest", Time.get_unix_time_from_system())

# This is implemented on GameServer
@rpc(any_peer) func LatencyRequest(_client_time): pass

# This is returned from GameServer, after RequestLatency().
@rpc
func LatencyResponse(client_time):
	latency_array.append((Time.get_unix_time_from_system() - client_time)/2)
	if latency_array.size() == 9:
		var total_latency := 0.0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size() -1, -1, -1):
			if latency_array[i] > (2*mid_point) and latency_array[i] > 20: # exclude outliers
				latency_array.remove_at(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print ("New Latency (ms): ", latency*1000, "  Delta latency (ms): ", delta_latency*1000)
		latency_array.clear()
		
		get_node("/root/Client/DebugOverlay").UpdateLatency(latency)


#------------------------------------------------------------
#------------------ Syncing player state --------------------
#------------------------------------------------------------

func SendPlayerState(player_state):
	#print ("player state: ", player_state)
	if game_server_network.host != null:
		rpc_id(1, "ReceivePlayerState", player_state)

# This is implemented on GameServer
@rpc(any_peer, unreliable)
func ReceivePlayerState(_player_state): pass


# This is called from GameServer
@rpc(unreliable)
func ReceiveWorldState(world_state):
	#print ("Received world state: ", world_state)
	get_node("/root/Client/World").UpdateWorldState(world_state)
	print("Server time: ", world_state.T, ",  client clock: ", client_clock, ",  diff: ", world_state.T - client_clock)


#------------------------------------------------------------
#------------------ Login and Verification ------------------
#------------------------------------------------------------

func ConnectToServer():
	print ("Attempting to connect to game server...")
	game_server_network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(game_server_network)
	
	game_server_network.connection_failed.connect(connection_failed)
	game_server_network.connection_succeeded.connect(connection_succeeded)
	game_server_network.server_disconnected.connect(server_disconnected)

	
func connection_failed():
	print ("GameServer Connection failed!")
	game_server_network.connection_failed.disconnect(connection_failed)
	game_server_network.connection_succeeded.disconnect(connection_succeeded)


func connection_succeeded():
	print ("GameServer Connection succeeded! client id: ", multiplayer.get_unique_id())
	
	rpc_id(1, "ServerTimeRequest", Time.get_unix_time_from_system()) # note this time is a float in 4.0
	
	# note: SceneTreeTimer doesn't do what we want currently: get_tree().create_timer(0.5).timeout.connect(RequestLatency)
	var timer = Timer.new()
	timer.name = "LatencyTimer"
	timer.autostart = true
	timer.wait_time = 0.5
	timer.timeout.connect(RequestLatency)
	self.add_child(timer)


func server_disconnected():
	print ("GameServer disconnected!")
	get_node("/root/Client/LoginScreen").GameServerDropped() #visible = true
	get_node("/root/Client/DebugOverlay").UpdateClientId(-1)
	get_node("LatencyTimer").queue_free()


# This is implemented on the GameServer
@rpc(any_peer) func ServerTimeRequest(_time): pass


# This is a time ping returned from GameServer right after initial network connected.
@rpc
func ServerTimeResponse(server_time, client_time):
	latency = (Time.get_unix_time_from_system() - client_time)/2
	client_clock = server_time + latency


# this is called from a GameServer
@rpc
func PlayerTokenRequest():
	print ("Got PlayerTokenRequest from GameServer, sending response")
	rpc_id(1, "PlayerTokenResponse", token)

# this is implemented on GameServer
@rpc(any_peer) func PlayerTokenResponse(_token: String): pass


# this is called from GameServer
@rpc
func VerificationResponseToClient(is_authorized):
	print ("GameServer says authorized: ", is_authorized)
	if is_authorized:
		get_node("/root/Client/LoginScreen").visible = false
		get_node("/root/Client/DebugOverlay").UpdateClientId(multiplayer.get_unique_id())
		print ("We have lift off!")
	else:
		print ("Login failed, please try again!")
		get_node("/root/Client/LoginScreen").LoginRejectedFromGameServer()


#------------------------------------------------------------
#------------------ Player Node Maintenance -----------------
#------------------------------------------------------------

@rpc
func DespawnPlayer(game_client_id):
	print ("GameServer says to despawn: ", game_client_id)
	get_node("/root/Client/World").DespawnPlayer(game_client_id)

@rpc
func SpawnNewPlayer(game_client_id: int, spawn_point: Vector2):
	print ("GameServer says to spawn player ", game_client_id, " at ", spawn_point)
	get_node("/root/Client/World").SpawnNewPlayer(game_client_id, spawn_point)


#------------------------------------------------------------
#------------------------ Testing ---------------------------
#------------------------------------------------------------

func RequestPlayerData(what: String, requestor: int):
	print("RequestPlayerData on client: ", what)
	
	rpc_id(1, "PlayerDataRequest", what, requestor)

## this is a stub, the true function is on the GameServer
@rpc(any_peer) func PlayerDataRequest(_what:String, _requestor:int): pass


# this is called by the GameServer
@rpc
func PlayerDataResponse(what:String, data, requestor:int):
	print("client received response: ", what, ", data: ", data, ", requestor: ", requestor)
	instance_from_id(requestor).DataReceived(what, data)

# FOR TESTING ONLY!
func DataReceived(what, data):
	print ("Data receieved at object: ", what, ": ", data)

