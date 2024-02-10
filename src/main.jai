#import "Basic";
#import "String";
#import "SDL";
#import "GL";

// Engine static settings - globals
WINDOW_WIDTH := 640;
WINDOW_HEIGHT := 480;
WINDOW : *SDL_Window = null;

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

}

