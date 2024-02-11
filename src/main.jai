#import "Basic";
#import "String";
#import "SDL";
#import "GL";

// Engine static settings - globals
WINDOW_WIDTH   := 640;
WINDOW_HEIGHT  := 480;
ENGINE_RUNNING := true;

WINDOW : *SDL_Window = null;

ENGINE_START_TIME : Apollo_Time;

// Shaders - for now here
VERTEX_SHADER :: #string GLSL
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

FRAGMENT_SHADER :: #string GLSL
  #version 460 core

  in vec3 fragmentColor;

  out vec3 color;

  void main() {
    color = fragmentColor;
  }
GLSL

load_shaders :: (vertex_shader: string, fragment_shader: string) -> GLuint {
  // Initialize local variables
  program_id : GLuint;
  shader_program : GLuint;
  vertex_shader_id : GLuint;
  fragment_shader_id : GLuint;
  result_vertex : GLint;
  result_fragment : GLint;
  result_program : GLint;
  info_log_length_vertex : s32;
  info_log_length_fragment : s32;
  info_log_length_program : s32;

  shader_program = glCreateProgram();
  vertex_shader_id = glCreateShader(GL_VERTEX_SHADER);
  fragment_shader_id = glCreateShader(GL_FRAGMENT_SHADER);

  glShaderSource(vertex_shader_id, 1, *to_c_string(vertex_shader), null);
  glCompileShader(vertex_shader_id);

  glGetShaderiv(vertex_shader_id, GL_COMPILE_STATUS, *result_vertex);
  glGetShaderiv(vertex_shader_id, GL_INFO_LOG_LENGTH, *info_log_length_vertex);

  if (info_log_length_vertex > 0) {
    vertex_shader_error_log : [512]u8;
    glGetShaderInfoLog(vertex_shader_id, cast(u32)info_log_length_vertex, null, cast(*GLchar) *vertex_shader_error_log);
    print("%\n", cast(string) vertex_shader_error_log);
  }

  glShaderSource(fragment_shader_id, 1, *to_c_string(fragment_shader), null);
  glCompileShader(fragment_shader_id);

  glGetShaderiv(fragment_shader_id, GL_COMPILE_STATUS, *result_fragment);
  glGetShaderiv(fragment_shader_id, GL_INFO_LOG_LENGTH, *info_log_length_fragment);

  if (info_log_length_fragment > 0) {
    fragment_shader_error_log : [512]u8;
    glGetShaderInfoLog(fragment_shader_id, cast(u32)info_log_length_fragment, null, cast(*GLchar) *fragment_shader_error_log);
    print("%\n", cast(string) fragment_shader_error_log);
  }

  // Creating and attaching compiled shaders to program
  program_id = glCreateProgram();
  glAttachShader(program_id, vertex_shader_id);
  glAttachShader(program_id, fragment_shader_id);
  glLinkProgram(program_id);

  glGetProgramiv(program_id, GL_LINK_STATUS, *result_program);
  glGetProgramiv(program_id, GL_INFO_LOG_LENGTH, *info_log_length_program);

  if (info_log_length_program > 0) {
    program_error_log : string;
    glGetProgramInfoLog(program_id, cast(u32)info_log_length_fragment, null, to_c_string(program_error_log));
    print("%\n", program_error_log);
  }

  // Now we can detach and delete shaders
  glDetachShader(program_id, vertex_shader_id);
  glDetachShader(program_id, fragment_shader_id);

  glDeleteShader(vertex_shader_id);
  glDeleteShader(fragment_shader_id);

  return program_id;
}

main :: () {
  // Initial message
  print("Hello ItchIO! This is Box Delivery game\n");

  // Exit message
  defer print("All went well, goodbye...\n");

  // Initialize SDL
  SDL_Init(SDL_INIT_VIDEO);
  WINDOW = SDL_CreateWindow("Box Delivery", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, xx WINDOW_WIDTH, xx WINDOW_HEIGHT, SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE);

  // Check for window creation
  if !WINDOW {
    print("Failed to create window: %\n", to_string(SDL_GetError()));
    return;
  }

  defer SDL_DestroyWindow(WINDOW);
  defer SDL_Quit();

  SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, xx SDL_GL_CONTEXT_PROFILE_CORE);

  gl_context := SDL_GL_CreateContext(WINDOW);
  if !gl_context {
    print("Failed to create OpenGL context: %\n", to_string(SDL_GetError()));
    return;
  }

  gl_load(*gl, SDL_GL_GetProcAddress);
  using gl; // This might be not used, since it might shadow some stuff.

  print("GL Vendor = %\n", to_string(glGetString(GL_VENDOR)));
  print("GL Version = %\n", to_string(glGetString(GL_VERSION)));

  // Time stuff
  delta_time := 0.01667; // Assuming 60 FPS
  ENGINE_START_TIME = current_time_monotonic();

  while ENGINE_RUNNING {
    // Frame time
    frame_start := current_time_monotonic();

    // FPS counter in window title
    if to_float64_seconds(ENGINE_START_TIME) > 1.0 {
      window_title := tprint("Box Delivery - FPS: %", cast(int) (1 / delta_time));
      SDL_SetWindowTitle(WINDOW, to_c_string(window_title));
      ENGINE_START_TIME = Apollo_Time.{0, 0};
    }

    event : SDL_Event;
    
    // Event polling
    while SDL_PollEvent(*event) {
      if event.type == {
        case SDL_QUIT;
          ENGINE_RUNNING = false;
        case SDL_KEYUP;
          if event.key.keysym.sym == SDLK_ESCAPE ENGINE_RUNNING = false;
        case SDL_WINDOWEVENT;
          if event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED {
            WINDOW_WIDTH = event.window.data1;
            WINDOW_HEIGHT = event.window.data2;
            // glViewport(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT);
          }
      }
    }
    // Simulation

    // Rendering
    glViewport(0, 0, xx WINDOW_WIDTH, xx WINDOW_HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT);

    SDL_GL_SwapWindow(WINDOW);

    // Frame time
    frame_end := current_time_monotonic();
    delta_time = cast(float) to_float64_seconds(frame_end - frame_start);
    ENGINE_START_TIME += frame_end - frame_start;
  }
}

