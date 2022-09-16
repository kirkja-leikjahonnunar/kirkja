extends Area3D

var velocity: Vector3 = Vector3(0.0, 0.0, 5.0)

func _process(delta):
	position += velocity * delta
	rotate_x(45.0 * delta)
