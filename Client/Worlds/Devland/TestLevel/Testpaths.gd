extends Path3D


@export var world_scale_start := 1.0
@export var world_scale_end := .5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


var first := true
var ticker : float
var last_player_pos : Vector3
var last_percent : float


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if GameGlobals.current_player_object == null: return
	
	$pathpoint.position = curve.samplef(ticker)
	ticker += _delta
	if ticker > curve.point_count: ticker = 0
	
	var player_point = to_local(GameGlobals.current_player_object.global_position)
	if player_point == last_player_pos:
		return
	
	var closest_point = curve.get_closest_point(player_point)
	var closest_baked_offset = curve.get_closest_offset(player_point)
	var closest_percent = closest_baked_offset / curve.get_baked_length()
	
	$Closest.position = closest_point
	
	print ("point: ", player_point, ", closest: ", closest_point, ", offset: ", closest_baked_offset, ", %: ", closest_percent)
	
	if (closest_point - player_point).length() > 3.0: # manual collider: distance to path, would be nice to use tilt for this
		first = true
		$Closest.mesh.surface_get_material(0).albedo_color = Color(1,0,0)
		return
	
	if first:
		first = false
		last_player_pos = player_point
		last_percent = closest_baked_offset / curve.get_baked_length()
		$Closest.mesh.surface_get_material(0).albedo_color = Color(0,1,0)
		return
	
	var last_scale = (world_scale_end - world_scale_start) * last_percent + world_scale_start
	var current_scale = (world_scale_end - world_scale_start) * closest_percent + world_scale_start
	var scale_diff = current_scale / last_scale
	
	$Size.scale = scale_diff * $Size.scale
	var map = get_node("/root/Client/World/Map")
	var old_player_world_pos = GameGlobals.current_player_object.global_position
	var old_player_map_pos = map.to_local(GameGlobals.current_player_object.global_position)
	map.scale = scale_diff * map.scale
	map.global_position -= map.to_global(old_player_map_pos) - old_player_world_pos
	#var new_player_world_pos = GameGlobals.current_player_object.global_position
	
	last_player_pos = player_point
	last_percent = closest_percent
