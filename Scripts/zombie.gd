extends CharacterBody2D

# --- Propriedades de Movimento e Dano ---
@export var speed = 100.0 # Velocidade do inimigo (ajuste no Inspetor)
var current_health = 3    # Vida do inimigo (exemplo)

# --- Referência ao Jogador ---
# Encontra o nó do jogador. O caminho é baseado na Árvore de Cenas principal.
# ASSUMIMOS que o nó raiz do Player se chama "Pixeleon".
@onready var player = get_parent().get_node("Pixeleon") 

# --- Referência de Animação (Opcional, se o Zombie tiver um AnimatedSprite2D) ---
# Se o nó AnimatedSprite2D for filho direto, use:
@onready var _animated_sprite = $AnimatedSprite2D 

# ----------------------------------------------------------------------

func _physics_process(_delta):
	# 1. VERIFICAÇÃO DE SEGURANÇA: Se o Player não existe, o inimigo não se move.
	if player == null:
		# Se for para o inimigo ser destruído quando o Player for destruído,
		# você pode colocar um queue_free() aqui.
		return
		
	# 2. CALCULA A DIREÇÃO: Posição do Player - Posição do Inimigo
	var direcao_para_jogador = player.global_position - global_position
	
	# 3. NORMALIZAÇÃO: Garante que o vetor de direção tenha comprimento 1 (velocidade uniforme).
	var direcao_normalizada = direcao_para_jogador.normalized()
	
	# 4. APLICA VELOCIDADE: Move na direção calculada.
	velocity = direcao_normalizada * speed
	
	# 5. EXECUTA MOVIMENTO: Move o corpo e lida com colisões.
	move_and_slide()
	
	# 6. Lógica de Animação (Opcional, para virar o sprite)
	if _animated_sprite != null:
		_animated_sprite.play("run") # Assume que você tem uma animação "run"
		if velocity.x < 0:
			_animated_sprite.flip_h = true
		elif velocity.x > 0:
			_animated_sprite.flip_h = false

# ----------------------------------------------------------------------
#                         FUNÇÕES DE JOGABILIDADE
# ----------------------------------------------------------------------

# Função para receber dano (chamada pelo Projétil)
func take_damage(amount):
	current_health -= amount
	print("Inimigo levou dano. Vida restante: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	# Adicione efeitos de explosão, som, etc.
	queue_free() # Destrói o inimigo
	
# ----------------------------------------------------------------------

# Lembre-se de conectar o sinal _on_body_entered do nó de colisão (Area2D) do Player, 
# se quiser que o Player morra ao tocar no inimigo.
