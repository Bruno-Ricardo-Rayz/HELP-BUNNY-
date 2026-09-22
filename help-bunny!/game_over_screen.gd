extends Control

@onready var titulo: Label = find_child("Titulo", true, false)

func _ready() -> void:
	# Permite que este menu e seus botões continuem rodando mesmo quando o jogo for pausado
	process_mode = PROCESS_MODE_ALWAYS
	
	# Busca os botões dentro de toda a estrutura da cena de forma segura
	var btn_tentar = find_child("BtnTentar", true, false)
	var btn_sair = find_child("BtnSair", true, false)
	
	# Conecta os sinais de clique do botão Tentar Novamente
	if btn_tentar:
		if not btn_tentar.pressed.is_connected(_on_btn_tentar_pressed):
			btn_tentar.pressed.connect(_on_btn_tentar_pressed)
			
	# Conecta os sinais de clique do botão Sair do Jogo
	if btn_sair:
		if not btn_sair.pressed.is_connected(_on_btn_sair_pressed):
			btn_sair.pressed.connect(_on_btn_sair_pressed)

	# Inicia o efeito do título piscar suavemente
	iniciar_pisca_titulo()

	# Espera exatamente 4 segundos em tempo real antes de pausar a física e o tempo do jogo
	await get_tree().create_timer(4.0, false).timeout
	get_tree().paused = true

func iniciar_pisca_titulo() -> void:
	var label_titulo = titulo if titulo else find_child("Titulo", true, false)
	if not label_titulo:
		return
		
	# Cor inicial vermelha
	label_titulo.add_theme_color_override("font_color", Color.RED)
	
	# Cria um Tween infinito para transição suave de cores
	var tween = create_tween().set_loops()
	
	# 1. Mantém vermelho prevalecente (espera 1.2 segundos em vermelho)
	tween.tween_interval(1.2)
	
	# 2. Transita lentamente de Vermelho para Branco (leva 0.8 segundos)
	tween.tween_property(label_titulo, "theme_override_colors/font_color", Color.WHITE, 0.8)
	
	# 3. Permanece brevemente em Branco (0.2 segundos)
	tween.tween_interval(0.2)
	
	# 4. Retorna lentamente de Branco para Vermelho (leva 0.8 segundos)
	tween.tween_property(label_titulo, "theme_override_colors/font_color", Color.RED, 0.8)

func _on_btn_tentar_pressed() -> void:
	# 1. Reseta a vida no GameData (se a sua autoload de dados existir)
	if GameData and "vida_maxima" in GameData and "vida_atual" in GameData:
		GameData.vida_atual = GameData.vida_maxima

	# 2. Despausa o jogo para que a fase recarregada não nasça congelada
	get_tree().paused = false

	# 3. Transição ou recarregamento direto da cena atual
	if typeof(Transition) != TYPE_NIL and Transition.has_method("ir_para"):
		Transition.ir_para("reiniciar")
	else:
		get_tree().reload_current_scene()

func _on_btn_sair_pressed() -> void:
	# Despausa o jogo para liberar a troca de cena
	get_tree().paused = false

	# Muda para a cena do menu principal
	if typeof(Transition) != TYPE_NIL and Transition.has_method("ir_para"):
		Transition.ir_para("res://menu.tscn")
	else:
		get_tree().change_scene_to_file("res://menu.tscn")
