extends Node3D


# Base class for visual part of players.


# Whether this model sticks around after player goes on to inhabit something else.
@export var persistent_shell := true


# Stub for custom camera placements.
func GetCameraPlacements() -> CameraPlacements: return null


# Return the bounding box of the player at rest.
func GetRestAABB() -> AABB: return AABB()


# Whether this mesh as various things implemented on it, such as "walk", or "climb".
func HasFeature(feature) -> bool:
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
