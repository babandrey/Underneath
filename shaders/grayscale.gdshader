shader_type canvas_item;

/* Animation values (0 → 1) */
uniform float red_anim = 0.0;
uniform float blue_anim = 0.0;
uniform float green_anim = 0.0;
uniform float yellow_anim = 0.0;
uniform float purple_anim = 0.0;

/* Target colors */
#define RED_COLORS 3
uniform vec3 red[RED_COLORS]: source_color;

#define BLUE_COLORS 3
uniform vec3 blue[BLUE_COLORS]: source_color;

#define GREEN_COLORS 3
uniform vec3 green[GREEN_COLORS]: source_color;

#define YELLOW_COLORS 3
uniform vec3 yellow[YELLOW_COLORS]: source_color;

#define PURPLE_COLORS 7
uniform vec3 purple[PURPLE_COLORS]: source_color;

uniform float threshold = 0.15;
uniform float edge_softness = 0.05;

uniform bool move_wave = false;
uniform float amplitude = 5.0;   // how far left/right (pixels)
uniform float frequency = 4.0;   // how wavy it is
uniform float speed = 2.0;       // how fast it moves

void vertex() {
	if(move_wave)
	{
		// Use Y so different heights move differently (nice wave look)
	    float wave = sin(VERTEX.y * frequency + TIME * speed);

	    // Offset X (left/right)
	    VERTEX.x += wave * amplitude;
	}
}

float color_mask(vec3 tex, vec3 target) {
    float d = distance(tex, target);
    return smoothstep(threshold + edge_softness, threshold, d);
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // Grayscale base
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray_color = vec3(gray);

    float keep_color = 0.0;

	for(int i = 0; i < RED_COLORS; i++)
	{
		keep_color = max(keep_color, color_mask(tex.rgb, red[i]) * red_anim);
	}
	
	for(int i = 0; i < BLUE_COLORS; i++)
	{
		keep_color = max(keep_color, color_mask(tex.rgb, blue[i]) * blue_anim);
	}
	
	for(int i = 0; i < GREEN_COLORS; i++)
	{
		keep_color = max(keep_color, color_mask(tex.rgb, green[i]) * green_anim);
	}
	
	for(int i = 0; i < YELLOW_COLORS; i++)
	{
		keep_color = max(keep_color, color_mask(tex.rgb, yellow[i]) * yellow_anim);
	}
	
	for(int i = 0; i < PURPLE_COLORS; i++)
	{
		keep_color = max(keep_color, color_mask(tex.rgb, purple[i]) * purple_anim);
	}

    vec3 final_color = mix(gray_color, tex.rgb, clamp(keep_color, 0.0, 1.0));
    COLOR = vec4(final_color, COLOR.a);
}
