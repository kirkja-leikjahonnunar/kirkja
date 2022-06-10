#
# Exterior torroidal gravity area.
# Assumes the torus is sitting in the x-z axis, and (currently) assumes it is not stretched
#

extends Area3D

@export var gravity_weight := 1.0
@export var major_radius := -1.0 # -1 means use have the x size
@export var align_player := true # true if the player controller should align to the computed gravity direction

# Called when the node enters the scene tree for the first time.
func _ready():
	if major_radius == -1: # compute based on collision shape bounds
		var shape : CollisionShape3D = $CollisionShape3D
		major_radius = shape.shape.size.x/2
	print ("setting up exterior torroidal gravity with major radius: ", major_radius)



var global_gravity_dir : Vector3
var local_gravity_distance : float

func UpdateGravityDirection(world_pos : Vector3):
	var local_pos : Vector3 = global_transform.inverse() * world_pos
	var v : Vector3 = Vector3(local_pos.x, 0, local_pos.z,)
	var vlen = v.length()
	if vlen != 0: v /= vlen
	
	if vlen < major_radius:
		var nearest_on_ring : Vector3 = major_radius * v
		v = nearest_on_ring - local_pos
		local_gravity_distance = v.length() 
		if local_gravity_distance != 0:
			global_gravity_dir = v / local_gravity_distance
		global_gravity_dir = global_transform.basis * global_gravity_dir
	else: # normal gravity, but reverse for y < 0
		local_gravity_distance = local_pos.y
		if local_pos.y < 0:
			global_gravity_dir = global_transform.basis * Vector3(0,1,0) # - global_transform.origin
		else :
			global_gravity_dir = global_transform.basis * Vector3(0,-1,0) # - global_transform.origin
	#print ("gpos: ", world_pos, ", lpos: ", local_pos, ", grav dir: ", global_gravity_dir)
	return global_gravity_dir


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta):
#	pass



var player_in_count := 0

func _on_gravity_area_body_entered(body):
	print ("Body entered ", name, ": ", body.name)
	if body is CharacterController:
		player_in_count += 1
		body.EnteredGravityArea(self)


func _on_gravity_area_body_exited(body):
	print ("Body exited ", name, ": ", body.name)
	if body is CharacterController:
		player_in_count -= 1
		body.ExitedGravityArea(self)

