// Shaders - for now here
DEFAULT_VERTEX_SHADER :: #string GLSL
  #version 460 core
  layout(location = 0) in vec3 vertexPosition_modelspace;
  layout(location = 1) in vec3 vertexColor;

  out vec3 fragmentColor;
  
  uniform mat4 u_view_projection;

  void main() {
      gl_Position = u_view_projection * vec4(vertexPosition_modelspace, 1);

      fragmentColor = vertexColor;
  }
GLSL
