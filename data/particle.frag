#version 330

/**
 * Author: Kazik Pogoda
 * https://xemantic.com
 * contact: morisil@xemantic.com
 */

uniform vec3 color = vec3(1);
uniform float centerX;
uniform float centerY;
uniform float radius;

// TODO can it be vec3?
out vec4 fragColor;

void main() {
  float dist = distance(vec2(centerX, centerY), gl_FragCoord.xy);
  vec3 outColor;
  if (dist <= 10) {
    outColor = vec3(1);
  } else {
    outColor = vec3(0);
  }
  fragColor = vec4(
    outColor,
    1 //smoothstep(radius - .5, radius, dist)
  );
  //fragColor = vec4(gl_FragCoord.x / 1000 - radius, gl_FragCoord.y / 1000 + radius, 0, 1);
}
