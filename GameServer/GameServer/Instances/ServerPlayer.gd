extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass



func SetName(new_name: String):
	$PlayerName.text = new_name


func SetColor(new_color: Color):
	var mat = $PlayerMesh.mesh.surface_get_material()
	mat.albedo_color = new_color

