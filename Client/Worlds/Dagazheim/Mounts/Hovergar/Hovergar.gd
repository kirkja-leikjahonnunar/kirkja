extends CharacterBody3D

const ONE_G = 9.807 # m/s².

@onready var PIVOT: Node3D = $CameraPivot
@onready var SPEED_UI: Label = $UI/PanelContainer/VBoxContainer/SpeedUI
@onready var VELOCITY_UI: Label = $UI/PanelContainer/VBoxContainer/VelocityUI

# Looks.
@onready var RUDDER_L: Node3D = $Looks/AttachRudderL/Rudder
@onready var RUDDER_R: Node3D = $Looks/AttachRudderR/Rudder

# Properties.
@export var InvertY: bool = false
@export var MouseSenesitivity: float = 0.005 # TODO: Doc magic number.
@export var MaxSpeed: float = 10.0
@export var MinSpeed: float = 0.05
@export var AccelerationRate: float = 0.15
@export var BreakDecay: float = 0.95 # Damping.
@export var MaxRoll: float = deg_to_rad(45)
@export var MaxPitch: float = deg_to_rad(20)

var thrust: Vector3 # Thrust vector from the user's keyboard, mouse, or gamepad.
#var gravity: Vector3 = Vector3.DOWN * ONE_G # Gravitational velocity vector can point toward other directions.
var using_rudder_l: bool = false
var using_rudder_r: bool = false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta):
	# Calculate the thrust
	thrust = Vector3.ZERO
	
	# Keyboard Thrusting.
	if Input.is_action_pressed("char_forward"):
		thrust += -transform.basis.z * AccelerationRate
	if Input.is_action_pressed("char_backward"):
		thrust += transform.basis.z * AccelerationRate
	if Input.is_action_pressed("char_strafe_left"):
		thrust += -transform.basis.x * AccelerationRate
	if Input.is_action_pressed("char_strafe_right"):
		thrust += transform.basis.x * AccelerationRate
	if Input.is_action_pressed("char_fly_up"):
		thrust += -transform.basis.y * AccelerationRate
	if Input.is_action_pressed("char_fly_down"):
		thrust += transform.basis.y * AccelerationRate
	
	# Air Breaking.
	if Input.is_action_pressed("char_jump"):
		velocity *= BreakDecay
	
	# Left Rudder.
	if Input.is_action_just_pressed("use_rudder_l"):
		RUDDER_L.SlideRudder(true)
		using_rudder_l = true
	if Input.is_action_just_released("use_rudder_l"):
		RUDDER_L.SlideRudder(false)
		using_rudder_l = false
	
	# Right Rudder.
	if Input.is_action_just_pressed("use_rudder_r"):
		RUDDER_R.SlideRudder(true)
		using_rudder_r = true
	if Input.is_action_just_released("use_rudder_r"):
		RUDDER_R.SlideRudder(false)
		using_rudder_r = false
	
	# Both rudders are down.
	if using_rudder_l and using_rudder_r:
		thrust += -transform.basis.z * AccelerationRate
		
	# Both rudders are up.
	if not using_rudder_l and not using_rudder_r:
		rotation.z = 0.0
		print("Rudderless.")
	
	# Orient the thrust around the player's y axis, so the [wsad] controls are relative to the viewport.
	#thrust = thrust.rotated(Vector3.UP, PIVOT.rotation.y)
	
	# Add player input to our velocity.
	velocity += thrust
	var damp = 2.0
#	rotation.x *=  damp * delta
#	clamp(rotation.x, deg_to_rad(-20), deg_to_rad(20))
#	velocity = velocity.rotated(Vector3.RIGHT, rotation.x)
	
	rotation.y +=  rotation.z * damp * delta
	velocity = velocity.rotated(Vector3.UP, rotation.z * damp * delta)
	
	#rotate_y(rotation.z * 0.03) # Turn our vessel in the direction we are rolling.
	#velocity = velocity.rotated(Vector3.UP, rotation.z * 0.03) # Update our heading.
	
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
	
	# TODO: Hopefully will be fixed soon.
	# https://github.com/godotengine/godot/issues/16352


func _input(event):
	if event is InputEventMouseMotion:
		var mouse_delta_x: float = event.get_relative().x * -MouseSenesitivity
		var mouse_delta_y: float = event.get_relative().y * -MouseSenesitivity
		
		if using_rudder_l or using_rudder_r:
			# Pitch around local coords.
			#rotate_object_local(transform.basis.x, mouse_delta_y / 2) # Pitch.
			
#			rotate_object_local(Vector3.RIGHT, mouse_delta_y / 2) # Pitch.
#			rotation.x = clamp(rotation.x, -MaxPitch, MaxPitch)
			
			#velocity = velocity.rotated(Vector3.RIGHT, mouse_delta_y) # Pitch.
			
			# Yaw around WORLD COORDS.
			#rotate_y(event.get_relative().x * -MouseSenesitivity)
#			if rotation.x < -MaxPitch:
			
			# Roll.
			rotate_object_local(Vector3.FORWARD, -mouse_delta_x / 2)
			rotation.z = clamp(rotation.z, -MaxRoll, MaxRoll)
			
			# Yaw.
			#rotate(Vector3.UP, rotation.z)
			#velocity = velocity.rotated(Vector3.UP, rotation.z)
			#print(rotation.z)
			
			#rotate(Vector3.UP, mouse_delta_x)
			#rotate_object_local(Vector3.UP, event.get_relative().x * -MouseSenesitivity)
			#velocity = velocity.rotated(Vector3.UP, mouse_delta_x)
		else:
			PIVOT.rotate_y(mouse_delta_x) # Yaw.
			PIVOT.rotate_object_local(Vector3.RIGHT, mouse_delta_y) # Pitch.
