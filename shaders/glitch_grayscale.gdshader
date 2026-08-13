shader_type canvas_item;

// --- TOGGLES ---
instance uniform bool enable_glitch = true;
instance uniform bool enable_monochrome = true;

// --- SCREEN TEXTURE ---
uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

// --- GLITCH / VHS UNIFORMS ---
uniform float pixel_size : hint_range(1.0, 10.0) = 3.0;
uniform float vhs_intensity : hint_range(0.0, 10.0) = 3.0;
uniform float glitch_opacity : hint_range(0.0, 1.0) = 0.5; 
uniform float double_vision_split : hint_range(0.0, 0.05) = 0.01;

// --- MONOCHROME UNIFORMS ---
uniform vec4 mono_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float mono_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float contrast : hint_range(0.5, 2.0) = 1.0;

// Pseudo-random noise function for glitch offset
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    // 1. Sample original base color
    vec4 original_color = texture(screen_texture, SCREEN_UV);
    vec3 current_color = original_color.rgb;

    // 2. Apply Glitch Effect (if enabled)
    if (enable_glitch) {
        vec2 screen_res = vec2(textureSize(screen_texture, 0));
        vec2 grid_uv = round(SCREEN_UV * (screen_res / pixel_size)) / (screen_res / pixel_size);
        
        float time_step = floor(TIME * 15.0); 
        float glitch = (random(vec2(time_step, floor(grid_uv.y * 30.0))) - 0.5) * 0.005 * vhs_intensity;
        
        vec2 uv = grid_uv;
        uv.x += glitch;

        vec2 uv_red = uv + vec2(double_vision_split, 0.0);
        vec2 uv_blue = uv - vec2(double_vision_split, 0.0);
        
        vec4 tex_red = texture(screen_texture, uv_red);
        vec4 tex_blue = texture(screen_texture, uv_blue);
        
        vec3 red_vision = vec3(tex_red.r, 0.0, 0.0);
        vec3 blue_vision = vec3(0.0, tex_blue.g, tex_blue.b); 
        vec3 vhs_color = red_vision + blue_vision;

        current_color = mix(current_color, vhs_color, glitch_opacity);
    }

    // 3. Apply Monochrome Effect (if enabled)
    if (enable_monochrome) {
        // Calculate grayscale from the current color (including glitch if active)
        float gray = dot(current_color, vec3(0.299, 0.587, 0.114));

        // Contrast adjustment
        gray = (gray - 0.5) * contrast + 0.5;

        // Apply tint color
        vec3 mono = gray * mono_color.rgb;

        // Blend with the pre-monochrome color state
        current_color = mix(current_color, mono, mono_intensity);
    }

    // 4. Output final result
    COLOR = vec4(current_color, original_color.a);
}