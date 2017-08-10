#===============================================================================

                    #--------------------------------------#
                    # model_with_possible_tzar_emulation.R #
                    #--------------------------------------#

#===============================================================================

#' model.R code for tzar or tzar emulation
#'
#' @param parameters  list of parameters built by tzar from project.yaml
#' @param main_function  name of function to call to run under tzar or tzar emulation
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' model_with_possible_tzar_emulation (parameters, my_main_function)
#'}

model_with_possible_tzar_emulation <-
    function (parameters,
              main_function,
              tzar_emulation_yaml_file_path = "./tzar_emulation.yaml"
              )
    {
    tzar_em_params =
        yaml::yaml.load_file (normalizePath (tzar_emulation_yaml_file_path,
                                             mustWork=TRUE))

    emulating_tzar = tzar::as_boolean (tzar_em_params$emulating_tzar)

    if (! emulating_tzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulating tzar")

        main_function (parameters = parameters)

        } else
        #---------------------  EMULATING  ---------------------
        {
        cat ("\n\n=====>  In model.R: EMULATING tzar")

        set_tzar_output_dir_in_scratch_file (parameters$full_output_dir_with_slash,
                                             tzar_em_params$emulation_scratch_file_name_with_path)
        }

    return (parameters)
    }

#===============================================================================

