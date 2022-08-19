extends ProximityButton
class_name InhabitableTrigger

# Base class of any context that can be inhabited.
#
# Place this as a child of the PlayerMesh

@export var inhabitable := true
@export var inhabitable_object : Node3D  # default to parent
var initial_layer : int
var initial_mask : int
var scale_target : Vector3
var hovered := false


func GetInhabitableObject():
	if inhabitable_object: return inhabitable_object
	return get_parent()


func _ready():
	body_entered.connect(_on_proximity_button_body_entered)
	body_exited.connect(_on_proximity_button_body_exited)
	$Highlight.visible = false
	scale_target = $Highlight.scale
	$Highlight.scale = Vector3(0,0,0)
	initial_layer = collision_layer
	initial_mask = collision_mask


func SetInhabitable():
	print ("set ",GetInhabitableObject().name," inhabitable with layer: ", initial_layer)
	collision_layer = initial_layer
	collision_mask = initial_mask
	inhabitable = true

func SetUninhabitable():
	print ("set ",GetInhabitableObject().name," uninhabitable")
	collision_layer = 0
	collision_mask = 0
	inhabitable = false
	Unhover()


func Hover():
	print ("Hover on ", GetInhabitableObject().name, ", hovered: ", hovered,", hl on: ", $Highlight.visible, ", ", collision_layer)
	$Highlight.visible = true
	hovered = true
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($Highlight, "scale", scale_target, 0.15)


func Unhover():
	#$Highlight.visible = false
	print ("unhover on ", GetInhabitableObject().name, ", hovered: ", hovered,", hl on: ", $Highlight.visible, ", ", collision_layer)
	if hovered:
		hovered = false
		var tween : Tween = get_tree().create_tween()
		tween.tween_property($Highlight, "scale", Vector3(0, 0, 0), 0.15).finished.connect(TurnOffIndicator)

func TurnOffIndicator():
	if not hovered:
		$Highlight.visible = false


func Use():
	print ("InhabitableTrigger: Inhabit!")

