extends Object

static func rand_bcc() -> Vector3:
	var u:float = randf_range(0, 1)
	var v:float = randf_range(0, 1)
	if (u + v) >= 1:
		u = 1 - u
		v = 1 - v
	return Vector3(u, v, 1.0 - (u + v))

static func from_bcc_vector3(
	p_uvw:Vector3,
	p_a:Vector3,
	p_b:Vector3,
	p_c:Vector3) -> Vector3:
		return (p_a * p_uvw.x) + (p_b * p_uvw.y) + (p_c * p_uvw.z)

static func get_orthogonal_to(p_v:Vector3) -> Vector3:
	var x:float = abs(p_v.x)
	var y:float = abs(p_v.y)
	var z:float = abs(p_v.z)
	var other:Vector3 = Vector3.FORWARD
	if (x > y) && (x > z):
		other = Vector3.RIGHT
	elif (y > z):
		other = Vector3.UP
	return p_v.cross(other)

static func quat_shortest_arc(
	p_normal_from:Vector3,
	p_normal_to:Vector3) -> Quaternion:
		var dot:float = p_normal_from.dot(p_normal_to)
		if dot > 0.999999:
			return Quaternion.IDENTITY
		if dot < -0.999999:
			return Quaternion(get_orthogonal_to(p_normal_from), PI)
		var axis:Vector3 = p_normal_from.cross(p_normal_to)
		return Quaternion(axis.x, axis.y, axis.z, 1 + dot).normalized()

static func triangle_area(p_a:Vector3, p_b:Vector3, p_c:Vector3)->float:
	var a:float = p_a.distance_to(p_b)
	var b:float = p_b.distance_to(p_c)
	var c:float = p_c.distance_to(p_a)
	var s:float = (a + b + c) / 2
	return sqrt(s * (s - a) * (s - b) * (s - c))
	
static func generate(
	p_mesh:Mesh,
	p_density:float,
	p_blade_width:Vector2,
	p_blade_height:Vector2,
	p_sway_pitch:Vector2,
	p_sway_yaw:Vector2) -> Array:
		if !p_mesh:
			return []
		var spawns:Array = []
		var surface:Array = p_mesh.surface_get_arrays(0)
		var indices:PackedInt32Array = surface[Mesh.ARRAY_INDEX]
		var positions:PackedVector3Array = surface[Mesh.ARRAY_VERTEX]
		var normals:PackedVector3Array = surface[Mesh.ARRAY_NORMAL]
		for index in range(0, indices.size(), 3):
			var j = indices[index]
			var k = indices[index + 1]
			var l = indices[index + 2]
			var area:float = triangle_area(
				positions[j],
				positions[k],
				positions[l]
			)
			var blades_per_face:int = int(round(area * p_density))
			for _i in range(0, blades_per_face):
				var uvw:Vector3 = rand_bcc()
				var position:Vector3 = from_bcc_vector3(
					uvw,
					positions[j],
					positions[k],
					positions[l]
				)
				var normal:Vector3 = from_bcc_vector3(
					uvw,
					normals[j],
					normals[k],
					normals[l]
				)
				var q1:Quaternion = Quaternion(Vector3.UP, deg_to_rad(randf_range(0, 360)))
				var q2:Quaternion = quat_shortest_arc(Vector3.UP, normal)
				var transform:Transform3D = Transform3D(Basis(q2 * q1), position)
				var params:Color = Color(
					randf_range(p_blade_width.x, p_blade_width.y),
					randf_range(p_blade_height.x, p_blade_height.y),
					deg_to_rad(randf_range(p_sway_pitch.x, p_sway_pitch.y)),
					deg_to_rad(randf_range(p_sway_yaw.x, p_sway_yaw.y))
				)
				spawns.push_back([transform, params])
		return spawns
