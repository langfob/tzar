my_main_code <- function (parameters, emulating_tzar=FALSE)
    {
    cat ("\nInside my_main_code():")
    cat ("\n    parameters$full_output_dir_with_slash = \n'",
         parameters$full_output_dir_with_slash,
         "'")
    cat ("\n    parameters$some_other_variable = '",
         parameters$some_other_variable,
         "'\n")
    }

runt <- function ()
    {
    tzar::run_tzar (main_function = my_main_code,
                    parameters_yaml_file_path = "./project.yaml",
                    tzar_emulation_yaml_file_path = "./tzar_emulation.yaml")
    }
