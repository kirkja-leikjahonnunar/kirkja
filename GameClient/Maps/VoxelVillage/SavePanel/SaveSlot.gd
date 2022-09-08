extends ColorRect


func SetText(new_text):
	$Label.text = new_text


func SetSelected():
	pass


func SetUnselected():
	pass


func SetColor(new_color: Color):
	color = new_color
	material.set_shader_uniform("color", new_color)
	material.set_shader_uniform("border_color", new_color.darkened(.15))
