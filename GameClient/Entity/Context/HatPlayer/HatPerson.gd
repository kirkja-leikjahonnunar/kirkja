extends PlayerController


@export var min_time_scale = 3
@export var max_time_scale = 10

@onready var state_machine = $PlayerMesh/AnimationTree.get("parameters/playback")


# Speed will be 0 for idle, 1 for walk, up to 2 for full sprint.
func SetSpeed(speed):
	#super(speed)
	
	animation_tree["parameters/IdleWalkRun/BlendSpace1D/blend_position"] = speed
	animation_tree["parameters/IdleWalkRun/TimeScale/scale"] = max(min_time_scale, speed / 2.0 * (max_time_scale - min_time_scale) + min_time_scale)
	#get_tree().create_tween().tween_property(animation_tree, "parameters/IdleWalkRun/blend_position", speed, .25)


# called when a jump starts from the floor
func JumpStart():
	state_machine.travel("JumpStart")


# called when going from falling to on floor.
func JumpEnd():
	state_machine.travel("JumpEnd")

# called if we are falling, but it's not starting from jumping
func Falling():
	state_machine.travel("JumpIdle")

