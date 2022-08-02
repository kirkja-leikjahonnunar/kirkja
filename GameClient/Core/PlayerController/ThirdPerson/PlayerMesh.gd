class_name PlayerMesh
extends Node3D


# Base class for visual part of players.

# Some standard animation connections
@export var animation_tree: AnimationTree


# Whether this model sticks around after player goes on to inhabit something else.
@export var persistent_shell := true


# Stub for custom camera placements.
func GetCameraPlacements() -> CameraPlacements: return null


# Return the bounding box of the player at rest.
func GetRestAABB() -> AABB: return AABB()


# Whether this mesh as various things implemented on it, such as "walk", or "climb".
func HasFeature(_feature) -> bool:
	return false


func SetAsInhabited():
	if has_node("InhabitableTrigger"):
		var node = get_node("InhabitableTrigger")
		node.SetUninhabitable()

func SetAsUninhabited():
	if has_node("InhabitableTrigger"):
		var node = get_node("InhabitableTrigger")
		node.SetInhabitable()

# Make the model disappear, and remove from tree
func Deresolution():
	print ("removing model ", name)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector3(0, 0, 0), 0.15).finished.connect(Finalize)
	
func Finalize():
	queue_free()


#--------------------------- Animation syncing ----------------------------

# Speed will be 0 for idle, 1 for walk, up to 2 for full sprint.
func SetSpeed(speed):
	#print ("Move speed: ", value)
	if animation_tree:
		animation_tree["parameters/IdleWalkRun/blend_position"] = speed
		#get_tree().create_tween().tween_property(animation_tree, "parameters/IdleWalkRun/blend_position", speed, .25)

# called when a jump starts from the floor
func JumpStart():
	pass

# called when going from falling to on floor.
func JumpEnd():
	pass

# called if we are falling, but it's not starting from jumping
func Falling():
	pass

