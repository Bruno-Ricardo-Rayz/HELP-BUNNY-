extends Area2D

var ativado: bool = false

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_checkpoint: AudioStreamPlayer = $SomCheckpoint

func _ready():
	body_entered.connect(_on_body_entered)
	
	if is_instance_valid(animated_sprite):
		animated_sprite.stop()
		animated_sprite.frame = 0 # Fica inteira parada no chão esperando o player

func _on_body_entered(body):
	if not ativado and (body.name == "Player" or body.is_in_group("player")):
		ativado = true
		
		# Toca o som do checkpoint
		if is_instance_valid(som_checkpoint):
			som_checkpoint.play()
		
		# Toca a animação UMA VEZ ao ser coletada
		if is_instance_valid(animated_sprite):
			animated_sprite.frame = 0
			animated_sprite.play("carrot")
		
		# Salva o checkpoint no GameData
		if GameData:
			var caminho_fase = get_tree().current_scene.scene_file_path
			GameData.salvar_checkpoint(caminho_fase, global_position)
		
		# Faz o player parar por 2 segundos no estado de CHECKPOINT
		if body.has_method("pausar_por_tempo"):
			body.pausar_por_tempo(2.0)
		
		# Faz o pulso contínuo
		iniciar_pulso_continuo()

func iniciar_pulso_continuo():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.25, 1.25), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
