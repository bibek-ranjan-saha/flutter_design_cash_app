#version 320 es
precision mediump float;

uniform float uTime;
uniform vec2 uResolution;

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    uv.x *= uResolution.x / uResolution.y;

    // Create dynamic color blending
    vec3 color1 = vec3(0.9, 0.3, 0.5); // Pinkish tone
    vec3 color2 = vec3(0.2, 0.6, 1.0); // Light Blue tone

    // Create a moving wave pattern
    float wave = sin(uv.x * 10.0 + uTime) * cos(uv.y * 10.0 + uTime);
    wave = smoothstep(-0.5, 0.5, wave);

    vec3 finalColor = mix(color1, color2, wave);

    fragColor = vec4(finalColor, 1.0);
}
