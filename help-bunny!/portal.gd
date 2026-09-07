extends Area2D

# Permite escolher a cena de destino direto pelo Inspetor no editor
@export_file("*.tscn") var proxima_cena: String

var trocando_de_fase: bool = false

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if trocando_de_fase:
		return
		
	# Verifica se o corpo que entrou é o jogador
	if body.name == "Player" or body.is_in_group("player"):
		trocando_de_fase = true
		mudar_de_fase()

func mudar_de_fase():
	if proxima_cena != "":
		# 1. Atualiza o GameData para registrar a nova fase e preparar o progresso
		if GameData and GameData.has_method("resetar_checkpoint_para_nova_fase"):
			GameData.resetar_checkpoint_para_nova_fase(proxima_cena)
			
		# 2. Chama o Autoload do Transition para fazer o fade_out -> troca de cena -> fade_in
		if Engine.has_singleton("Transition") or get_node_or_null("/root/Transition"):
			Transition.ir_para(proxima_cena)
		else:
			# Fallback de emergência caso o Transition falhe
			get_tree().change_scene_to_file(proxima_cena)
	else:
		trocando_de_fase = false
		print("Aviso: Nenhuma cena configurada no portal!")
