extends CharacterBody3D

const ONE_G = 9.807 # m/s².
const MY_G = 40

@onready var PIVOT := $CameraPivot
@onready var SPEED_UI := $UI/PanelContainer/VBoxContainer/SpeedUI
@onready var VELOCITY_UI := $UI/PanelContainer/VBoxContainer/VelocityUI

@export var MouseSenesitivity: float = 0.005 # TODO: Doc magic number.

# m/s.
@export var IsGliding: bool = true # Use flying or sticky gravity. Magnetic stick?
@export var MaxSpeed: float = 5.0
@export var MinSpeed: float = 0.1
@export var AccelerationRate: float = 0.666
@export var BreakDecay: float = 0.95 # Damping.

var thrust: Vector3 # Thrust vector from the user's keyboard, mouse, or gamepad.
var gravity: Vector3 = Vector3.DOWN * ONE_G # Gravitational velocity vector can point toward other directions.
var using_rudder: bool = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Calculate the thrust
	#thrust = Vector3.ZERO
	
	if Input.is_action_pressed("char_forward"):
		thrust += -transform.basis.z * AccelerationRate
		
	if Input.is_action_pressed("char_backward"):
		thrust += transform.basis.z * AccelerationRate
		
	if Input.is_action_pressed("char_strafe_left"):
		thrust += -transform.basis.x * AccelerationRate
	if Input.is_action_pressed("char_strafe_right"):
		thrust += transform.basis.x * AccelerationRate
	if Input.is_action_pressed("char_jump"):
		velocity *= BreakDecay
	
	if Input.is_action_pressed("char_fly_up"):
		thrust += -transform.basis.y * AccelerationRate
	if Input.is_action_pressed("char_fly_down"):
		thrust += transform.basis.y * AccelerationRate


	# Orient the thrust around the player's y axis, so the [wsad] controls are relative to the viewport.
	#thrust = thrust.rotated(Vector3.UP, PIVOT.rotation.y)#.normalized()
	
	# Add player input.
	velocity += thrust
	
	# Clamp the velocity's magnitude according to the speed properties.
	if velocity.length() < MinSpeed:
		velocity = Vector3.ZERO
	elif velocity.length() > MaxSpeed:
		velocity = velocity.normalized() * MaxSpeed
	
	move_and_slide()
	
	# UI.
	var speed = velocity.length()
	SPEED_UI.text = "Speed: %s" % speed
	VELOCITY_UI.text = "Velocity: %s" % velocity


func _input(event):
	if event is InputEventMouseMotion:
		PIVOT.rotate_object_local(Vector3.RIGHT, event.get_relative().y * -MouseSenesitivity) # Pitch.
		if using_rudder:
			rotate_y(event.get_relative().x * -MouseSenesitivity) # Yaw.
		else:
			PIVOT.rotate_y(event.get_relative().x * -MouseSenesitivity) # Yaw.
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			using_rudder = true
		elif not event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			using_rudder = false
			
