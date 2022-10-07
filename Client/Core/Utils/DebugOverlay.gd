extends Control



func UpdateClientId(id):
	$VBoxContainer/ClientId.text = "client_id: "+str(id)

func UpdateWorldState(data):
	$VBoxContainer/WorldState.text = "world state: "+str(data)

func UpdateLatency(value):
	$VBoxContainer/Latency.text = "latency: "+str(value)


func Add(what, text):
	if has_node("VBoxContainer/"+what):
		Update(what, text)
	else:
		var label = Label.new()
		label.name = what
		label.text = text
		$VBoxContainer.add_child(label)

func Update(which, text):
	if has_node("VBoxContainer/"+which):
		get_node("VBoxContainer/"+which).text = which+": "+text
	else:
		Add(which, text)
