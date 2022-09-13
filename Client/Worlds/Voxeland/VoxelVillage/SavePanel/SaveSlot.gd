extends ColorRect
class_name SaveSlot


var path: String
#var mod_time


func SetText(new_text):
	$Label.text = new_text


func SetSelected():
	pass


func SetUnselected():
	pass


func SetColor(new_color: Color):
	color = new_color
	material.set_shader_parameter("color", new_color)
	material.set_shader_parameter("border_color", new_color.darkened(.15))
