extends ProximityButton


#TODO: this should probably be a generic map portal trigger

var voxel_village_resource := "res://Maps/VoxelVillage/VoxelVillage.tscn"


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_on_proximity_button_body_entered)
	body_exited.connect(_on_proximity_button_body_exited)


func Hover():
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($GPUParticles3D.draw_pass_1.surface_get_material(0), "albedo_color", Color(1,1,1), 0.15)
	#.albedo_color = Color(1,1,1)


func Unhover():
	#$GPUParticles3D.draw_pass_1.surface_get_material(0).albedo_color = Color(.3,.3,.3)
	var tween : Tween = get_tree().create_tween()
	tween.tween_property($GPUParticles3D.draw_pass_1.surface_get_material(0), "albedo_color", Color(.3,.3,.3), 0.15)


func Use():
	print ("Voxel map trigger!")
	#TODO: transition to voxel_village_resource
