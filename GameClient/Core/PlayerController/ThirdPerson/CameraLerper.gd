#
# This camera lerps to camera targets defined by various other things,
# like a player's camera rig or scene poi cameras.
#

extends Camera3D


@export var FollowProxy : NodePath
@onready var follow_proxy = get_node(FollowProxy) if not FollowProxy.is_empty() else null

@export var lerp_speed := 30
@export var show_target_indicator := false


# Called when the node enters the scene tree for the first time.
func _ready():
	GameGlobals.main_camera = self
	
	if follow_proxy != null:
		if follow_proxy.has_method("GetCameraProxy"):
			follow_proxy = follow_proxy.GetCameraProxy()
	elif follow_proxy == null && has_node("../Player"):
		follow_proxy = get_node("../Player").GetCameraProxy()
	elif GameGlobals.current_player_object != null:
		follow_proxy = GameGlobals.current_player_object.GetCameraProxy()
	
	if follow_proxy == null:
		#follow_proxy = self # assume we will assign this to player's proxy later
		set_physics_process(false)
		call_deferred("PollForPlayer")


func PollForPlayer():
#	if GameGlobals.current_player_object != null:
#		follow_proxy = GameGlobals.current_player_object.GetCameraProxy()
#		set_physics_process(true)
#	else:
#		call_deferred("PollForPlayer") # *** this causes crash?
	
	while GameGlobals.current_player_object == null:
		print ("polling for player")
		await get_tree().physics_frame
	
	follow_proxy = GameGlobals.current_player_object.GetCameraProxy()
	set_physics_process(true)
	


func _physics_process(delta):
	global_transform = global_transform.interpolate_with(follow_proxy.global_transform, lerp_speed*delta)

func _process(_delta):
	if show_target_indicator and $SelectorCast.is_colliding():
		$Indicator/TargetIndicator.global_transform.origin = $SelectorCast.get_collision_point()
		$Indicator/TargetIndicator.visible = true

