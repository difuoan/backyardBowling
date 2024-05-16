extends RichTextLabel

@export var typeSpeeds: Dictionary = {
	" ": 0.1,
	",": 0.2,
	".": 0.4,
	";": 0.2,
	":": 0.2,
	"-": 0.2,
	"!": 0.4,
	"?": 0.4
}
@export var charWaitTime: float = 0.05
@export var initialWaitTime: float = 1

@onready var audioPlayer: AudioStreamPlayer = $%AudioStreamPlayer

var originalText: String
var skip: bool = false
var levelComplete: bool = false

func _ready():
	originalText = text
	text = ""
	await get_tree().create_timer(initialWaitTime).timeout
	var isBBCode: bool = false
	audioPlayer.play()
	for character in originalText:
		if skip: return
		text += character
		if character == "[":
			isBBCode = true
		elif character == "]":
			isBBCode = false
		if isBBCode: continue
		var waitTime: float = charWaitTime
		if typeSpeeds.has(character):
			waitTime += typeSpeeds[character]
		await get_tree().create_timer(waitTime).timeout
	audioPlayer.stop()
	Global.onLevelComplete()
	levelComplete = true

func _input(event):
	if skip or levelComplete: return
	var isEcho: bool = event.is_echo()
	var isLeftClick: bool = event.is_action("click_left")
	var isReleased: bool = event.is_released()
	var hasPosition: bool = "global_position" in event
	if not isLeftClick or not hasPosition or isEcho or not isReleased: return
	skip = true
	text = originalText
	audioPlayer.stop()
	Global.onLevelComplete()
	levelComplete = true
