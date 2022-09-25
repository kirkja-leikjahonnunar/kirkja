extends CharacterBody3D

const ONE_G = 9.807 # m/s².
const MY_G = 40

@onready var PIVOT: Node3D = $CameraPivot
@onready var SPEED_UI: Label = $UI/PanelContainer/VBoxContainer/SpeedUI
@onready var VELOCITY_UI: Label = $UI/PanelContainer/VBoxContainer/VelocityUI
@onready var EXAUST_L := $Looks/LeftFender2/ExaustL
@onready var EXAUST_R := $Looks/RightFender2/ExaustR


#@export var IsGliding: bool = true # Use flying or sticky gravity. Magnetic stick?
@export var InvertY: bool
@export var MouseSenesitivity: float = 0.005 # TODO: Doc magic number.
@export var MaxSpeed: float = 10.0
@export var MinSpeed: float = 0.05
@export var AccelerationRate: float = 0.15
@export var BreakDecay: float = 0.95 # Damping.
@export var MaxRoll: float = deg_to_rad(45)
@export var MaxPitch: float = deg_to_rad(45)

var thrust: Vector3 # Thrust vector from the user's keyboard, mouse, or gamepad.
var gravity: Vector3 = Vector3.DOWN * ONE_G # Gravitational velocity vector can point toward other directions.
var using_rudder: bool


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
	
	# Mouse Stearing.
	if Input.is_action_just_pressed("use_rudder_l") or Input.is_action_just_pressed("use_rudder_r"):
		using_rudder = true
	if not Input.is_action_pressed("use_rudder_l") and not Input.is_action_pressed("use_rudder_r"):
		using_rudder = false
		
#		var tween = get_tree().create_tween()
#		tween.tween_property(self, "rotation.z", 0.0, 1.0)
#		tween.tween_property($Sprite, "scale", Vector2(), 1)
#		tween.tween_callback($Sprite.queue_free)

	
	# Orient the thrust around the player's y axis, so the [wsad] controls are relative to the viewport.
	#thrust = thrust.rotated(Vector3.UP, PIVOT.rotation.y)
	
	# Add player input.
	velocity += thrust
	
	# Clamp the velocity's magnitude according to the speed properties.
	if velocity.length() < MinSpeed:
		velocity = Vector3.ZERO
		EXAUST_L.emitting = false
		EXAUST_R.emitting = false
	elif velocity.length() > MaxSpeed:
		velocity = velocity.normalized() * MaxSpeed
	else:
		EXAUST_L.emitting = true
		EXAUST_R.emitting = true
	
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
		
		if using_rudder:
			# Pitch around local coords.
			#rotate_object_local(Vector3.RIGHT, mouse_delta_y) # Pitch.
			#velocity = velocity.rotated(Vector3.RIGHT, mouse_delta_y) # Pitch.
			
			# Yaw around WORLD COORDS.
			#rotate_y(event.get_relative().x * -MouseSenesitivity)
#			if rotation.x < -MaxPitch:
			
			
			rotate_object_local(Vector3.FORWARD, -mouse_delta_x / 2) # Roll
			rotation.z = clamp(rotation.z, -MaxRoll, MaxRoll)
			
			rotate(Vector3.UP, mouse_delta_x)
			#rotate_object_local(Vector3.UP, event.get_relative().x * -MouseSenesitivity)
			velocity = velocity.rotated(Vector3.UP, mouse_delta_x)
		else:
			PIVOT.rotate_y(mouse_delta_x) # Yaw.
			PIVOT.rotate_object_local(Vector3.RIGHT, mouse_delta_y) # Pitch.
