#version 300 es

precision highp float;

out vec2 texCoord;

void main(void) {
    float x = float((gl_VertexID & 1) << 2);
    float y = float((gl_VertexID & 2) << 1);

    // Results for [gl_VertexID] (x, y):
    // [0] (0, 0)
    // [1] (4, 0)
    // [2] (0, 4)
  
    texCoord.x = x * 0.5;
    texCoord.y = y * 0.5;

    gl_Position = vec4(x - 1.0, y - 1.0, 0, 1.0);
}
