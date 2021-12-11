extends Spatial

var angle:float = 0.0
export(float) var angular_speed:float = 0.1

func _process(delta):
	angle += delta * angular_speed
	transform.basis = Basis(Quat(Vector3.UP, angle))
