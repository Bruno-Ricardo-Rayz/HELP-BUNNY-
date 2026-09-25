extends AudioStreamPlayer

# No Inspetor do GerenciadorMusica, coloque as músicas do Menu/Créditos
@export var playlist: Array[AudioStream] = []

var indice_musica_atual: int = 0
var ativo: bool = true

func _ready():
	if not finished.is_connected(_on_musica_finalizada):
		finished.connect(_on_musica_finalizada)
	iniciar_playlist()

func iniciar_playlist():
	ativo = true
	if playlist.size() == 0:
		return
		
	# Embaralha a lista para mudar a ordem toda vez que a playlist iniciar
	playlist.shuffle()
	indice_musica_atual = 0
		
	if not playing:
		tocar_musica_atual()

func parar_playlist():
	ativo = false
	stop()
	stream = null

func tocar_musica_atual():
	if not ativo or playlist.size() == 0:
		return
		
	stream = playlist[indice_musica_atual]
	play()

func _on_musica_finalizada():
	if not ativo or playlist.size() == 0:
		return
		
	indice_musica_atual = (indice_musica_atual + 1) % playlist.size()
	tocar_musica_atual()
