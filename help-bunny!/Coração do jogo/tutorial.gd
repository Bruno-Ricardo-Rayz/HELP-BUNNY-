extends Control

# Altere para o caminho da sua primeira fase se necessário
@export_file("*.tscn") var primeira_fase: String = "res://LEVEL 1.tscn"

@onready var label_saida: Label = $"Label de saída"

var pode_avancar: bool = false

func _ready():
	# Inicia o efeito de piscar no label de saída
	iniciar_piscar_label_saida()
	
	# Aguarda 0.3 segundos antes de permitir avançar para evitar cliques acidentais vindos do menu
	await get_tree().create_timer(0.3).timeout
	pode_avancar = true

func iniciar_piscar_label_saida():
	if is_instance_valid(label_saida):
		# Cria um Tween em loop para suavizar a visibilidade da mensagem
		var tween = create_tween().set_loops()
		tween.tween_property(label_saida, "modulate:a", 0.2, 0.6).set_trans(Tween.TRANS_SINE)
		tween.tween_property(label_saida, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event):
	if not pode_avancar:
		return
		
	# Aceita qualquer tecla, botão do mouse ou toque na tela
	if (event is InputEventKey or event is InputEventMouseButton) and event.pressed and not event.echo:
		pode_avancar = false
		iniciar_jogo()

func iniciar_jogo():
	if GameData:
		GameData.resetar_checkpoint_para_nova_fase(primeira_fase)
		
	if Transition:
		Transition.ir_para(primeira_fase)
	else:
		get_tree().change_scene_to_file(primeira_fase)
