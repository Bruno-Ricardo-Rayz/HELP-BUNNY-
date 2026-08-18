extends Control

# Lista com os vídeos em ordem
@export var lista_videos: Array[VideoStream] = [
	preload("res://video1.ogv"),
	preload("res://video2.ogv"),
	preload("res://video3.ogv")
]

var indice_video_atual: int = 0

# --- REFERÊNCIAS ---
@onready var video_player: VideoStreamPlayer = $VideoStreamPlayer
@onready var color_rect: ColorRect = $ColorRect
@onready var timer_troca: Timer = $Timer

func _ready():
	# Conecta o sinal do Timer para trocar a cada 30 segundos
	timer_troca.timeout.connect(_on_timer_troca_timeout)
	
	# Inicia o primeiro vídeo da lista
	if lista_videos.size() > 0:
		video_player.stream = lista_videos[0]
		video_player.play()
	
	# Garante que a tela comece transparente
	color_rect.modulate.a = 0.0

func _on_timer_troca_timeout():
	trocar_video_com_fade()

func trocar_video_com_fade():
	# 1. ESCURECE A TELA (Fade Out de 1.5s)
	var tween_fade_out = create_tween()
	tween_fade_out.tween_property(color_rect, "modulate:a", 1.0, 1.5)
	
	await tween_fade_out.finished
	
	# 2. AVANÇA PARA O PRÓXIMO VÍDEO
	indice_video_atual = (indice_video_atual + 1) % lista_videos.size()
	video_player.stream = lista_videos[indice_video_atual]
	video_player.play()
	
	# 3. CLAREIA A TELA (Fade In de 1.5s)
	var tween_fade_in = create_tween()
	tween_fade_in.tween_property(color_rect, "modulate:a", 0.0, 1.5)
