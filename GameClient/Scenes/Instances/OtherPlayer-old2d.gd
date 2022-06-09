extends CharacterBody2D


func MovePlayer(new_position):
	#print ("MovePlayer, old: ", position, ", new: ", new_position)
	set_position(new_position)


func SetNameFromId(new_name: int):
	name = str(new_name)
	$Sprite2D/Name.text = name
