@tool
extends EditorScript


func _run():
	var dict = {"a":1, "b":2}
	
	for key in dict:
		print (key, ": ", dict[key])

	print("---")
	for key in dict.keys():
		print (key, ": ", dict[key])
	
	print (dict.a)
