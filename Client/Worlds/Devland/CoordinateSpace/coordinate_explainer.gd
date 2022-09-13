@tool
extends Node3D

@export var coordinate := Vector3(1,1,1):
	set(value):
		coordinate = value
		UpdateDisplay()
@export var spin_speed := 2.0

var is_ready = false

# Called when the node enters the scene tree for the first time.
func _ready():
	is_ready = true



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint(): return
	
	var r = 2
	var h = 2
	var speed = spin_speed/1000.0
	coordinate = Vector3(r*cos(speed * Time.get_ticks_msec()), h*cos(speed * Time.get_ticks_msec()/2), r*sin(speed * Time.get_ticks_msec()))
	UpdateDisplay()


func UpdateDisplay():
	if !is_ready and not Engine.is_editor_hint():
		return
	#print ("kids: ", get_child_count())
	get_node("Coordinate").position = coordinate
	
	$X.SetDash(Vector3(0,0,0), Vector3(coordinate.x, 0, 0))
	$Y.SetDash(Vector3(coordinate.x, 0, 0), Vector3(coordinate.x, 0, coordinate.z))
	$Z.SetDash(Vector3(coordinate.x, 0, coordinate.z), Vector3(coordinate.x, coordinate.y, coordinate.z))
	
	$Axes/XLabel.text = "X: %.2f" % coordinate.x
	$Axes/YLabel.text = "Y: %.2f" % coordinate.y
	$Axes/ZLabel.text = "Z: %.2f" % coordinate.z
