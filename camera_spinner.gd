extends Node3D

var angle:float = 0.0
@export var angular_speed: float:float = 0.1

func _process(delta):
	angle += delta * angular_speed
	transform.basis = Basis(Quaternion(Vector3.UP, angle))
