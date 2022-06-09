extends Node3D

@onready var game_server : GameServer = get_parent()


# Note, this will run 20 times a second
func _physics_process(_delta):
	for player in $Players.get_children():
		# update player positions
		var player_id = str(player.name).to_int()
		#print ("Update pos for player ", player_id)
		
		if player_id in game_server.packet_post:
			var player_pos = game_server.packet_post[player_id].P
			var player_rot = game_server.packet_post[player_id].R
			var player_mrot = game_server.packet_post[player_id].R2
			
			player.velocity = player_pos - player.global_transform.origin
			#player.move_and_slide()
			player.position = player_pos
			player.quaternion = player_rot
			player.get_node("PlayerMesh").quaternion = player_mrot
			
			game_server.packet_post[player_id].P = player.global_transform.origin
