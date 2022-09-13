@tool
extends EditorScript



# Called when the node enters the scene tree for the first time.
func _run():
#	var s : String = "abc %s, %.2f" % [123, 456.2342342]
#	print (s)
#	print("abc", 123)
#	#print("abc %s, %.2f" % [123, 456.2342342])
	var s = "0123456789"
	print ("right(2): ", s.right(2))
	print ("right(-2): ", s.right(-2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
