extends Node


var world_state := {}

# This happens 20 times a second
func _physics_process(_delta):
	if not get_parent().packet_post.is_empty():
		world_state = get_parent().packet_post.duplicate(true)
		for player in world_state.keys(): #TODO: is there more efficient looping?
			world_state[player].erase("T") # removes individual client times
		
		#ONLY WORKS WITH SYNCED TIME: world_state["T"] = Time.get_ticks_msec() # adding a single Server time to send back to clients
		world_state["T"] = Time.get_unix_time_from_system() # adding a single Server time to send back to clients
		
		get_parent().SendWorldState(world_state)
