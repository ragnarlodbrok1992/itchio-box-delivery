#import "Basic";
#import "Compiler";
#import "File";

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
