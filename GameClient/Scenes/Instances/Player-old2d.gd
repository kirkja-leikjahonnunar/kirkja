extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var player_state


# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = 0 #ProjectSettings.get_setting("physics/2d/default_gravity")


func _ready():
	set_physics_process(false) #hack: something to do with main menu?


func _physics_process(delta):
	HandleMovement(delta)
	DefinePlayerState()


func DefinePlayerState():
	#TODO: probably need GameServer.client_clock instead of sys time here:
	player_state = { "T": GameServer.client_clock, "P": global_transform.origin }
	#player_state = { "T": Time.get_ticks_msec(), "P": global_transform.origin }
	GameServer.SendPlayerState(player_state)


func HandleMovement(delta):
	var input_blocked := (get_viewport().gui_get_focus_owner() != null)
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if not input_blocked and Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down") if not input_blocked else Vector2(0,0)
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2(), SPEED)

	move_and_slide()


func _on_player_input_event(_viewport, _event, _shape_idx):
	pass
	#if event is InputEventMouseButton:
	#	print ("Player input event")

func SetNameFromId(new_name: int):
	name = str(new_name)
	$Sprite2D/Name.text = name


func MovePlayer(new_position):
	print ("MovePlayer, old: ", position, ", new: ", new_position, ", diff: ", new_position - position)
	#set_position(new_position)

