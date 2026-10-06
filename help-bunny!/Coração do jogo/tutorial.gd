extends Control
class_name TelaTutorial

@export_file("*.tscn") var primeira_fase: String = "res://LEVEL 1.tscn"

@onready var label_saida: Label = $"Label de saída"

var pode_avancar: bool = false

func _ready() -> void:
	iniciar_piscar_label_saida()
	await get_tree().create_timer(0.3).timeout
	pode_avancar = true

func iniciar_piscar_label_saida() -> void:
	var tween = create_tween().set_loops()
	tween.tween_property(label_saida, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label_saida, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if not pode_avancar: 
		return
		
	if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed() and not event.is_echo():
		pode_avancar = false
		iniciar_jogo()

func iniciar_jogo() -> void:
	GameData.resetar_checkpoint_para_nova_fase(primeira_fase)
	Transition.ir_para(primeira_fase)
