extends RigidBody2D

class_name BowlingPin

signal died(body: Node2D)

@export var hitEffect: PackedScene = preload("res://effects/blood.tscn")
@export var strikeIndikator: PackedScene = preload("res://effects/strike_indicator.tscn")
@export var bloodFountain: PackedScene = preload("res://effects/blood_fountain.tscn")
@export var minImpulse: float = 12500
@export var massMultiplicator: float = 0.25
@export var spriteSize: float = 288
@export var minImpulseModifier: float = 0.25
@export var lethalityThreshold: float = 0.666
@export var idleExpression: Texture2D = preload("res://pin/emotions/calm.png")
@export var painExpression: Texture2D = preload("res://pin/emotions/angry.png")
@export var horrifiedExpression: Texture2D = preload("res://pin/emotions/horrified.png")
@export var scepticalExpression: Texture2D = preload("res://pin/emotions/sceptical.png")
@export var hitSound: AudioStream = preload("res://sound/pinHit.mp3")

@onready var animationTree: AnimationTree = $AnimationTree
@onready var stateMachine: AnimationNodeStateMachinePlayback = animationTree["parameters/playback"]
@onready var idleExpressionSprite: Sprite2D = $IdleExpression
@onready var painExpressionSprite: Sprite2D = $PainExpression
@onready var scepticalExpressionSprite: Sprite2D = $ScepticalExpression
@onready var horrifiedExpressionSprite: Sprite2D = $HorrifiedExpression
@onready var collisionPolygon: CollisionPolygon2D = $CollisionPolygon2D
@onready var horrifiedArea: Area2D = $HorrifiedArea
@onready var scepticalArea: Area2D = $ScepticalArea
@onready var hitAudioPlayer: AudioStreamPlayer
@onready var pinCounterRotation = randf_range(-25, 25)
@onready var pinCountercrossRotation = randf_range(0, 360)
@onready var masked: Node2D = $CanvasGroup/Masked

var isAlreadyHit: bool = false:
	get:
		return Global.hitPins.has(self)
var isHorrified: bool = false:
	get:
		return stateMachine.get_current_node() == "horror"

func _ready() -> void:
	Global.levelLoaded.connect(onLevelLoaded)
	setExpressions()
	activateAnimations()
	addAudioPlayer()
	setUpRigidBody()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	checkContacts(state)

func _on_horrified_area_body_entered(body: Node2D):
	getHorrified(body)

func _on_sceptical_area_body_entered(body: Node2D):
	getSceptical(body)
	seeDeath(body)

func seeDeath(body: Node2D):
	if isAlreadyHit or isHorrified: return
	if not body is BowlingPin: return
	body.died.connect(getHorrified)

func getHorrified(body: Node2D) -> void:
	if isAlreadyHit or isHorrified: return
	if not isBowlingBall(body): return
	stateMachine.travel("horror")
	
func getSceptical(body: Node2D) -> void:
	if isAlreadyHit or isHorrified: return
	if not isBowlingBall(body): return
	stateMachine.travel("sceptical")

func setUpRigidBody() -> void:
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	max_contacts_reported = 50
	contact_monitor = true
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, true)
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)

func activateAnimations() -> void:
	animationTree.active = true
	animationTree.set("parameters/conditions/isNotDead", true)
	animationTree.set("parameters/conditions/isDead", false)
	await get_tree().create_timer(0.1).timeout
	animationTree.advance(randf_range(0.0, 4.0))

func setExpressions() -> void:
	if idleExpression: idleExpressionSprite.texture = idleExpression
	if painExpression: painExpressionSprite.texture = painExpression
	if horrifiedExpression: horrifiedExpressionSprite.texture = horrifiedExpression
	if scepticalExpression: scepticalExpressionSprite.texture = scepticalExpression

func addAudioPlayer() -> void:
	hitAudioPlayer = AudioStreamPlayer.new()
	add_child(hitAudioPlayer)
	hitAudioPlayer.stream = hitSound

func isBowlingBall(body: Node2D) -> bool:
	return body is BowlingBall

func hit(hitPosition: Vector2, hitPositionModifier: float, collider: Node2D) -> void:
	if not isAlreadyHit: stateMachine.travel("pain")
	addSplatter(hitPosition, collider is BowlingBall)
	var isLethal: bool = hitPositionModifier > lethalityThreshold
	if not isLethal or isAlreadyHit: return
	animationTree.set("parameters/conditions/isNotDead", false)
	animationTree.set("parameters/conditions/isDead", true)
	addFountain(hitPosition, collider)
	Global.kill.emit(self)
	died.emit(Global.ball)
	addStrikeIndicator(hitPosition)

func addSplatter(effectPosition: Vector2, hitByBall: bool = false):
	var splatter = hitEffect.instantiate()
	get_parent().add_child(splatter)
	splatter.global_position = effectPosition
	splatter.rotation_degrees = randf_range(0, 360)
	splatter.z_index = -10
	if hitByBall:
		var ballSplatter = hitEffect.instantiate()
		Global.ball.masked.add_child(ballSplatter)
		ballSplatter.global_position = effectPosition
		ballSplatter.rotation_degrees = randf_range(0, 360)
	var wound = hitEffect.instantiate()
	masked.add_child(wound)
	wound.global_position = effectPosition
	wound.rotation_degrees = randf_range(0, 360)

func addFountain(effectPosition: Vector2, collider: Node2D):
	var fountain = bloodFountain.instantiate()
	add_child(fountain)
	fountain.global_position = effectPosition
	fountain.look_at(collider.position)

func addStrikeIndicator(effectPosition: Vector2) -> void:
	if Global.pinCount < Global.pins.size(): return
	var strike = strikeIndikator.instantiate()
	get_parent().add_child(strike)
	strike.global_position = effectPosition

func checkContacts(state: PhysicsDirectBodyState2D) -> void:
	for contactIndex in state.get_contact_count():
		checkContact(state, contactIndex)
	
func checkContact(state: PhysicsDirectBodyState2D, contactIndex: int) -> void:
	var collider: Node2D = state.get_contact_collider_object(contactIndex) as Node2D
	var massMult: float = getMassMultiplicator(collider)
	var impactForce: float = state.get_contact_impulse(contactIndex).length() * massMult
	var hitPosition: Vector2 = state.get_contact_local_position(contactIndex)
	var hitPositionModifier: float = getHitPositionModifier(hitPosition)
	var isImpactEnough: bool = impactForce * massMult * hitPositionModifier > minImpulse
	var lastVelocity: Vector2 = Vector2.ZERO
	var lastPosition: Vector2 = collider.position
	if "lastPosition" in collider:
		lastPosition = collider.lastPosition
	var currentVelocity: Vector2 = Vector2.ZERO
	if "linear_velocity" in collider:
		currentVelocity = collider.linear_velocity
	if "velocity" in collider:
		currentVelocity = collider.velocity
	if "lastVelocity" in collider:
		lastVelocity = collider.lastVelocity
	var isFlyingAway: bool = (collider.position + currentVelocity).distance_to(hitPosition) > (lastPosition + lastVelocity).distance_to(hitPosition)
	var isVelocityEnough: bool = lastVelocity.length() * massMult * hitPositionModifier > minImpulse
	if (not isImpactEnough and not isVelocityEnough) or isFlyingAway: return
	hit(hitPosition, hitPositionModifier, collider)

func getHitPositionModifier(hitPosition: Vector2) -> float:
	var localHitPositionY: float = (to_local(hitPosition).y - spriteSize) * -1
	var normalisedLocalHitPositionY: float = localHitPositionY / (spriteSize * 2)
	return clampf(normalisedLocalHitPositionY, minImpulseModifier, 1)

func getMassMultiplicator(collider: Node2D) -> float:
	var massMult: float = 1
	if "massMultiplicator" in collider:
		massMult = collider.massMultiplicator
	return massMult

func onLevelLoaded() -> void:
	Global.pins.append(self)
	Global.pinSize += 1
