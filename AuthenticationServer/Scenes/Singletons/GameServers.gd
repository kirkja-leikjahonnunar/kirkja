extends Node

var gateway_network : ENetMultiplayerPeer
var gateway_api : MultiplayerAPI
var max_servers = 50
var port := 1912

var gameserverlist := {}

func _ready():
	StartServer()

#func _process(_delta: float):
#	if get_custom_multiplayer() == null:
#		return
#	if not custom_multiplayer.has_multiplayer_peer():
#		return
#	custom_multiplayer.poll()



func StartServer():
	gateway_network = ENetMultiplayerPeer.new()
	gateway_api = MultiplayerAPI.new()
	
	gateway_network.create_server(port, max_servers)
	get_tree().set_multiplayer(gateway_api, "/root/GameServers")
	#set_custom_multiplayer(gateway_api)
	#custom_multiplayer.set_root_path("/root/GameServers")
	#custom_multiplayer.set_multiplayer_peer(gateway_network)
	multiplayer.set_multiplayer_peer(gateway_network)
	print ("GameServer hub started!")
	
	gateway_network.peer_connected.connect(peer_connected)
	gateway_network.peer_disconnected.connect(peer_disconnected)


func peer_connected(game_server_id):
	print ("GameServer connected to GameServers hub: ", game_server_id)
	gameserverlist["GameServer"+str(gameserverlist.size()+1)] = game_server_id


func peer_disconnected(game_server_id):
	print ("GameServer disconnected to GameServers hub: ", game_server_id)
	for key in gameserverlist:
		if gameserverlist[key] == game_server_id:
			gameserverlist.erase(key)


# Send a token to the gameserver. The GameServer will check this token against one that a GameClient
# tries to connect to the GameServer with.
func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	print ("Auth server sending token to GameServer: ", token)
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)

# this is implemented on the GameServer
@rpc func ReceiveLoginToken(_token): pass

