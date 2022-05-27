class_name ProximityButton
extends Area3D


var body_near

func _process(_delta):
	if body_near:
		#TODO: this should be part of the character controller, else too much process
		if Input.is_action_just_pressed("char_use2"):
			Use()

func Hover():
	pass


func Unhover():
	pass


func Use():
	pass


func _on_proximity_button_body_entered(body):
	print ("Body ", body.name, " entered ", name)
	body_near = body
	Hover()


func _on_proximity_button_body_exited(body):
	print ("Body ", body.name, " exited ", name)
	body_near = null
	Unhover()
