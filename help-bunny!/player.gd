extends CharacterBody2D

# --- CONFIGURAÇÕES DO COELHO ---
@export var velocidade_corrida: float = 200.0
@export var força_pulo_degrau: float = -280.0   # Pulo curto para subir relevo/bloco
@export var força_pulo_obstaculo: float = -420.0 # Pulo grande (quando acertar a palavra)
@export var gravidade: float = 980.0

# --- ESTADOS DO COELHO ---
enum Estado { CORRENDO, PARADO, PULANDO }
var estado_atual: Estado = Estado.CORRENDO

# --- NÓS DO COELHO ---
@onready var raycast_obstaculo: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# IMPORTANTE: Permite que o RayCast detecte tanto corpos quanto áreas (Area2D)
	raycast_obstaculo.collide_with_areas = true
	raycast_obstaculo.collide_with_bodies = true

func _physics_process(delta):
	# Aplica gravidade se não estiver no chão
	if not is_on_floor():
		velocity.y += gravidade * delta

	match estado_atual:
		Estado.CORRENDO:
			velocity.x = velocidade_corrida
			
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("correr"):
				sprite.play("correr")
			
			# 1. Pulo automático de relevo ao bater em blocos normais (Chão)
			if is_on_wall() and is_on_floor():
				velocity.y = força_pulo_degrau

			# 2. Detecta OBSTÁCULOS REAIS na Camada 2 (Area2D ou StaticBody2D)
			if raycast_obstaculo.is_colliding():
				parar_no_obstaculo()

		Estado.PARADO:
			velocity.x = 0
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("parado"):
				sprite.play("parado")

		Estado.PULANDO:
			velocity.x = velocidade_corrida
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("pular"):
				sprite.play("pular")
			
			if is_on_floor() and velocity.y >= 0:
				estado_atual = Estado.CORRENDO

	move_and_slide()

# --- FUNÇÕES DE CONTROLE ---

func parar_no_obstaculo():
	if estado_atual != Estado.PARADO:
		estado_atual = Estado.PARADO
		print("Obstáculo real detectado! Coelho parou para digitar.")

func pular_obstaculo_automaticamente():
	if estado_atual == Estado.PARADO:
		velocity.y = força_pulo_obstaculo
		estado_atual = Estado.PULANDO
