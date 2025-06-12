extends Window


@onready var background_texture: Texture2D = preload("res://assets/water_background_big.png")


func _ready():
	var tex_rect = TextureRect.new()
	tex_rect.name = "Background"
	tex_rect.texture = background_texture
	tex_rect.stretch_mode = TextureRect.STRETCH_TILE
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tex_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tex_rect.anchor_right = 1.0
	tex_rect.anchor_bottom = 1.0
	tex_rect.offset_left = 0
	tex_rect.offset_top = 0
	tex_rect.offset_right = 0
	tex_rect.offset_bottom = 0
	tex_rect.visible = false
	
	add_child(tex_rect)
	move_child(tex_rect, 0)


func _on_close_requested() -> void:
	self.queue_free()
