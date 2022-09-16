extends Node3D

const NOTE_PS = preload("res://Worlds/Audioland/Flowav/Note/Note.tscn")


func _on_timer_timeout():
	var note = NOTE_PS.instantiate()
	
	add_child(note)
