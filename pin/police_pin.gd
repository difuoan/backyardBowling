extends BowlingPin

class_name PolicePin

signal onGuard(body: Node2D)

@export var projectile: PackedScene = preload("res://pin/bullet.tscn")
@export var bulletSpeed: float = 12500

@onready var gun: Sprite2D = $Gun
@onready var hand: Sprite2D = $Gun/Hand
@onready var muzzle: Node2D = $Gun/Muzzle
@onready var maxGunDistance: float = gun.offset.x
@onready var maxMuzzleDistance: float = muzzle.position.x

func _process(_delta) -> void:
	pointAtBall()
	if isAlreadyHit: gun.visible = false

func _on_horrified_area_body_entered(body: Node2D):
	getHorrified(body)
	onGuard.emit(body)

func _on_sceptical_area_body_entered(body: Node2D):
	getSceptical(body)
	seeDeath(body)
	checkBuddy(body)

func checkBuddy(body: Node2D):
	if isAlreadyHit or isHorrified: return
	if not body is PolicePin: return
	body.onGuard.connect(getHorrified)

func pointAtBall() -> void:
	if not Global.ball or isAlreadyHit or not isHorrified: return
	gun.visible = true
	gun.look_at(Global.ball.global_position)
	if muzzle.global_position.x < global_position.x and gun.flip_v == false:
		gun.flip_v = true
	elif muzzle.global_position.x > global_position.x and gun.flip_v == true:
		gun.flip_v = false
	var rad = gun.rotation
	var deg = rad_to_deg(rad)
	var normalisedRad = deg / 180.0
	normalisedRad -= int(normalisedRad)
	var distanceToOne: float = abs(1 - normalisedRad)
	var distanceToZero: float = abs(0 - normalisedRad)
	var distance: float = min(distanceToZero, distanceToOne)
	var distanceMod = abs(remap(distance, 0, 0.5, 0.5, 1))
	gun.offset.x = maxGunDistance * distanceMod
	hand.position.x = maxGunDistance * distanceMod
	muzzle.position.x = maxMuzzleDistance * distanceMod

func _on_gun_timer_timeout():
	if not Global.ball or isAlreadyHit or not isHorrified: return
	var bullet: RigidBody2D = projectile.instantiate() as RigidBody2D
	get_parent().add_child(bullet)
	bullet.global_position = muzzle.global_position
	bullet.look_at(Global.ball.global_position)
	bullet.apply_central_impulse(Vector2(cos(bullet.rotation), sin(bullet.rotation)) * bulletSpeed)

