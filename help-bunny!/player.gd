extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTO ---
@export var velocidade_corrida: float = 450.0
@export var força_pulo_degrau: float = -480.0     # Pulo curto para subir degraus
@export var força_pulo_obstaculo: float = -650.0  # Altura do pulo para superar o buraco
@export var impulso_horizontal_pulo: float = 520.0 # Distância para frente para atravessar o vão
@export var gravidade: float = 980.0

# --- ESTADOS DO COELHO ---
enum Estado { DORMINDO, CORRENDO, PARADO, PULANDO, CHECKPOINT, MORTO }
var estado_atual: Estado = Estado.DORMINDO

# --- VARIÁVEIS DE CONTROLE DE ANIMAÇÃO ---
var acordando: bool = false
var tocando_hurt: bool = false

# --- NÓS DO COELHO ---
@onready var raycast_obstaculo: RayCast2D = $RayCast2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var som_pulo: AudioStreamPlayer = $SomPulo
@onready var som_perdendo_vida: AudioStreamPlayer = $PerdendoVida
@onready var som_recuperando_vida: AudioStreamPlayer = $RecuperandoVida

func _ready():
	add_to_group("player")
	
	raycast_obstaculo.collide_with_areas = true
	raycast_obstaculo.collide_with_bodies = true
	
	if GameData:
		GameData.fase_atual = get_tree().current_scene.scene_file_path
		
		if GameData.tem_checkpoint and GameData.pos_checkpoint != Vector2.ZERO:
			global_position = GameData.pos_checkpoint
			estado_atual = Estado.CORRENDO
		else:
			iniciar_sequencia_acordar()

func iniciar_sequencia_acordar():
	estado_atual = Estado.DORMINDO
	acordando = true
	tocar_animacao("sleep")
	
	await get_tree().create_timer(1.0).timeout
	tocar_animacao("despertando")
	
	await get_tree().create_timer(0.6).timeout
	tocar_animacao("desperto")
	
	await get_tree().create_timer(0.6).timeout
	tocar_animacao("idle")
	
	await get_tree().create_timer(0.5).timeout
	acordando = false
	estado_atual = Estado.CORRENDO

func _physics_process(delta):
	if estado_atual == Estado.MORTO:
		return

	if not is_on_floor():
		velocity.y += gravidade * delta

	match estado_atual:
		Estado.DORMINDO:
			velocity.x = 0

		Estado.CORRENDO:
			velocity.x = velocidade_corrida
			
			if not tocando_hurt:
				tocar_animacao("run")
			
			if is_on_wall() and is_on_floor():
				velocity.y = força_pulo_degrau
				if is_instance_valid(som_pulo):
					som_pulo.play()

			if raycast_obstaculo.is_colliding():
				parar_no_obstaculo()

		Estado.PARADO:
			velocity.x = 0
			if not tocando_hurt:
				tocar_animacao("idle")

		Estado.PULANDO:
			velocity.x = impulso_horizontal_pulo
			
			if not tocando_hurt:
				tocar_animacao("jump")
			
			if is_on_floor() and velocity.y >= 0:
				estado_atual = Estado.CORRENDO

		Estado.CHECKPOINT:
			velocity.x = 0
			tocar_animacao("attack")

	move_and_slide()

# --- FUNÇÕES DE CONTROLE ---

func parar_no_obstaculo():
	if estado_atual != Estado.PARADO and estado_atual != Estado.CHECKPOINT and estado_atual != Estado.DORMINDO:
		estado_atual = Estado.PARADO

func pular_obstaculo_automaticamente():
	if estado_atual == Estado.PARADO:
		velocity.y = força_pulo_obstaculo
		velocity.x = impulso_horizontal_pulo
		estado_atual = Estado.PULANDO
		
		if is_instance_valid(som_pulo):
			som_pulo.play()
		
		if GameData:
			GameData.tem_checkpoint = true

# --- SISTEMA DE DANO, VIDA E DERROTA ---

func tomar_dano(quantidade: int = 1):
	if GameData:
		GameData.vida_atual -= quantidade
		if GameData.vida_atual < 0:
			GameData.vida_atual = 0

	if is_instance_valid(som_perdendo_vida):
		som_perdendo_vida.play()

	tocando_hurt = true
	tocar_animacao("hurt")
	
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(2.0, 0.2, 0.2, 1.0), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	await get_tree().create_timer(0.4).timeout
	tocando_hurt = false

	if GameData and GameData.vida_atual <= 0:
		morrer()

func recuperar_vida(quantidade: int = 1):
	if GameData:
		if GameData.vida_atual < GameData.vida_maxima:
			GameData.vida_atual = min(GameData.vida_atual + quantidade, GameData.vida_maxima)
			
			if is_instance_valid(som_recuperando_vida):
				som_recuperando_vida.play()

func morrer():
	if estado_atual == Estado.MORTO:
		return
		
	estado_atual = Estado.MORTO
	velocity = Vector2.ZERO
	tocar_animacao("dead")
	Engine.time_scale = 1.0

# --- PAUSA DE CHECKPOINT ---

func pausar_por_tempo(tempo_segundos: float = 2.0):
	estado_atual = Estado.CHECKPOINT
	tocar_animacao("attack")
	
	await get_tree().create_timer(tempo_segundos).timeout
	
	if estado_atual == Estado.CHECKPOINT:
		estado_atual = Estado.CORRENDO

# --- FUNÇÃO AUXILIAR PARA TROCA DE ANIMAÇÕES ---

func tocar_animacao(nome_animacao: String):
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(nome_animacao):
		if sprite.animation != nome_animacao:
			sprite.play(nome_animacao)
