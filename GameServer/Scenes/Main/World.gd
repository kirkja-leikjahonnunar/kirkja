extends Node2D

@onready var game_server : GameServer = get_parent()


func _physics_process(_delta):
	for player in $Players.get_children():
		# update player positions
		var player_id = str(player.name).to_int()
		#print ("Update pos for player ", player_id)
		
		if player_id in game_server.packet_post:
			var player_pos = game_server.packet_post[player_id].P 
			
			player.velocity = player_pos - player.global_transform.origin
			#player.move_and_slide()
			player.position = player_pos
			
			game_server.packet_post[player_id].P = player.global_transform.origin
