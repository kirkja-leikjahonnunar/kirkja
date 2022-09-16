extends Node3D

@onready var knob: MeshInstance3D = $Knob
#var radius: float

#func _ready():
#	radius = knob.mesh.radius

func SetMagnatude(magnitude: float, radius: float):
	knob.mesh.height = magnitude
	knob.mesh.radius = radius
	var material = knob.get_surface_override_material(0)
	material.albedo_color = Color.from_hsv(1.0 / 16.0 * position.x, 1.0, magnitude / 5.0, 1.0)
	#material.emission_energy = value / 10
