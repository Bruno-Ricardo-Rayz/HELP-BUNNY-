extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTO ---
@export var velocidade_corrida: float = 150.0
@export var força_pulo_degrau: float = -200.0     # Pulo curto para subir degraus
@export var força_pulo_obstaculo: float = -350.0  # Altura do pulo para superar o buraco
@export var impulso_horizontal_pulo: float = 320.0 # Distância para frente para atravessar o vão
@export var gravidade: float = 980.0

# --- ESTADOS DO COELHO ---
enum Estado { CORRENDO, PARADO, PULANDO }
var estado_atual: Estado = Estado.CORRENDO

# --- NÓS DO COELHO ---
@onready var raycast_obstaculo: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	raycast_obstaculo.collide_with_areas = true
	raycast_obstaculo.collide_with_bodies = true

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

	move_and_slide()

# --- FUNÇÕES DE CONTROLE ---

func parar_no_obstaculo():
	if estado_atual != Estado.PARADO:
		estado_atual = Estado.PARADO

func pular_obstaculo_automaticamente():
	if estado_atual == Estado.PARADO:
		velocity.y = força_pulo_obstaculo
		velocity.x = impulso_horizontal_pulo
		estado_atual = Estado.PULANDO
