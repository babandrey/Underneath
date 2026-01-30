shader_type canvas_item;

/* Animation values (0 → 1) */
uniform float red_anim = 0.0;
uniform float blue_anim = 0.0;
uniform float green_anim = 0.0;
uniform float yellow_anim = 0.0;
uniform float purple_anim = 0.0;

/* Target colors */
uniform vec3 red: source_color;
uniform vec3 blue1: source_color;
uniform vec3 blue2: source_color;
uniform vec3 blue3: source_color;
uniform vec3 green: source_color;
uniform vec3 yellow: source_color;
uniform vec3 purple: source_color;

uniform float threshold = 0.15;
uniform float edge_softness = 0.05;

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

    // Red
    keep_color = max(keep_color,
        color_mask(tex.rgb, red) * red_anim
    );

    // Blue (multiple targets)
    keep_color = max(keep_color,
        color_mask(tex.rgb, blue1) * blue_anim
    );
    keep_color = max(keep_color,
        color_mask(tex.rgb, blue2) * blue_anim
    );
    keep_color = max(keep_color,
        color_mask(tex.rgb, blue3) * blue_anim
    );

    // Green
    keep_color = max(keep_color,
        color_mask(tex.rgb, green) * green_anim
    );

    // Yellow
    keep_color = max(keep_color,
        color_mask(tex.rgb, yellow) * yellow_anim
    );

    // Purple
    keep_color = max(keep_color,
        color_mask(tex.rgb, purple) * purple_anim
    );

    vec3 final_color = mix(gray_color, tex.rgb, clamp(keep_color, 0.0, 1.0));
    COLOR = vec4(final_color, tex.a);
}
