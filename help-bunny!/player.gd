extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTO ---
@export var velocidade_corrida: float = 150.0
@export var força_pulo_degrau: float = -200.0     # Pulo curto para subir degraus
@export var força_pulo_obstaculo: float = -350.0  # Altura do pulo para superar o buraco
@export var impulso_horizontal_pulo: float = 320.0 # Distância para frente para atravessar o vão
@export var gravidade: float = 980.0

# --- ESTADOS DO COELHO ---
enum Estado { CORRENDO, PARADO, PULANDO, CHECKPOINT }
var estado_atual: Estado = Estado.CORRENDO

# --- NÓS DO COELHO ---
@onready var raycast_obstaculo: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Registra no grupo para o Projétil conseguir identificar o Player
	add_to_group("player")
	
	raycast_obstaculo.collide_with_areas = true
	raycast_obstaculo.collide_with_bodies = true
	
	# Registra a fase atual e reposiciona no Checkpoint (se existir)
	if GameData:
		GameData.fase_atual = get_tree().current_scene.scene_file_path
		
		if GameData.tem_checkpoint and GameData.pos_checkpoint != Vector2.ZERO:
			global_position = GameData.pos_checkpoint

func _physics_process(delta):
	# Aplica gravidade
	if not is_on_floor():
		velocity.y += gravidade * delta

	match estado_atual:
		Estado.CORRENDO:
			velocity.x = velocidade_corrida
			
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("correr"):
				sprite.play("correr")
			
			# Pulo automático de degrau pequeno
			if is_on_wall() and is_on_floor():
				velocity.y = força_pulo_degrau

			# Detecta o Obstáculo na Layer 2
			if raycast_obstaculo.is_colliding():
				parar_no_obstaculo()

		Estado.PARADO:
			velocity.x = 0
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("parado"):
				sprite.play("parado")

		Estado.PULANDO:
			# Mantém a velocidade impulsionada para frente durante o salto
			velocity.x = impulso_horizontal_pulo
			
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("pular"):
				sprite.play("pular")
			
			# Quando pousar na plataforma oposta, volta a correr normalmente
			if is_on_floor() and velocity.y >= 0:
				estado_atual = Estado.CORRENDO

		Estado.CHECKPOINT:
			# Fica parado no checkpoint sem acionar a lógica de digitação
			velocity.x = 0
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("parado"):
				sprite.play("parado")

	move_and_slide()

# --- FUNÇÕES DE CONTROLE ---

func parar_no_obstaculo():
	if estado_atual != Estado.PARADO and estado_atual != Estado.CHECKPOINT:
		estado_atual = Estado.PARADO

func pular_obstaculo_automaticamente():
	if estado_atual == Estado.PARADO:
		velocity.y = força_pulo_obstaculo
		velocity.x = impulso_horizontal_pulo
		estado_atual = Estado.PULANDO
		
		# Salva no GameData que o jogador avançou um obstáculo (checkpoint)
		if GameData:
			GameData.tem_checkpoint = true

# --- SISTEMA DE DANO E DERROTA ---

func tomar_dano():
	# Efeito visual: pisca rapidamente em vermelho ao sofrer dano
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 0.2, 0.2, 1.0), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	# Se a vida zerar, executa a morte
	if GameData and GameData.vida_atual <= 0:
		morrer()

func morrer():
	# Para totalmente a física do player
	velocity = Vector2.ZERO
	set_physics_process(false)
	set_process(false)
	
	# Toca animação de hit/derrota se ela existir no sprite
	if sprite.sprite_frames and sprite.sprite_frames.has_animation("hit"):
		sprite.play("hit")

# --- PAUSA DE CHECKPOINT ---

func pausar_por_tempo(tempo_segundos: float = 2.0):
	# Muda para o estado isolado de CHECKPOINT
	estado_atual = Estado.CHECKPOINT
	
	await get_tree().create_timer(tempo_segundos).timeout
	
	# Só volta a correr se ainda estiver aguardando no checkpoint
	if estado_atual == Estado.CHECKPOINT:
		estado_atual = Estado.CORRENDO
