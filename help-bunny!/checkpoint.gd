extends Area2D

var ativado: bool = false

# AJUSTE DA ALTURA DE RESPAWN:
# Quanto maior o número negativo aqui, mais ALTO o coelho vai nascer.
const OFFSET_RESPAWN_Y: float = -120.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_checkpoint: AudioStreamPlayer = $SomCheckpoint

func _ready():
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Estado inicial: Parado no primeiro frame (cenoura inteira)
	if is_instance_valid(animated_sprite):
		animated_sprite.stop()
		animated_sprite.frame = 0

func _on_body_entered(body):
	if not ativado and (body.name == "Player" or body.is_in_group("player")):
		ativado = true
		
		# Toca o som do checkpoint
		if is_instance_valid(som_checkpoint):
			som_checkpoint.play()
		
		# Toca a animação da cenoura sendo comida
		if is_instance_valid(animated_sprite):
			if not animated_sprite.animation_finished.is_connected(_on_animacao_terminou):
				animated_sprite.animation_finished.connect(_on_animacao_terminou)
			
			animated_sprite.frame = 0
			animated_sprite.play("carrot")
		
		# Salva a posição do checkpoint BEM MAIS PARA CIMA (-120px)
		if GameData and GameData.has_method("salvar_checkpoint"):
			var caminho_fase = get_tree().current_scene.scene_file_path
			var pos_respawn = global_position + Vector2(0, OFFSET_RESPAWN_Y)
			
			GameData.salvar_checkpoint(caminho_fase, pos_respawn)
			print("Checkpoint salvo com sucesso! Posicao de Respawn: ", pos_respawn)
		
		# Trava a corrida do coelho por 2 segundos
		if body.has_method("pausar_por_tempo"):
			body.pausar_por_tempo(2.0)

func _on_animacao_terminou():
	# Trava no último frame da animação (cenoura toda comida)
	if is_instance_valid(animated_sprite):
		animated_sprite.stop()
		var ultimo_frame = animated_sprite.sprite_frames.get_frame_count("carrot") - 1
		animated_sprite.frame = max(0, ultimo_frame)
