extends CPUParticles3D

var default_amount: int = amount


func SetAmountMultiplier(multiplier: int):
	# TODO: Can't adjust the `amount` without recalculating the emitter.
	# Issue: https://github.com/godotengine/godot/issues/16352
	
	# TODO: Can we get around setting the amount somehow?
	# TODO: Fake it with several speeds.
#	if multiplier > 0:
#		amount = 45 #default_amount * multiplier * 10
#		emitting = true
#	else:
#		amount = 10
#		emitting = true
	pass
