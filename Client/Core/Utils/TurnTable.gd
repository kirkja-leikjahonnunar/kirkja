extends Node3D

var degree_amount: float = deg_to_rad(45)

func _process(delta):
	rotate(Vector3.UP, degree_amount * delta)
