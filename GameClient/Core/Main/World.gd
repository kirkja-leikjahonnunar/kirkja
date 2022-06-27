extends Node3D

@export var player_prefab : PackedScene
@export var other_player_prefab : PackedScene


#-------------------- Player init/destroy ------------------------------------

func SpawnNewPlayer(game_client_id: int, spawn_point: Vector3, spawn_rotation: Quaternion):
	print ("World needs to spawn player! at ", spawn_point)
	if get_tree().get_multiplayer().get_unique_id() == game_client_id:
		print ("Trying to spawn ourself as player...")
		var new_player = player_prefab.instantiate()
		new_player.position = spawn_point
		new_player.quaternion = spawn_rotation
		new_player.SetNameFromId(game_client_id)
		$Players.add_child(new_player)
		#new_player.set_physics_process(true) unnecessary?
		new_player.ConnectOptionsWindow(get_node("../ControlConfig")) #TODO: this should probably not be coupled to the CharacterController?
		new_player.main_camera = $MainCamera
		#TODO: if player despawns on server disconnect, we need to unconnect?
		$MainCamera.follow_proxy = new_player.GetCameraProxy()
	else:
		if not $Players.has_node(str(game_client_id)):
			var new_other_player = other_player_prefab.instantiate()
			new_other_player.SetNameFromId(game_client_id)
			new_other_player.position = spawn_point
			new_other_player.quaternion = spawn_rotation
			$Players.add_child(new_other_player)

func DespawnPlayer(game_client_id):
	print ("Despawning ", game_client_id)
	await get_tree().create_timer(0.2).timeout # pause to catch any spawn/despawn race condition
	if $Players.has_node(str(game_client_id)):
		get_node("Players/"+str(game_client_id)).queue_free()


func SpawnOfflinePlayer(spawn_point: Vector3, spawn_rotation: Quaternion):
	print ("Trying to spawn ourself as new offline player...")
	var new_player = player_prefab.instantiate()
	new_player.position = spawn_point
	new_player.quaternion = spawn_rotation
	new_player.SetNameFromId(-1)
	$Players.add_child(new_player)
	#new_player.set_physics_process(true) unnecessary?
	new_player.ConnectOptionsWindow(get_node("../ControlConfig")) #TODO: this should probably not be coupled to the CharacterController?
	new_player.main_camera = $MainCamera
	#TODO: if player despawns on server disconnect, we need to unconnect?
	$MainCamera.follow_proxy = new_player.GetCameraProxy()


#------------------ World State Syncing ----------------------

var last_world_state_time := 0.0
var interpolation_offset := .1 #100.0
var world_state_buffer = [] #array of world state dictionaries
# each world state currently contains:
#   T:       server time
#   players: array of player data: { P, R, R2 }
#   scene:   array of non-continuous scene events


func _physics_process(_delta):
	var render_time = GameServer.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2: # we have a future state, we need to interpolate
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) \
								/ float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].players.keys():
				#if str(player) == "T":
				#	continue
				#if player == multiplayer.get_unique_id():
				#	continue
				if not world_state_buffer[1].players.has(player):
					continue
				if $Players.has_node(str(player)):
					var new_position = world_state_buffer[1].players[player].P.lerp(world_state_buffer[2].players[player].P, interpolation_factor)
					var new_rotation = world_state_buffer[1].players[player].R.slerp(world_state_buffer[2].players[player].R, interpolation_factor)
					var new_rotation2 = world_state_buffer[1].players[player].R2.slerp(world_state_buffer[2].players[player].R2, interpolation_factor)
					#var new_position = world_state_buffer[2][player].P
#					print ("Finally updating player ",player,", pos: ", new_position,
#							", B.n: ", world_state_buffer.size(), 
#							", rt: ", render_time,
#							", t0: ", world_state_buffer[1]["T"],
#							", t1: ", world_state_buffer[2]["T"],
#							", tdiff: ",world_state_buffer[2]["T"] - world_state_buffer[1]["T"],
#							", lerp : ", interpolation_factor)
					$Players.get_node(str(player)).MovePlayer(new_position, new_rotation, new_rotation2)
				else:
					print("Spawing new other player ", player)
					SpawnNewPlayer(player, world_state_buffer[2].players[player].P, world_state_buffer[2].players[player].R)
		elif render_time > world_state_buffer[1].T: # we have no future world state, we need to extrapolate
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) \
								/ float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.0
			
			#var players = [ world_state_buffer[0].players, world_state_buffer[1].players ]
			
			for player in world_state_buffer[1].players.keys():
				#if str(player) == "T": # this is the server evaluation time
				#	continue
				#if player == multiplayer.get_unique_id():
				#	continue
				if not world_state_buffer[0].players.has(player):
					continue
				if $Players.has_node(str(player)):
					var position_delta = (world_state_buffer[1].players[player].P - world_state_buffer[0].players[player].P)
					var rotation_delta = world_state_buffer[0].players[player].R.inverse() * world_state_buffer[1].players[player].R
					var new_position = world_state_buffer[1].players[player].P + (position_delta * extrapolation_factor)
					var new_rotation = world_state_buffer[1].players[player].R.slerp(world_state_buffer[1].players[player].R * rotation_delta, extrapolation_factor)
					var new_rotation2 = world_state_buffer[1].players[player].R2 #FIXME .slerp(world_state_buffer[1].players[player].R * rotation_delta, extrapolation_factor)
					$Players.get_node(str(player)).MovePlayer(new_position, new_rotation, new_rotation2)
				else:
					print("Spawing new other player ", player)
					SpawnNewPlayer(player, world_state_buffer[1].players[player].P, world_state_buffer[1].players[player].R)
			


func UpdateWorldState(world_state):
	#print ("Updating world state: ", world_state)
	get_node("/root/Client/DebugOverlay").UpdateWorldState(world_state)
	#print ("Got world state: ", world_state)
	if world_state.T > last_world_state_time:
		last_world_state_time = world_state.T
		world_state_buffer.append(world_state)
