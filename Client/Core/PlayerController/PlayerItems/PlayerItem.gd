class_name PlayerItem
extends Node3D

# WORK IN PROGRESS!
# 
# PlayerItem are meant to be items that can be held, whether tools, handleable objects, flashlights, guns, etc.

enum ItemLocation { LeftHand, RightHand, Hat, HoverFollow, BackPack, Pendant }


# Perform an action. Return true if action happens, else false for action is not handled by this object.
func Action1() -> bool:
	return false


