extends Resource
#class_name CameraSettings

# NOT USED! would this even be useful?


@export var fov := 75.0
@export var head_height := 1.5
@export var cam_h_offset := .25
@export var cam_back_offset := .25
@export var cam_top_offset := 0.0
@export var camera_mode = "third" # CameraMode.Third

@export var allow_first_person := true
@export var min_pitch_fp := -PI/2
@export var max_pitch_fp := PI/2
@export var min_pitch := -PI/2
@export var max_pitch := PI/2
@export var min_camera_distance := 0.2  # below this, switch to 1st person
@export var max_camera_distance := 10.0  # maximum to position camera away from player

