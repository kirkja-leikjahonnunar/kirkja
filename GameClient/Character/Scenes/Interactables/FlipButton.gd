extends ProximityButton

@export var Seesaw : NodePath
@onready var seesaw = null if Seesaw.is_empty() else get_node(Seesaw)
var seesaw_zrot := 0.0

var on: bool = false

func _ready():
	$HoverIndicate.scale = Vector3(0,0,0)
	if seesaw:
		seesaw_zrot = seesaw.rotation.z


func Hover():
	$HoverIndicate.visible = true
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($HoverIndicate, "scale", Vector3(1, 1, 1), 0.15)


func Unhover():
	#$HoverIndicate.visible = false
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($HoverIndicate, "scale", Vector3(0, 0, 0), 0.15).finished.connect(TurnOffIndicator)

func TurnOffIndicator():
	if not on:
		$HoverIndicate.visible = false


func Use():
	if on:
		on = false
		var tween : Tween = get_tree().create_tween()
		#tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property($Switch, "rotation", Vector3(0, 0, 0), 0.25)
		if seesaw:
			tween = get_tree().create_tween()
			tween.tween_property(seesaw, "rotation", Vector3(seesaw.rotation.x, seesaw.rotation.y, seesaw_zrot), 0.1)
	else:
		on = true
		var tween : Tween = get_tree().create_tween()
		tween.tween_property($Switch, "rotation", Vector3(deg2rad(-30.9), 0, 0), 0.25)
		if seesaw:
			tween = get_tree().create_tween()
			tween.tween_property(seesaw, "rotation", Vector3(seesaw.rotation.x, seesaw.rotation.y, -seesaw_zrot), 0.1)
