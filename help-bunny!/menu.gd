extends Control

# --- REFERÊNCIAS DOS NÓS ---
@onready var p1: VideoStreamPlayer = $VideoStreamPlayer1
@onready var p2: VideoStreamPlayer = $VideoStreamPlayer2
@onready var p3: VideoStreamPlayer = $VideoStreamPlayer3
@onready var color_rect: ColorRect = $ColorRect

@onready var btn_novo_jogo: Button = $UI/VBoxContainer/BtnNovoJogo
@onready var btn_continuar: Button = $UI/VBoxContainer/BtnContinuar
@onready var btn_creditos: Button = $UI/VBoxContainer/BtnCreditos
@onready var btn_sair: Button = $UI/VBoxContainer/BtnSair
@onready var cenoura: TextureRect = $UI/CenouraIcone
@onready var logo: TextureRect = $UI/LogoMenu
@onready var icone_ia: TextureRect = $UI/IconeIA

# --- VARIÁVEIS DE CONTROLE ---
var players = []
var indice_atual: int = 0
var repeticoes: int = 0
var tween_pulsar_cenoura: Tween
var tween_pulsar_logo: Tween

func _ready():
	players = [p1, p2, p3]
	
	# Desativa a captura de mouse em imagens decorativas para não bloquear os botões
	configurar_filtros_mouse()
	
	# Fade in inicial suave usando o ColorRect local do menu
	if is_instance_valid(color_rect):
		color_rect.color.a = 1.0
		var tween_inicial = create_tween()
		tween_inicial.tween_property(color_rect, "color:a", 0.0, 0.8)
	
	# Inicializa reprodutores de vídeo
	for i in range(players.size()):
		if is_instance_valid(players[i]):
			if i == 0:
				players[i].show()
				players[i].play()
			else:
				players[i].hide()
	
	# Conectando sinais dos botões via código para segurança
	conectar_sinais_botoes()
	
	# Inicia animações da UI
	iniciar_animacao_cenoura()
	iniciar_animacao_logo()
	
	# Centraliza a logo e posiciona ícones
	centralizar_logo()
	posicionar_icone_ia()
	
	# Desabilita o botão continuar se não houver checkpoint salvo no GameData
	if is_instance_valid(btn_continuar):
		btn_continuar.disabled = not GameData.tem_checkpoint
	
	# Posiciona a cenoura no primeiro botão ativo
	if is_instance_valid(btn_continuar) and not btn_continuar.disabled:
		posicionar_cenoura_no_botao(btn_continuar)
	elif is_instance_valid(btn_novo_jogo):
		posicionar_cenoura_no_botao(btn_novo_jogo)

# --- GARANTE QUE NENHUMA IMAGEM BLOQUEIE O MOUSE ---

func configurar_filtros_mouse():
	if is_instance_valid(icone_ia):
		icone_ia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(cenoura):
		cenoura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(logo):
		logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_instance_valid(color_rect):
		color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

# --- CONEXÃO AUTOMÁTICA DE SINAIS ---

func conectar_sinais_botoes():
	if is_instance_valid(btn_novo_jogo):
		if not btn_novo_jogo.pressed.is_connected(_on_btn_novo_jogo_pressed):
			btn_novo_jogo.pressed.connect(_on_btn_novo_jogo_pressed)
		if not btn_novo_jogo.mouse_entered.is_connected(_on_btn_novo_jogo_mouse_entered):
			btn_novo_jogo.mouse_entered.connect(_on_btn_novo_jogo_mouse_entered)
			
	if is_instance_valid(btn_continuar):
		if not btn_continuar.pressed.is_connected(_on_btn_continuar_pressed):
			btn_continuar.pressed.connect(_on_btn_continuar_pressed)
		if not btn_continuar.mouse_entered.is_connected(_on_btn_continuar_mouse_entered):
			btn_continuar.mouse_entered.connect(_on_btn_continuar_mouse_entered)
			
	if is_instance_valid(btn_creditos):
		if not btn_creditos.pressed.is_connected(_on_btn_creditos_pressed):
			btn_creditos.pressed.connect(_on_btn_creditos_pressed)
		if not btn_creditos.mouse_entered.is_connected(_on_btn_creditos_mouse_entered):
			btn_creditos.mouse_entered.connect(_on_btn_creditos_mouse_entered)
			
	if is_instance_valid(btn_sair):
		if not btn_sair.pressed.is_connected(_on_btn_sair_pressed):
			btn_sair.pressed.connect(_on_btn_sair_pressed)
		if not btn_sair.mouse_entered.is_connected(_on_btn_sair_mouse_entered):
			btn_sair.mouse_entered.connect(_on_btn_sair_mouse_entered)

# --- POSICIONAMENTO DO ÍCONE IA ---

func posicionar_icone_ia():
	if is_instance_valid(icone_ia):
		icone_ia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone_ia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icone_ia.size = Vector2(620, 620)
		icone_ia.global_position = Vector2(810, 280)
		icone_ia.show()

# --- AJUSTE E ANIMAÇÃO DA LOGO ---

func centralizar_logo():
	if is_instance_valid(logo):
		var largura_tela = get_viewport_rect().size.x
		var largura_logo = logo.size.x * logo.scale.x
		logo.global_position.x = (largura_tela / 2.0) - (largura_logo / 2.0)
		logo.global_position.y = 20.0

func iniciar_animacao_logo():
	if not is_instance_valid(logo):
		return
		
	if tween_pulsar_logo:
		tween_pulsar_logo.kill()
		
	tween_pulsar_logo = create_tween().set_loops()
	tween_pulsar_logo.tween_property(logo, "scale", Vector2(0.84, 0.84), 0.8).set_trans(Tween.TRANS_SINE)
	tween_pulsar_logo.tween_property(logo, "scale", Vector2(0.8, 0.8), 0.8).set_trans(Tween.TRANS_SINE)

# --- SISTEMA DA CENOURA ---

func iniciar_animacao_cenoura():
	if not is_instance_valid(cenoura):
		return
		
	if tween_pulsar_cenoura:
		tween_pulsar_cenoura.kill()
		
	tween_pulsar_cenoura = create_tween().set_loops()
	tween_pulsar_cenoura.tween_property(cenoura, "scale", Vector2(0.115, 0.115), 0.5).set_trans(Tween.TRANS_SINE)
	tween_pulsar_cenoura.tween_property(cenoura, "scale", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_SINE)

func posicionar_cenoura_no_botao(botao: Button):
	if not is_instance_valid(botao) or not is_instance_valid(cenoura):
		return
		
	var altura_cenoura_real = cenoura.size.y * cenoura.scale.y
	var centro_y_botao = botao.global_position.y + (botao.size.y / 2.0)
	
	var pos_destino = Vector2(
		20.0,
		centro_y_botao - (altura_cenoura_real / 2.0)
	)
	
	var tween_pos = create_tween()
	tween_pos.tween_property(cenoura, "global_position", pos_destino, 0.15).set_trans(Tween.TRANS_QUAD)

# --- SINAIS DE HOVER (MOUSE ENTERED) ---

func _on_btn_continuar_mouse_entered():
	if is_instance_valid(btn_continuar) and not btn_continuar.disabled:
		posicionar_cenoura_no_botao(btn_continuar)

func _on_btn_novo_jogo_mouse_entered():
	posicionar_cenoura_no_botao(btn_novo_jogo)

func _on_btn_creditos_mouse_entered():
	posicionar_cenoura_no_botao(btn_creditos)

func _on_btn_sair_mouse_entered():
	posicionar_cenoura_no_botao(btn_sair)

# --- TROCA DE VÍDEOS COM FADE ---

func _on_timer_timeout():
	repeticoes += 1
	if repeticoes >= 2:
		repeticoes = 0
		trocar_video_com_transicao()
	else:
		if is_instance_valid(players[indice_atual]):
			players[indice_atual].play()

func trocar_video_com_transicao():
	if is_instance_valid(color_rect):
		var tween_out = create_tween()
		tween_out.tween_property(color_rect, "color:a", 1.0, 0.5)
		await tween_out.finished
	
	if is_instance_valid(players[indice_atual]):
		players[indice_atual].hide()
		players[indice_atual].stop()
	
	indice_atual = (indice_atual + 1) % players.size()
	
	if is_instance_valid(players[indice_atual]):
		players[indice_atual].show()
		players[indice_atual].play()
	
	await get_tree().create_timer(0.2).timeout
	
	if is_instance_valid(color_rect):
		var tween_in = create_tween()
		tween_in.tween_property(color_rect, "color:a", 0.0, 0.5)

# --- CLIQUE DOS BOTÕES (USANDO TRANSITION AUTOMÁTICO) ---

func _on_btn_novo_jogo_pressed():
	if GameData:
		GameData.resetar_checkpoint_para_nova_fase("res://LEVEL 1.tscn")
	
	if Transition:
		Transition.ir_para("res://LEVEL 1.tscn")
	else:
		get_tree().change_scene_to_file("res://LEVEL 1.tscn")

func _on_btn_continuar_pressed():
	if GameData and GameData.tem_checkpoint and GameData.fase_atual != "":
		if Transition:
			Transition.ir_para(GameData.fase_atual)
		else:
			get_tree().change_scene_to_file(GameData.fase_atual)

func _on_btn_creditos_pressed():
	if Transition:
		Transition.ir_para("res://creditos.tscn")
	else:
		get_tree().change_scene_to_file("res://creditos.tscn")

func _on_btn_sair_pressed():
	get_tree().quit()
