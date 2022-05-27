extends Node
class_name PlayerVerification


@onready var game_server = get_parent()


# Waiting room for connected GameClients.
# GatewayServer sends a token to GameClient, which sends it here for verification.
# The token might take a while to get to the server from both routes.
var awaiting_verification = {} 


func Start(game_client_id):
	awaiting_verification[game_client_id] = { "Timestamp": Time.get_unix_time_from_system() }
	game_server.FetchPlayerToken(game_client_id)
	print(awaiting_verification, "________________")



#------------------------------------------------------------------------------
# Verify the player_token a GameClient submits against tokens recieved
# from the Authentication server.
#------------------------------------------------------------------------------

# This is called when GameClient sends PlayerTokenResponse
func Verify(game_client_id, player_token):
	var is_authorized: bool = false
	var new_player_node = null
	
	# Try to verify for 30 seconds.
	while Time.get_unix_time_from_system() - player_token.right(-64).to_int() <= 30:
		
		# Grant access to the player, unless the internet broke.
		if game_server.expected_tokens.has(player_token):
			print ("Client is verified, hooray!")
			is_authorized = true
			awaiting_verification.erase(game_client_id)
			game_server.expected_tokens.erase(player_token)
			new_player_node = game_server.CreatePlayer(game_client_id)
			break
		else:
			print ("Player not verified yet, trying again in 2 seconds...")
			# Wait 2 seconds before, trying again (provides 15 attempts).
			await get_tree().create_timer(2).timeout
	
	# Notify client of results of verification process
	game_server.VerificationResponse(game_client_id, is_authorized, new_player_node)
	
	# Make sure people are disconnected.
	# Could be dodgy behaviour, or an internet hickup.
	if is_authorized == false:
		awaiting_verification.erase(game_client_id)
		game_server.network.get_peer(game_client_id).peer_disconnect_later()


func _on_verification_expiration_timeout():
	var current_time = Time.get_unix_time_from_system()
	var start_time
	if awaiting_verification.size() == 0:
		pass
	else:
		for key in awaiting_verification.keys():
			start_time = awaiting_verification[key].Timestamp
			if current_time - start_time >= 10:
				awaiting_verification.erase(key)
				var connected_peers = Array(multiplayer.get_peers())
				if connected_peers.has(key):
					game_server.VerificationResponse(key, false)
					#TODO: check that net sends before being disconnected:
					game_server.network.get_peer(key).peer_disconnect()
	print("After verification timeout, still Awaiting verification:")
	print(awaiting_verification)
