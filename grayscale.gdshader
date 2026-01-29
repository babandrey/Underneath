shader_type canvas_item;

uniform bool red_open = false;
uniform bool blue_open = false;
uniform bool green_open = false;
uniform bool purple_open = false;
uniform bool yellow_open = false;

uniform vec3 red: source_color;
uniform vec3 blue: source_color;
uniform vec3 green: source_color;
uniform vec3 purple: source_color;
uniform vec3 yellow: source_color;

uniform float threshold = 0.25;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // grayscale
    float gray = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
    vec3 gray_color = vec3(gray);

    // 1 = keep color, 0 = grayscale
    float keep_color = 0.0;

    if (red_open)
        keep_color = max(keep_color, step(distance(tex.rgb, red), threshold));

    if (blue_open)
        keep_color = max(keep_color, step(distance(tex.rgb, blue), threshold));

    if (green_open)
        keep_color = max(keep_color, step(distance(tex.rgb, green), threshold));

    if (yellow_open)
        keep_color = max(keep_color, step(distance(tex.rgb, yellow), threshold));

    if (purple_open)
        keep_color = max(keep_color, step(distance(tex.rgb, purple), threshold));

    vec3 final_color = mix(gray_color, tex.rgb, keep_color);
    COLOR = vec4(final_color, tex.a);
}
