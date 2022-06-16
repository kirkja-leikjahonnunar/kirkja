extends Node


# This will be:
#  "players": a copy of GameServer.packet_post with time stamps removed
#  "T":       server time
#  "scene":   array of non-continuous scene events
#  "other_stuff": ...tbd, like npcs and other moving items
var world_state := {}

# This happens 20 times a second
func _physics_process(_delta):
	if not get_parent().packet_post.is_empty():
		var players_data = get_parent().packet_post.duplicate(true)
		world_state["players"] = players_data
		for player in players_data.keys(): #TODO: is there more efficient looping?
			players_data[player].erase("T") # removes individual client times
		
		world_state["T"] = Time.get_unix_time_from_system() # adding a single Server time to send back to clients
		
		get_parent().SendWorldState(world_state)
	
	#TODO: get_parent().SendSceneEvents():
