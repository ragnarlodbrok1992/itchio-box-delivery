#import "Basic";
#import "Compiler";
#import "File";
#import "File_Utilities";
#import "String";

JAI_PATH := "D:/Jai";
JAI_SDL2_PATH := "/modules/SDL/win/";
SDL2_DLL := "SDL2.dll";

#run {
  // No output of build script
  set_build_options_dc(.{do_output = false});

  args := get_build_options().compile_time_command_line; // I don't know if I have to have this right now

  workspace := compiler_create_workspace("Target workspace");
  if !workspace {
    log_error("Failed to create workspace");
    return;
  }

  options := get_build_options(workspace);

  build_output_directory := "build/";

  make_directory_if_it_does_not_exist(build_output_directory, recursive = true);

  options.output_path = build_output_directory;
  options.output_executable_name = "box-delivery";

  set_build_options(options, workspace);

  // Compiler loop
  compiler_begin_intercept(workspace);
  add_build_file("src/main.jai", workspace);

  // Copy SDL2.dll to the build directory
  sdl2_dll_path := join(JAI_PATH, JAI_SDL2_PATH, SDL2_DLL);
  abs_working_directory := join(get_working_directory(), "/", build_output_directory, SDL2_DLL);
  abs_working_directory  = replace(abs_working_directory, "\\", "/");

  copy_file(sdl2_dll_path, abs_working_directory);

  while true {
    message := compiler_wait_for_message();

    if message.kind == {
      case .ERROR;
        exit(1);

      case .COMPLETE;
        break;
    }
  }

  compiler_end_intercept(workspace);

};
