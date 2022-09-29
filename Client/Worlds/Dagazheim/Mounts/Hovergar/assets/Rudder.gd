extends Node3D

@onready var animation_player = $AnimationPlayer

func SlideRudder(lowering: bool):
	if lowering:
		animation_player.play("slide_rudder")
	else:
		animation_player.play_backwards("slide_rudder")


