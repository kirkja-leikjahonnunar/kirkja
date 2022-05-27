extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.size_changed.connect(WindowSizeChanged)
	$ScreenSize.minimum_size = get_tree().root.size


func WindowSizeChanged():
	print ("window size changed: ", get_tree().root.size)
	$ScreenSize.minimum_size = get_tree().root.size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta):
#	pass
