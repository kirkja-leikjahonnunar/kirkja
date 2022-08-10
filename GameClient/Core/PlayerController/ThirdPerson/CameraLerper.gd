#
# This camera lerps to camera targets defined by various other things,
# like a player's camera rig or scene poi cameras.
#

extends Camera3D


@export var FollowProxy : NodePath
@onready var follow_proxy = get_node(FollowProxy) if not FollowProxy.is_empty() else null

@export var lerp_speed := 30


# Called when the node enters the scene tree for the first time.
func _ready():
	GameGlobals.main_camera = self
	
	if follow_proxy == null && has_node("../Player"):
		follow_proxy = get_node("../Player").GetCameraProxy()
	if follow_proxy == null:
		follow_proxy = self # assume we will assign this to player's proxy later

func _physics_process(delta):
	global_transform = global_transform.interpolate_with(follow_proxy.global_transform, lerp_speed*delta)

func _process(_delta):
	if $SelectorCast.is_colliding():
		$Indicator/TargetIndicator.global_transform.origin = $SelectorCast.get_collision_point()
		$Indicator/TargetIndicator.visible = true

