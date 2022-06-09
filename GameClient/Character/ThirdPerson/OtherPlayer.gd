#
# A standin for networked other players
#

extends CharacterBody3D


#--------------------- Network sync helpers ---------------------------------

func SetNameFromId(game_client_id):
	name = str(game_client_id)
	$Name.text = name


func MovePlayer(pos, rot, rot2):
	global_transform.origin = pos
	$PlayerMesh.quaternion = rot2
	global_transform.basis = Basis(rot)

