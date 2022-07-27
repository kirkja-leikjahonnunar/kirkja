class_name ProximityButton
extends Area3D


var body_near

#func _process(_delta):
#	if body_near:
#		#TODO: this should be part of the character controller or some other singular input pipeline
#		if Input.is_action_just_pressed("char_use2"):
#			Use()

func Hover():
	pass


func Unhover():
	pass


func Use():
	pass


func _on_proximity_button_body_entered(body):
	print ("Body ", body.name, " entered ", name)
	body_near = body
	if body.has_method("AddProximityTrigger"): # is PlayerController:
		body.AddProximityTrigger(self)
	Hover()


func _on_proximity_button_body_exited(body):
	print ("Body ", body.name, " exited ", name)
	body_near = null
	if body.has_method("RemoveProximityTrigger"):
		body.RemoveProximityTrigger(self)
	Unhover()
