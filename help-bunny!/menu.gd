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
	
	# Fade in inicial
	color_rect.color.a = 1.0
	
	for i in range(players.size()):
		if i == 0:
			players[i].show()
			players[i].play()
		else:
			players[i].hide()
	
	var tween_inicial = create_tween()
	tween_inicial.tween_property(color_rect, "color:a", 0.0, 0.8)
	
	# Inicia animações da UI
	iniciar_animacao_cenoura()
	iniciar_animacao_logo()
	
	# Centraliza a logo no topo
	centralizar_logo()
	
	# Posiciona o ícone do coelhinho no canto inferior direito sobre a IA
	posicionar_icone_ia()
	
	# Posiciona a cenoura no primeiro botão
	if is_instance_valid(btn_continuar):
		posicionar_cenoura_no_botao(btn_continuar)
	elif is_instance_valid(btn_novo_jogo):
		posicionar_cenoura_no_botao(btn_novo_jogo)

# --- POSICIONAMENTO DO ÍCONE IA ---

func posicionar_icone_ia():
	if is_instance_valid(icone_ia):
		icone_ia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icone_ia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		# Aumenta ainda mais a caixa para esconder a marca d'água por completo
		icone_ia.size = Vector2(550, 550)
		
		# Reposiciona para cobrir a área expandida no canto
		icone_ia.global_position = Vector2(850, 330)
		
		icone_ia.show()
		icone_ia.move_to_front()

# --- AJUSTE E ANIMAÇÃO DA LOGO ---

func centralizar_logo():
	if is_instance_valid(logo):
		# Centraliza horizontalmente na tela de 1152px
		var largura_tela = get_viewport_rect().size.x
		var largura_logo = logo.size.x * logo.scale.x
		logo.global_position.x = (largura_tela / 2.0) - (largura_logo / 2.0)
		logo.global_position.y = 20.0 # Altura do topo

func iniciar_animacao_logo():
	if not is_instance_valid(logo):
		return
		
	if tween_pulsar_logo:
		tween_pulsar_logo.kill()
		
	tween_pulsar_logo = create_tween().set_loops()
	# Pulsa a logo maior (escala entre 0.8 e 0.84)
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
		players[indice_atual].play()

func trocar_video_com_transicao():
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween_out.finished
	
	players[indice_atual].hide()
	players[indice_atual].stop()
	
	indice_atual = (indice_atual + 1) % players.size()
	
	players[indice_atual].show()
	players[indice_atual].play()
	
	await get_tree().create_timer(0.2).timeout
	
	var tween_in = create_tween()
	tween_in.tween_property(color_rect, "color:a", 0.0, 0.5)

# --- CLIQUE DOS BOTÕES ---

func _on_btn_novo_jogo_pressed():
	var tween = create_tween()
	tween.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween.finished
	get_tree().change_scene_to_file("res://LEVEL 1.tscn")

func _on_btn_continuar_pressed():
	print("Continuar clicado")

func _on_btn_creditos_pressed():
	print("Créditos clicado")

func _on_btn_sair_pressed():
	get_tree().quit()
