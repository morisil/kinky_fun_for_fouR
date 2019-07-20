#version 330

/**
 * Author: Kazik Pogoda
 * https://xemantic.com
 * contact: morisil@xemantic.com
 */

uniform sampler2D mixer;
uniform float backgroundLevel;
uniform float motionBlurFactor;

out vec4 fragColor;

void main() {
  float mixLevel = motionBlurFactor;
  ivec2 uv = ivec2(
    int(gl_FragCoord.x),
    int(gl_FragCoord.y)
  );
  vec3 level = vec3(backgroundLevel);
  vec3 color = texelFetch(mixer, uv, 0).rgb;
  color = mix(level, color, motionBlurFactor);
  fragColor = vec4(color, 1.);
}
