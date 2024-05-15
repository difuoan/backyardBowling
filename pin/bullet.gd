extends RigidBody2D

@export var ballImpactForce: float = 25000
@export var sceneryImpactForce: float = 5000

var isAlreadyUsed: bool = false
var lastVelocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	setUpRigidBody()

func _process(_delta: float) -> void:
	lastVelocity = linear_velocity

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	checkContacts(state)

func checkContacts(state: PhysicsDirectBodyState2D) -> void:
	for contactIndex in state.get_contact_count():
		checkContact(state, contactIndex)

func setUpRigidBody() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	max_contacts_reported = 50
	contact_monitor = true
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func disableRigidBody() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_DISABLED
	max_contacts_reported = 0
	contact_monitor = false

func checkContact(state: PhysicsDirectBodyState2D, contactIndex: int) -> void:
	if isAlreadyUsed: return
	isAlreadyUsed = true
	var collider: Node2D = state.get_contact_collider_object(contactIndex) as Node2D
	if collider is BowlingBall:
		collider.apply_central_impulse(lastVelocity.normalized() * ballImpactForce)
	elif collider is BowlingPin:
		var hitPosition: Vector2 = state.get_contact_local_position(contactIndex)
		collider.hit(hitPosition, 1, self)
		queue_free()
	elif collider is Destructible:
		collider.explode(lastVelocity.normalized() * sceneryImpactForce)
