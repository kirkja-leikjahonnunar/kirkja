extends CharacterBody3D
class_name Pip
# The pip is the same size as a voxel.( 0.1 m cubed)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var MouseSensitivity: float = 0.005 # For mouse velocity.
var MovementSpeed: float = 1.5 # m/s.

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera_3d: Camera3D = $CameraPivot/Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("char_strafe_left", "char_strafe_right", "char_forward", "char_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * MovementSpeed
		velocity.z = direction.z * MovementSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, MovementSpeed)
		velocity.z = move_toward(velocity.z, 0, MovementSpeed)
	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		camera_pivot.rotation.y -= event.relative.x * MouseSensitivity
		camera_pivot.rotation.x -= event.relative.y * MouseSensitivity
		
		print("Relative: ", event.relative)
		print("Velocity: ", event.velocity)
