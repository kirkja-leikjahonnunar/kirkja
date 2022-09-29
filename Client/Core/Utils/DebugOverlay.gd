extends Node2D



func UpdateClientId(id):
	$VBoxContainer/ClientId.text = "client_id: "+str(id)

func UpdateWorldState(data):
	$VBoxContainer/WorldState.text = "world state: "+str(data)

func UpdateLatency(value):
	$VBoxContainer/Latency.text = "latency: "+str(value)


func Add(what, text):
	var label = Label.new()
	label.name = what
	label.text = text
	$VBoxContainer.add_child(label)

func Update(which, text):
	if has_node("VBoxContainer/"+which):
		get_node("VBoxContainer/"+which).text = text
