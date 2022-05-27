extends Node

var network := ENetMultiplayerPeer.new()
var port := 1911
var max_servers := 5


func _ready():
	start_server()


func start_server():
	network.create_server(port, max_servers)
	
	multiplayer.set_multiplayer_peer(network)
	
	print ("Authentication Server started!")
	
	#network.connect("peer_connected", peer_connected, [])
	network.peer_connected.connect(peer_connected)
	network.peer_disconnected.connect(peer_disconnected)
	
	#print("peer id: "+network.)

#var gateway_id # we only have this global to test pinging
func peer_connected(new_gateway_id):
	print ("Gateway " + str(new_gateway_id) + " Connected!")
	# ping for debugging, auth to gateway:
	#gateway_id = new_gateway_id
	#get_tree().create_timer(1.0).timeout.connect(DoPingGatewayServer)


func peer_disconnected(old_gateway_id):
	print ("Gateway " + str(old_gateway_id) + " Disconnected!")



# called from GatewayServer
@rpc(any_peer)
func RequestAuthentication(username:String, password:String, game_client_id: int):
	print("AuthenticatePlayer on AuthenticationServer: ", username, ": ", password)
	var from_gateway_id = multiplayer.get_remote_sender_id()
	var result := false
	
	var token := "" 
	var hashed_password := ""
	
	if not PlayerData.HasPlayer(username):
		print ("Unknown user ", username)
		result = false
	else:
		var user = PlayerData.UserData(username)
		var salt = user.salt
		hashed_password = GenerateHashedPassword(password, salt)
		
		if hashed_password != user.password:
			print ("Incorrect password!")
			result = false
		else:
			print ("Successful authentication for ", username)
			result = true
			
			randomize()
			token = str(randi()).sha256_text() + str(int(Time.get_unix_time_from_system()))
			print ("token generated: ", token)
			
			var gameserver = "GameServer1" #TODO: replace with proper load balance selection for server
			GameServers.DistributeLoginToken(token, gameserver)
	
	print("sending auth response for "+username, ", result: ", result, " to client: ", game_client_id)
	rpc_id(from_gateway_id, "AuthenticationResponse", result, game_client_id, token) #ultimately goes to client


# these are stubs, the real functions are on client side
#@rpc(any_peer) func PlayerDataResponse(what:String, requestor:int): pass
@rpc(any_peer) func AuthenticationResponse(_result: bool, _player_id: int, _token:String):
	pass #sends to GatewayServer


#------------------  Acount creation ---------------------------------------

# note: these MUST sync up with messages on GameClient project!!
enum CREATEACCOUNT { Success=1, UserExists=2, AuthInternalError=3 }

# This is called from GatewayServer
@rpc(any_peer)
func CreateAccountRequest(game_client_id: int, username: String, password: String):
	var gateway_id = multiplayer.get_remote_sender_id()
	var result
	var message
	if PlayerData.HasPlayer(username):
		result = false
		message = CREATEACCOUNT.UserExists
	else:
		result = true
		message = CREATEACCOUNT.Success
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		var success = PlayerData.SetUserPassword(username, hashed_password, salt, true)
		if not success:
			result = false
			message = CREATEACCOUNT.AuthInternalError
	
	if result == true:
		print ("Account created for ", username)
	rpc_id(gateway_id, "CreateAccountResponse", result, game_client_id, message)

# This is implemented on GatewayServer
@rpc func CreateAccountResponse(_result, _game_client_id, _message): pass

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	print ("Salt: ", salt)
	return salt

func GenerateHashedPassword(password, salt):
	var hashed_password = password
	var rounds = pow(2,3)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text() #TODO: replace this with a "slow" hashing function instead
		rounds -= 1
	return hashed_password


##---------------- Ping test ----------------------------
#
## for debugging rpc calls: gateway to auth..
#
#@rpc(any_peer)
#func PingAuthenticateServer():
#	var from_gateway_id = multiplayer.get_remote_sender_id()
#	print ("Sending ping response to gateway: ", from_gateway_id)
#	rpc_id(from_gateway_id, "AuthPingResponse")
#@rpc func AuthPingResponse(): pass
#
#
##----------------------- Ping test: auth ping gateway -------------------------
#var last_gateway_ping_time := 0
#var do_gateway_pings := false
#
## for debugging rpc calls..
#func DoPingGatewayServer():
#	do_gateway_pings = true
#	last_gateway_ping_time = Time.get_ticks_usec()
#	#var gateway_id = multiplayer.get_remote_sender_id()
#	print ("Trying to ping GatewayServer from auth server to gateway: ",gateway_id,"...")
#	rpc_id(gateway_id, "PingGatewayServer")
#
#@rpc func PingGatewayServer(): pass
#@rpc(any_peer) func GatewayPingResponse():
#	print ("Gateway server ping returned! elapsed time (ms): ", (Time.get_ticks_usec()-last_gateway_ping_time)/1000.0)
#	last_gateway_ping_time = 0
#	if do_gateway_pings:
#		#var gateway_id = multiplayer.get_remote_sender_id()
#		get_tree().create_timer(1.0).timeout.connect(DoPingGatewayServer)


