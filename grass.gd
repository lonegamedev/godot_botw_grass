@tool
extends MultiMeshInstance3D

const MeshFactory = preload("mesh_factory.gd")
const GrassFactory = preload("grass_factory.gd")

@export var blade_width: Vector2 = Vector2(0.01, 0.02): 
	set(new_value): 
		blade_width = new_value
		rebuild()

@export var blade_height: Vector2 = Vector2(0.04, 0.08):
	set(new_value):
		blade_height = new_value
		rebuild()
		
@export var sway_yaw: Vector2 = Vector2(0.0, 10.0):
	set(new_value):
		sway_yaw = new_value
		rebuild()
		
@export var sway_pitch: Vector2 = Vector2(0.04, 0.08):
	set(new_value):
		sway_pitch = new_value
		rebuild()
	
@export var mesh: Mesh = null:
	set(new_value):
		mesh = new_value
		
@export var density: float = 1.0:
	set(new_value):
		density = new_value
		if density < 1.0:
			density = 1.0
		rebuild()

func rebuild():
	if !multimesh:
		multimesh = MultiMesh.new()
	multimesh.instance_count = 0
	var spawns:Array = GrassFactory.generate(
		mesh,
		density,
		blade_width,
		blade_height,
		sway_pitch,
		sway_yaw
	)
	if spawns.is_empty():
		return
	multimesh.mesh = MeshFactory.simple_grass()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_custom_data = true
	multimesh.use_colors = false
	multimesh.instance_count = spawns.size()
	for index in multimesh.instance_count:
		var spawn:Array = spawns[index]
		multimesh.set_instance_transform(index, spawn[0])
		multimesh.set_instance_custom_data(index, spawn[1])
