extends Control

# --- REFERÊNCIAS ---
@onready var container: VBoxContainer = $CreditosContainer

# --- CONFIGURAÇÕES ---
@export var velocidade_rolagem: float = 65.0 # Pixels por segundo
var rolando: bool = false

func _ready():
	modulate.a = 0.0
	
	# Aguarda 1 frame para o Godot calcular os tamanhos reais da logo e do texto
	await get_tree().process_frame
	
	var largura_tela = get_viewport_rect().size.x
	var altura_tela = get_viewport_rect().size.y
	
	# Centraliza o bloco inteiro (Logo + Texto) na horizontal
	container.global_position.x = (largura_tela / 2.0) - (container.size.x / 2.0)
	
	# Posiciona o topo do container logo abaixo do limite da tela
	container.global_position.y = altura_tela
	
	# Fade In inicial da tela
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	await tween.finished
	
	rolando = true

func _process(delta):
	if rolando:
		# Sobe a logo e o texto juntos continuamente
		container.global_position.y -= velocidade_rolagem * delta
		
		# Quando a base do container passar do topo da tela
		if container.global_position.y < -container.size.y:
			rolando = false
			voltar_ao_menu()

func _input(event):
	# Pula os créditos se pressionar ESC, Espaço ou Enter
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_accept"):
		voltar_ao_menu()

func voltar_ao_menu():
	rolando = false
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	await tween.finished
	get_tree().change_scene_to_file("res://menu.tscn")
