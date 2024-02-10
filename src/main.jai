#import "Basic";
#import "String";
#import "SDL";
#import "GL";

// Engine static settings - globals
WINDOW_WIDTH := 640;
WINDOW_HEIGHT := 480;
WINDOW : *SDL_Window = null;
ENGINE_RUNNING := true;

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

  while ENGINE_RUNNING {
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
  }
}

