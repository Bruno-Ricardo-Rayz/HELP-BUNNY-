extends Area2D

@export var velocidade: float = 200.0
@export var dano: int = 1
@export var tempo_digitacao: float = 3.0

# --- SOM DO PROJÉTIL ---
@export var som_disparo: AudioStream

var eh_fogo: bool = false
var ativo: bool = true
var tempo_vida: float = 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	# Conecta os sinais de colisão via código
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

	# Toca a animação correspondente
	if sprite:
		if eh_fogo:
			dano = 2
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("carrot fire"):
				sprite.play("carrot fire")
		else:
			if sprite.sprite_frames and sprite.sprite_frames.has_animation("carrot"):
				sprite.play("carrot")

	# Toca o áudio de disparo assim que a cenoura é criada
	tocar_som_disparo()

func _process(delta):
	tempo_vida += delta
	if ativo:
		# Movimenta a cenoura para a esquerda calculando a velocidade real
		var delta_real = delta / Engine.time_scale if Engine.time_scale > 0 else delta
		position.x -= velocidade * delta_real

# --- LÓGICA DE ÁUDIO DO DISPARO ---

func tocar_som_disparo():
	if som_disparo:
		# Cria um nó de áudio temporário na raiz do jogo para que o som continue 
		# tocando até o fim mesmo se a cenoura for destruída ou pausada pelo desafio
		var player_audio = AudioStreamPlayer.new()
		player_audio.stream = som_disparo
		player_audio.bus = "Master"
		
		get_tree().root.add_child(player_audio)
		player_audio.play()
		
		# Libera o nó de áudio da memória assim que terminar de tocar
		player_audio.finished.connect(player_audio.queue_free)

# --- DETECÇÃO DE COLISÃO ---

func _on_body_entered(body):
	if not ativo or tempo_vida < 0.1:
		return

	# Ignora colisão com o chão/cenário e spawner
	if body is TileMap or body is TileMapLayer or body.name.begins_with("Spawner") or body.is_in_group("spawner"):
		return

	# Verifica se atingiu o Player
	if body.is_in_group("player") or body.name == "Player":
		impactar_player()

func _on_area_entered(area):
	if not ativo or tempo_vida < 0.1:
		return

	# Ignora colisões com áreas do próprio spawner ou cenário
	if area.is_in_group("spawner") or area.name.begins_with("Spawner"):
		return

	# Se a área for do Player ou filha dele
	if area.is_in_group("player") or area.get_parent().is_in_group("player"):
		impactar_player()

func impactar_player():
	ativo = false
	var hud = get_tree().get_first_node_in_group("hud")
	
	if hud and hud.has_method("iniciar_desafio_projetil"):
		hud.iniciar_desafio_projetil(self, tempo_digitacao, dano)

func destruir_projetil():
	queue_free()
