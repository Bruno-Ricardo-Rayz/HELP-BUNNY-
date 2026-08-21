extends Area2D

# Permite escolher a cena de destino direto pelo Inspetor no editor
@export_file("*.tscn") var proxima_cena: String

func _ready():
	# Conecta o sinal de quando algum corpo entra na área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verifica se o corpo que entrou é o jogador (pelo nome do nó ou por grupo)
	if body.name == "Player" or body.is_in_group("player"):
		mudar_de_fase()

func mudar_de_fase():
	if proxima_cena != "":
		# Atualiza o GameData para registrar a nova fase e preparar o progresso
		if GameData:
			GameData.resetar_checkpoint_para_nova_fase(proxima_cena)
			
		# Faz a troca para a cena configurada
		get_tree().change_scene_to_file(proxima_cena)
	else:
		print("Aviso: Nenhuma cena configurada no portal!")
