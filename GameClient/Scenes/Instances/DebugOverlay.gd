extends Node2D



func UpdateClientId(id):
	$ClientId.text = "client_id: "+str(id)


func UpdateWorldState(data):
	$WorldState.text = "world state: "+str(data)
