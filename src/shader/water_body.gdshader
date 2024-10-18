shader_type canvas_item;

// uniform はgdscriptsでいう ほぼexport みたいな
// default値 RGBA(1.0,1.0,1.0,1.0) の白
uniform vec4 tint : source_color = vec4(1.0);
// 分からない;;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void vertex() {
	// Called for every vertex the material is visible on.
	// 頂点shader
}

void fragment() {
	// Called for every pixel the material is visible on.
	// pixel shader
	
	// UV座標のpixelの色を取得
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// 取得した色と tintで設定した色を 0.3の割合で brend
	// dst = x * (1 - a) + y * a  の式。
	// 0.7
	color = mix(color, tint, 0.7);
	
	// 分からない;; 1.4は何...?
	// -0.4をと 1.4で何...?
	color = mix(vec4(0.5), color, 1.4);
	
	COLOR = color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
