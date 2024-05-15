extends RigidBody2D

class_name Destructible

@export var minImpulse: float = 7500
@export var massMultiplicator: float = 1
@export var explosionMultiplicator: float = 10000

@onready var texturePolygon: Polygon2D = $Polygon2D
@onready var cdt: ConstrainedTriangulation = ConstrainedTriangulation.new()


var exploded: bool = false
var verts: PackedVector2Array
var tris: PackedInt32Array

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 50
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	can_sleep = false
	sleeping = false
	setUpDelaunay()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if exploded: return
	for contactIndex in state.get_contact_count():
		if exploded: return
		var collider: Node2D = state.get_contact_collider_object(contactIndex) as Node2D
		state.get_space_state()
		var massMult: float = 1
		if "massMultiplicator" in collider:
			massMult = collider.massMultiplicator
		var impact = state.get_contact_impulse(contactIndex)
		var impactForce: float = impact.length() * massMult
		var isImpactEnough: bool = impactForce > minImpulse
		if not isImpactEnough: return
		explode(impact.normalized() * explosionMultiplicator)

func setUpDelaunay() -> void:
	cdt.init(true, true, 0.1)
	cdt.insert_vertices(texturePolygon.polygon)
	var edges: PackedInt32Array = []
	for verticeIndex in texturePolygon.polygon.size():
		edges.append(verticeIndex)
		if verticeIndex + 1 >= texturePolygon.polygon.size():
			edges.append(0)
		else:
			edges.append(verticeIndex + 1)
	cdt.insert_edges(edges)
	cdt.erase_outer_triangles_and_holes()
	verts = cdt.get_all_vertices()
	tris = cdt.get_all_triangles()

func explode(impact: Vector2) -> void:
	if exploded: return
	exploded = true
	var trianglesCount: int = int(tris.size() / 3.0)
	for triangleIndex in trianglesCount:
		var shardPool = PackedVector2Array()
		for pointIndex in range(3):
			shardPool.append(verts[tris[3 * triangleIndex + pointIndex]])
		var shard = RigidBody2D.new()
		var collisionShape = CollisionPolygon2D.new()
		collisionShape.polygon = shardPool
		collisionShape.scale = texturePolygon.scale
		var textureShape = Polygon2D.new()
		textureShape.polygon = shardPool
		textureShape.texture = texturePolygon.texture
		textureShape.scale = texturePolygon.scale
		get_parent().add_child.call_deferred(shard)
		shard.add_child(collisionShape)
		shard.add_child(textureShape)
		shard.position = position
		shard.rotation = rotation
		shard.mass = mass / trianglesCount
		shard.center_of_mass_mode = RigidBody2D.CENTER_OF_MASS_MODE_CUSTOM
		var centerOfMass: Vector2 = Vector2.ZERO
		for point in shardPool:
			centerOfMass += point
		centerOfMass.x = centerOfMass.x / shardPool.size()
		centerOfMass.y = centerOfMass.y / shardPool.size()
		shard.center_of_mass = centerOfMass
		shard.apply_central_impulse(impact)
	queue_free()
