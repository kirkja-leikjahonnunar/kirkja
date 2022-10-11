extends Control


@export var align_right := false


func UpdateClientId(id):
	if align_right:
		$VBoxContainer/ClientId.text = str(id) + ": client_id"
	else:
		$VBoxContainer/ClientId.text = "client_id: "+str(id)

func UpdateWorldState(data):
	if align_right:
		$VBoxContainer/WorldState.text = str(data) + ": world state"
	else:
		$VBoxContainer/WorldState.text = "world state: "+str(data)

func UpdateLatency(value):
	if align_right:
		$VBoxContainer/Latency.text = str(value) + ": latency"
	else:
		$VBoxContainer/Latency.text = "latency: "+str(value)


func Add(what, text):
	if has_node("VBoxContainer/"+what):
		Update(what, text)
	else:
		var label := Label.new()
		if align_right:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		else:
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.name = what
		label.text = str(text)
		$VBoxContainer.add_child(label)


func Update(which, text):
	if has_node("VBoxContainer/"+which):
		if align_right:
			get_node("VBoxContainer/"+which).text =  str(text) + " : " + str(which)
		else:
			get_node("VBoxContainer/"+which).text = str(which)+": "+str(text)
	else:
		Add(which, text)
