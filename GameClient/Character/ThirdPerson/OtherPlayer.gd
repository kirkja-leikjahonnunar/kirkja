#
# A standin for networked other players
#

extends CharacterBody3D


#--------------------- Network sync helpers ---------------------------------

func SetNameFromId(game_client_id):
	$Name.text = str(game_client_id)


func MovePlayer(pos, rot):
	global_transform.origin = pos
	global_transform.basis = Basis(rot)

