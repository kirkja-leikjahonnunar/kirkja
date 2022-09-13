extends Node



func _ready():
	call_deferred("StartFresh")
	print ("test deferred")

func StartFresh():
	#$LoginScreen.visible = true
	#$ControlConfig.visible = false
	$PauseMenu.visible = true

