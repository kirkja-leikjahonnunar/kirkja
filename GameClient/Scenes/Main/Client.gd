extends Node



func _ready():
	call_deferred("StartFresh")
	print ("test deferred")

func StartFresh():
	$LoginScreen.visible = true
	$ControlConfig.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
