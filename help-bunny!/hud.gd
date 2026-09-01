extends CanvasLayer

# --- CONFIGURAÇÕES DA FASE ---
@export var tempo_restante: float = 60.0
@export var tamanho_minimo_palavra: int = 2
@export var tamanho_maximo_palavra: int = 5
var lista_palavras: Array[String] = []

# --- CONTROLE DA PENALIDADE PROGRESSIVA ---
var penalidade_atual: int = 5
const PENALIDADE_MAXIMA: int = 10

# --- VARIÁVEIS DE JOGO ---
var palavra_atual: String = ""
var texto_digitado: String = ""
var ativo: bool = false

# --- VARIÁVEIS DO PROJÉTIL ---
var modo_projetil: bool = false
var tempo_projetil_restante: float = 0.0
var projetil_atual: Node = null
var dano_projetil_atual: int = 1

# --- REFERÊNCIAS ---
@export var player_node: NodePath
var player: CharacterBody2D

# Cena do coração visual
@export var cena_coracao: PackedScene
var lista_coracoes: Array = []

@onready var richtext_palavra: RichTextLabel = $RichTextLabelPalavra
@onready var label_tempo: Label = $LabelTempo
@onready var label_feedback: Label = $LabelFeedback
@onready var container_vidas: HBoxContainer = $ContainerVidas

func _ready():
	add_to_group("hud")
	
	if player_node and not player_node.is_empty():
		player = get_node_or_null(player_node)
	if not player:
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if label_feedback:
		label_feedback.text = ""
	if richtext_palavra:
		richtext_palavra.text = ""

	carregar_dicionario("res://dicionario.txt")
	atualizar_ui_tempo()
	
	# Se a cena do coração não foi arrastada no Inspetor, tenta carregar direto
	if not cena_coracao:
		cena_coracao = load("res://coracao_ui.tscn")
		
	inicializar_coracoes_ui()

func inicializar_coracoes_ui():
	if not container_vidas:
		return

	# Limpa qualquer coração antigo no container
	for c in container_vidas.get_children():
		c.queue_free()
	lista_coracoes.clear()

	var total_vidas: int = GameData.vida_maxima if (GameData and "vida_maxima" in GameData) else 3

	if not cena_coracao:
		return

	# Instancia cada coração dentro de uma caixa para manter espaçamento no HBoxContainer
	for i in range(total_vidas):
		var caixa_suporte = Control.new()
		caixa_suporte.custom_minimum_size = Vector2(30, 30)
		
		var novo_coracao = cena_coracao.instantiate()
		novo_coracao.scale = Vector2(2.5, 2.5)
		novo_coracao.position = Vector2(15, 15)
		
		caixa_suporte.add_child(novo_coracao)
		container_vidas.add_child(caixa_suporte)
		lista_coracoes.append(novo_coracao)

	atualizar_ui_vida(false)

func carregar_dicionario(caminho_arquivo: String):
	if FileAccess.file_exists(caminho_arquivo):
		var arquivo = FileAccess.open(caminho_arquivo, FileAccess.READ)
		while not arquivo.eof_reached():
			var linha = arquivo.get_line().strip_edges().to_upper()
			var tamanho = linha.length()
			
			if tamanho >= tamanho_minimo_palavra:
				if tamanho_maximo_palavra <= 0 or tamanho <= tamanho_maximo_palavra:
					lista_palavras.append(linha)
					
		arquivo.close()
	else:
		lista_palavras = ["BOM", "PULAR", "GATO", "CASA"]

func _process(delta):
	# Lógica durante a câmera lenta do Projétil
	if modo_projetil:
		var delta_real = delta / Engine.time_scale
		tempo_projetil_restante -= delta_real
		if label_tempo:
			label_tempo.text = "PROJÉTIL: " + str(ceil(tempo_projetil_restante)) + "s"
		
		if tempo_projetil_restante <= 0:
			falha_projetil()
		return

	# Lógica do Tempo Normal
	if tempo_restante > 0:
		tempo_restante -= delta
		atualizar_ui_tempo()
		if tempo_restante <= 0:
			tempo_restante = 0
			game_over_tempo()

	if player and player.estado_atual == player.Estado.PARADO and not ativo:
		iniciar_desafio_digitacao()

# --- SISTEMA DE PROJÉTIL E CÂMERA LENTA ---

func iniciar_desafio_projetil(projetil_node, tempo: float, dano: int):
	modo_projetil = true
	ativo = true
	projetil_atual = projetil_node
	dano_projetil_atual = dano
	
	# Força o tempo para 3.0s ou usa o tempo passado pelo projétil
	tempo_projetil_restante = 3.0 if tempo <= 0 else tempo
	
	# Câmera mais lenta (0.08 deixa bem lento para o jogador ter tempo de ler e reagir)
	Engine.time_scale = 0.08
	gerar_palavra_projetil()

func gerar_palavra_projetil():
	texto_digitado = ""
	var palavras_filtradas = []
	for p in lista_palavras:
		if p.length() >= 4 and p.length() <= 5:
			palavras_filtradas.append(p)
			
	if palavras_filtradas.size() > 0:
		palavra_atual = palavras_filtradas.pick_random()
	else:
		palavra_atual = "FOGO" if dano_projetil_atual > 1 else "CORRE"
		
	atualizar_ui_palavra()

func falha_projetil():
	restaurar_tempo_normal()
	aplicar_dano_player(dano_projetil_atual)
	exibir_feedback("ATINGIDO!", Color.RED)
	if is_instance_valid(projetil_atual):
		projetil_atual.destruir_projetil()

func sucesso_projetil():
	restaurar_tempo_normal()
	exibir_feedback("DESVIADO!", Color.GREEN)
	
	if GameData and GameData.vida_atual < GameData.vida_maxima:
		GameData.vida_atual += 1
		atualizar_ui_vida(true)
	else:
		tempo_restante += 3.0
		atualizar_ui_tempo()

	if is_instance_valid(projetil_atual):
		projetil_atual.destruir_projetil()

func restaurar_tempo_normal():
	Engine.time_scale = 1.0
	modo_projetil = false
	ativo = false
	if richtext_palavra:
		richtext_palavra.text = ""

func cancelar_desafio_projetil_por_colisao(dano: int):
	if modo_projetil:
		restaurar_tempo_normal()
		aplicar_dano_player(dano)

# --- CAPTURA DE TECLAS ---

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		Engine.time_scale = 1.0
		get_tree().change_scene_to_file("res://menu.tscn")
		return

	if not ativo:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.unicode != 0:
			var letra_digitada = String.chr(event.unicode).to_upper()
			if letra_digitada != "":
				validar_letra(letra_digitada)

func validar_letra(letra_digitada: String):
	if palavra_atual == "":
		return
		
	var proxima_letra = palavra_atual[texto_digitado.length()]
	
	if letra_digitada == proxima_letra:
		texto_digitado += letra_digitada
		atualizar_ui_palavra()
		
		if texto_digitado == palavra_atual:
			if modo_projetil:
				sucesso_projetil()
			else:
				sucesso_palavra()
	else:
		if modo_projetil:
			falha_projetil()
		else:
			aplicar_erro()

func aplicar_erro():
	tempo_restante -= penalidade_atual
	if tempo_restante < 0:
		tempo_restante = 0
	exibir_feedback("- " + str(penalidade_atual) + "s!", Color.RED)
	if penalidade_atual < PENALIDADE_MAXIMA:
		penalidade_atual += 1
	gerar_nova_palavra()

func sucesso_palavra():
	ativo = false
	if richtext_palavra:
		richtext_palavra.text = ""
	tempo_restante += 3.0
	atualizar_ui_tempo()
	exibir_feedback("+3s! MUITO BEM!", Color.GREEN)
	penalidade_atual = 5
	if player and player.has_method("pular_obstaculo_automaticamente"):
		player.pular_obstaculo_automaticamente()

func iniciar_desafio_digitacao():
	ativo = true
	penalidade_atual = 5
	gerar_nova_palavra()

func gerar_nova_palavra():
	texto_digitado = ""
	if lista_palavras.size() > 0:
		palavra_atual = lista_palavras.pick_random()
	atualizar_ui_palavra()

# --- MONTAGEM DA UI ---

func atualizar_ui_palavra():
	if not richtext_palavra:
		return
	var texto_bbcode = "[center]"
	for i in range(palavra_atual.length()):
		var letra = palavra_atual[i]
		if i < texto_digitado.length():
			texto_bbcode += "[bgcolor=#33333388][color=#888888] " + letra + " [/color][/bgcolor] "
		else:
			texto_bbcode += "[bgcolor=#DDDDDD][color=#000000] " + letra + " [/color][/bgcolor] "
	texto_bbcode += "[/center]"
	richtext_palavra.text = texto_bbcode

func atualizar_ui_tempo():
	if not modo_projetil and label_tempo:
		label_tempo.text = "Tempo: " + str(ceil(tempo_restante)) + "s"

func atualizar_ui_vida(animar: bool = true):
	var v_atual = GameData.vida_atual if (GameData and "vida_atual" in GameData) else 3

	for i in range(lista_coracoes.size()):
		var coracao = lista_coracoes[i]
		if is_instance_valid(coracao):
			if i < v_atual:
				if animar and not coracao.visible:
					if coracao.has_method("aparecer_com_efeito"):
						coracao.aparecer_com_efeito()
					else:
						coracao.visible = true
				else:
					coracao.visible = true
					coracao.modulate = Color.WHITE
					coracao.scale = Vector2(2.5, 2.5)
			else:
				if animar and coracao.visible:
					if coracao.has_method("sumir_com_efeito"):
						coracao.sumir_com_efeito()
					else:
						coracao.visible = false
				else:
					coracao.visible = false

func aplicar_dano_player(quantidade: int):
	if GameData and "vida_atual" in GameData:
		GameData.vida_atual -= quantidade
		if GameData.vida_atual < 0:
			GameData.vida_atual = 0
	
	atualizar_ui_vida(true)
	
	if player and player.has_method("tomar_dano"):
		player.tomar_dano()

	if GameData and "vida_atual" in GameData and GameData.vida_atual <= 0:
		game_over_tempo()

func exibir_feedback(texto: String, cor: Color):
	if not label_feedback:
		return
	label_feedback.text = texto
	label_feedback.modulate = cor
	var tween = create_tween()
	tween.tween_property(label_feedback, "modulate:a", 0.0, 1.0).from(1.0)

func game_over_tempo():
	Engine.time_scale = 1.0
	ativo = false
	if richtext_palavra:
		richtext_palavra.text = "[center][color=red]GAME OVER![/color][/center]"
		
	# Dispara a função de morte do coelho (que executa a animação 'dead' e aguarda 4s)
	if player and player.has_method("morrer"):
		player.morrer()
