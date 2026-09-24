extends CharacterBody2D

# --- CONFIGURAÇÕES DE MOVIMENTO ---
@export var velocidade_corrida: float = 450.0
@export var velocidade_boost: float = 700.0

# --- AJUSTES DE PULO DOS OBSTÁCULOS ---
@export var força_pulo_degrau: float = -480.0     
@export var força_pulo_obstaculo: float = -620.0  
@export var impulso_horizontal_pulo: float = 600.0 
@export var gravidade: float = 980.0

# --- SISTEMA DE BOOST ---
var boost_ativo: bool = false
var chance_boost: float = 0.05  # Começa em 5%
const CHANCE_MINIMA: float = 0.05
const CHANCE_MAXIMA: float = 0.15 
var timer_boost: Timer
var tween_piscar: Tween
var boost_recupera_vida: bool = true 
var pausado_para_pulo_boost: bool = false 

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
	
	# Configura o Timer do Boost para 5 segundos
	timer_boost = Timer.new()
	timer_boost.wait_time = 5.0
	timer_boost.one_shot = true
	timer_boost.timeout.connect(_on_boost_terminou)
	add_child(timer_boost)
	
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
			velocity.x = velocidade_boost if boost_ativo else velocidade_corrida
			
			if not tocando_hurt:
				tocar_animacao("run")
			
			if is_on_wall() and is_on_floor():
				velocity.y = força_pulo_degrau
				if is_instance_valid(som_pulo):
					som_pulo.play()

			if raycast_obstaculo.is_colliding():
				if boost_ativo:
					pular_obstaculo_com_pausa_boost()
				else:
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

# --- LÓGICA DE PAUSA DO BOOST NO OBSTÁCULO ---

func pular_obstaculo_com_pausa_boost():
	if pausado_para_pulo_boost:
		return
		
	pausado_para_pulo_boost = true
	estado_atual = Estado.PARADO
	tocar_animacao("idle")
	
	await get_tree().create_timer(0.5).timeout
	
	pular_obstaculo_automaticamente()
	pausado_para_pulo_boost = false

# --- LÓGICA DE CHANCE E ATIVAÇÃO DO BOOST ---

func ao_acertar_palavra():
	var sorteio = randf()

	if sorteio <= chance_boost and not boost_ativo:
		ativar_boost()
	else:
		if chance_boost < CHANCE_MAXIMA:
			chance_boost = min(chance_boost + 0.10, CHANCE_MAXIMA)

func ativar_boost():
	boost_ativo = true
	chance_boost = CHANCE_MINIMA  # Reseta para 5%
	timer_boost.start()
	
	iniciar_efeito_piscar()

	if boost_recupera_vida:
		recuperar_vida(1)
		
	boost_recupera_vida = not boost_recupera_vida
	
	# Esconde a palavra na UI durante o boost
	get_tree().call_group("hud", "esconder_palavra_boost")
	
	if estado_atual == Estado.PARADO:
		pular_obstaculo_com_pausa_boost()
	else:
		estado_atual = Estado.CORRENDO

func _on_boost_terminou():
	boost_ativo = false
	parar_efeito_piscar()
	# Volta a mostrar a palavra assim que o boost acaba
	get_tree().call_group("hud", "iniciar_desafio_digitacao")

# --- EFEITO VISUAL PISCAR (VERDE / BRANCO / AZUL) ---

func iniciar_efeito_piscar():
	parar_efeito_piscar()
	
	tween_piscar = create_tween().set_loops()
	tween_piscar.tween_property(sprite, "modulate", Color(0.2, 1.0, 0.3, 1.0), 0.1) # Verde
	tween_piscar.tween_property(sprite, "modulate", Color.WHITE, 0.1)             # Branco
	tween_piscar.tween_property(sprite, "modulate", Color(0.2, 0.5, 1.0, 1.0), 0.1) # Azul
	tween_piscar.tween_property(sprite, "modulate", Color.WHITE, 0.1)             # Branco

func parar_efeito_piscar():
	if tween_piscar and tween_piscar.is_running():
		tween_piscar.kill()
	if sprite:
		sprite.modulate = Color.WHITE

# --- FUNÇÕES DE CONTROLE ---

func parar_no_obstaculo():
	if estado_atual != Estado.PARADO and estado_atual != Estado.CHECKPOINT and estado_atual != Estado.DORMINDO:
		estado_atual = Estado.PARADO

func pular_obstaculo_automaticamente():
	# Garante que só pula se estiver no chão (evita o pulo no ar)
	if (estado_atual == Estado.PARADO or boost_ativo) and is_on_floor():
		velocity.y = força_pulo_obstaculo
		velocity.x = impulso_horizontal_pulo
		estado_atual = Estado.PULANDO
		
		if is_instance_valid(som_pulo):
			som_pulo.play()
		
		if GameData:
			GameData.tem_checkpoint = true

# --- SISTEMA DE DANO, VIDA E DERROTA ---

func tomar_dano(quantidade: int = 1):
	if boost_ativo:
		return

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
				
			get_tree().call_group("hud", "atualizar_ui_vida", true)

func morrer():
	if estado_atual == Estado.MORTO:
		return
		
	estado_atual = Estado.MORTO
	velocity = Vector2.ZERO
	parar_efeito_piscar()
	tocar_animacao("dead")
	Engine.time_scale = 1.0

func pausar_por_tempo(tempo_segundos: float = 2.0):
	estado_atual = Estado.CHECKPOINT
	tocar_animacao("attack")
	
	await get_tree().create_timer(tempo_segundos).timeout
	
	if estado_atual == Estado.CHECKPOINT:
		estado_atual = Estado.CORRENDO

func tocar_animacao(nome_animacao: String):
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation(nome_animacao):
		if sprite.animation != nome_animacao:
			sprite.play(nome_animacao)
