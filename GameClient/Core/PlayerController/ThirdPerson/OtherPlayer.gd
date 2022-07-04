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

# If we despawn immediately upon server notification, it will most likely respawn due to 
# state updates, so we wait a little bit before fully despawning
func BeginDespawn():
	print ("Begin despawn for ", name)
	get_tree().create_timer(2.0).timeout.connect(FinalDespawn)

func FinalDespawn():
	print ("Final destruction of ", name)
	queue_free()
