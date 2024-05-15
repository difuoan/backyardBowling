extends BowlingPin

class_name ShieldPin

@onready var shield: Node2D = $Shield
@onready var hand: Sprite2D = $Shield/Hand
@onready var maxShieldDistance: float = hand.position.x

func _process(_delta) -> void:
	pointAtBall()

func _on_horrified_area_body_entered(body: Node2D):
	getHorrified(body)

func _on_sceptical_area_body_entered(body: Node2D):
	getSceptical(body)
	seeDeath(body)

func pointAtBall() -> void:
	if not Global.ball or isAlreadyHit or not isHorrified: return
	shield.visible = true
	shield.look_at(Global.ball.global_position)
	var rad = shield.rotation
	var deg = rad_to_deg(rad)
	var normalisedRad = deg / 180.0
	normalisedRad -= int(normalisedRad)
	var distanceToOne: float = abs(1 - normalisedRad)
	var distanceToZero: float = abs(0 - normalisedRad)
	var distance: float = min(distanceToZero, distanceToOne)
	var distanceMod = abs(remap(distance, 0, 0.5, 0.5, 1))
	hand.position.x = maxShieldDistance * distanceMod

func _on_died(_body: Node2D):
	shield.queue_free()
