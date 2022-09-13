class_name PlayerContext
extends Node


# Top level container for most general player state. Handles inhabiting new contexts.



#--------------------------- Body hopping -----------------------------------

var pending_player_context = null

func Inhabit(new_context):
	if pending_player_context:
		print ("cannot inhabit ", new_context.name, ", pending on ", pending_player_context.name)
		return
	print ("....trying to inhabit ", new_context.name)
	
	#-------- old model needs to be:
	# - highlightable if not being removed
	# - optionally removed
	var old_player_context = get_parent()
	old_player_context.remove_child(self)
	new_context.add_child(self)
	GameGlobals.current_player_object = new_context
	
#	# we need this to later orient new model to orientation of old model
#	var target_global_basis = old_player_context.global_transform.basis
#
#	# reparent old model
#	var _tr = old_player_context.global_transform
#	player_model_parent.remove_child(old_player_context)
#	get_parent().add_child(old_player_model)
#	old_player_model.global_transform = _tr
#	player_mesh = null
	
	old_player_context.active = false
	new_context.active = true
	print ("new context collision_layer: ", new_context.collision_layer)
	print ("new context collision_mask: ", new_context.collision_mask)
	
	# get rid of the old model if we have to
	if old_player_context.persistent_shell:
		# old player model gets abandonded and just sits in the world
		old_player_context.SetAsUninhabited()
	else:
		old_player_context.Deresolution()
	
	new_context.SetAsInhabited()
	
	#--------- new model:
	# - must dehighlight
	# - must be lerped to by player controller
	# - reparent after lerp
	#pending_player_context = new_context
	if GameGlobals.main_camera:
		GameGlobals.main_camera.follow_proxy = new_context.GetCameraProxy()
	
	#TODO: need to create a temporary tracking object to smoothly transition the camera to a new target
#	var tween : Tween = get_tree().create_tween()
#	tween.tween_property(self, "global_position", object.global_position, 0.15) #.finished.connect(ReparentNewModel)
#
#	object.SetAsInhabited()
#	#tween = get_tree().create_tween()
#	tween.tween_property(pending_player_model, "global_transform:basis", target_global_basis, 0.15).finished.connect(ReparentNewModel)


## Callback to finish inhabiting.
#func ReparentNewModel():
#	print ("finishing inhabit of ", pending_player_model.name)
#	var gtr = pending_player_model.global_transform
#	pending_player_model.get_parent().remove_child(pending_player_model)
#	player_model_parent.add_child(pending_player_model)
#	player_mesh = pending_player_model
#	pending_player_model.global_transform = gtr
#	pending_player_model.SetAsInhabited()
#	proximity_areas.erase(pending_player_model.get_node("InhabitableTrigger"))
#	pending_player_model = null


#--------------------- Network sync helpers ---------------------------------

# This needs to be called from _physics_process
func DefinePlayerState():
	var player = get_parent()
	var player_state = { "T": GameServer.client_clock, 
						"P": player.global_transform.origin,
						"R": player.global_transform.basis.get_rotation_quaternion(),
						"R2": player.player_model_parent.basis.get_rotation_quaternion()
						}
	GameServer.SendPlayerState(player_state)


func SetNameFromId(game_client_id):
	name = str(game_client_id)
	get_node("../Name").text = name
	#$Name.text = name


#TODO: this might be used if all collision processing is done on server
func MovePlayer(_pos, _rot, _rot2):
	pass
	#global_transform.origin = pos
	#global_transform.basis = Basis(rot)



