extends Control
class_name MenuPrincipal

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

@onready var som_clique_padrao: AudioStreamPlayer = $SomCliquePadrao
@onready var som_clique_creditos: AudioStreamPlayer = $SomCliqueCreditos

var players: Array[VideoStreamPlayer] = []
var indice_atual: int = 0
var repeticoes: int = 0
var tween_pulsar_cenoura: Tween
var tween_pulsar_logo: Tween

func _ready() -> void:
	GerenciadorMusica.iniciar_playlist()

	players = [p1, p2, p3]
	configurar_filtros_mouse()
	conectar_sinais_botoes()
	
	color_rect.color.a = 1.0
	create_tween().tween_property(color_rect, "color:a", 0.0, 0.8)
	
	for i in range(players.size()):
		players[i].visible = (i == 0)
	players[0].play()
	
	iniciar_animacao_cenoura()
	iniciar_animacao_logo()
	centralizar_logo()
	posicionar_icone_ia()
	
	btn_continuar.disabled = not GameData.tem_checkpoint
	
	if not btn_continuar.disabled:
		posicionar_cenoura_no_botao(btn_continuar)
	else:
		posicionar_cenoura_no_botao(btn_novo_jogo)

func configurar_filtros_mouse() -> void:
	icone_ia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cenoura.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

func conectar_sinais_botoes() -> void:
	# Verifica se a conexão já não foi feita visualmente no editor antes de forçar no código
	if not btn_novo_jogo.pressed.is_connected(_on_btn_novo_jogo_pressed):
		btn_novo_jogo.pressed.connect(_on_btn_novo_jogo_pressed)
		
	if not btn_continuar.pressed.is_connected(_on_btn_continuar_pressed):
		btn_continuar.pressed.connect(_on_btn_continuar_pressed)
		
	if not btn_creditos.pressed.is_connected(_on_btn_creditos_pressed):
		btn_creditos.pressed.connect(_on_btn_creditos_pressed)
		
	if not btn_sair.pressed.is_connected(_on_btn_sair_pressed):
		btn_sair.pressed.connect(_on_btn_sair_pressed)

	# Os sinais de hover (mouse_entered) continuamos conectando via código usando .bind()
	if not btn_novo_jogo.mouse_entered.is_connected(posicionar_cenoura_no_botao):
		btn_novo_jogo.mouse_entered.connect(posicionar_cenoura_no_botao.bind(btn_novo_jogo))
		btn_continuar.mouse_entered.connect(posicionar_cenoura_no_botao.bind(btn_continuar))
		btn_creditos.mouse_entered.connect(posicionar_cenoura_no_botao.bind(btn_creditos))
		btn_sair.mouse_entered.connect(posicionar_cenoura_no_botao.bind(btn_sair))
		
func posicionar_icone_ia() -> void:
	icone_ia.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icone_ia.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icone_ia.size = Vector2(620, 620)
	icone_ia.global_position = Vector2(810, 280)
	icone_ia.show()

func centralizar_logo() -> void:
	var largura_tela = get_viewport_rect().size.x
	var largura_logo = logo.size.x * logo.scale.x
	logo.global_position = Vector2((largura_tela / 2.0) - (largura_logo / 2.0), 20.0)

func iniciar_animacao_logo() -> void:
	if tween_pulsar_logo: tween_pulsar_logo.kill()
	
	tween_pulsar_logo = create_tween().set_loops()
	tween_pulsar_logo.tween_property(logo, "scale", Vector2(0.84, 0.84), 0.8).set_trans(Tween.TRANS_SINE)
	tween_pulsar_logo.tween_property(logo, "scale", Vector2(0.8, 0.8), 0.8).set_trans(Tween.TRANS_SINE)

func iniciar_animacao_cenoura() -> void:
	if tween_pulsar_cenoura: tween_pulsar_cenoura.kill()
		
	tween_pulsar_cenoura = create_tween().set_loops()
	tween_pulsar_cenoura.tween_property(cenoura, "scale", Vector2(0.115, 0.115), 0.5).set_trans(Tween.TRANS_SINE)
	tween_pulsar_cenoura.tween_property(cenoura, "scale", Vector2(0.1, 0.1), 0.5).set_trans(Tween.TRANS_SINE)

func posicionar_cenoura_no_botao(botao: Button) -> void:
	if botao.disabled: return 
		
	var altura_cenoura_real = cenoura.size.y * cenoura.scale.y
	var centro_y_botao = botao.global_position.y + (botao.size.y / 2.0)
	var pos_destino = Vector2(20.0, centro_y_botao - (altura_cenoura_real / 2.0))
	
	create_tween().tween_property(cenoura, "global_position", pos_destino, 0.15).set_trans(Tween.TRANS_QUAD)

func _on_timer_timeout() -> void: 
	repeticoes += 1
	if repeticoes >= 2:
		repeticoes = 0
		trocar_video_com_transicao()
	else:
		players[indice_atual].play()

func trocar_video_com_transicao() -> void:
	var tween_out = create_tween()
	tween_out.tween_property(color_rect, "color:a", 1.0, 0.5)
	await tween_out.finished
	
	players[indice_atual].hide()
	players[indice_atual].stop()
	
	indice_atual = (indice_atual + 1) % players.size()
	
	players[indice_atual].show()
	players[indice_atual].play()
	
	await get_tree().create_timer(0.2).timeout
	create_tween().tween_property(color_rect, "color:a", 0.0, 0.5)

func tocar_som_e_esperar(som: AudioStreamPlayer, tempo: float = 0.15) -> void:
	som.play()
	await get_tree().create_timer(tempo).timeout

func mudar_cena(caminho: String) -> void:
	Transition.ir_para(caminho)

func _on_btn_novo_jogo_pressed() -> void:
	GerenciadorMusica.parar_playlist()
	await tocar_som_e_esperar(som_clique_padrao)
	mudar_cena("res://tutorial.tscn")

func _on_btn_continuar_pressed() -> void:
	GerenciadorMusica.parar_playlist()
	await tocar_som_e_esperar(som_clique_padrao)
	
	if GameData.tem_checkpoint and GameData.fase_atual != "":
		mudar_cena(GameData.fase_atual)

func _on_btn_creditos_pressed() -> void:
	await tocar_som_e_esperar(som_clique_creditos, 0.2)
	mudar_cena("res://creditos.tscn")

func _on_btn_sair_pressed() -> void:
	await tocar_som_e_esperar(som_clique_padrao)
	get_tree().quit()
