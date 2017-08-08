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
              main_function
              )
    {
    tzar_emulation_yaml_file_path = "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R/tzar_emulation.yaml"
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

# 2017 08 07 9:46 pm - BTL
# For some reason, this is not writing out a directory value.
# It just writes the label "tzar_output_dir:" but nothing after it.
# Does this have anything to do with opening and overwriting issues when
# the previous run crashed and didn't clean up the scratch file?
# Or, do I need to put write statements back in here and figure out why
# the parameters$full_output_dir_with_slash value is empty (assuming it is)?

        set_tzar_output_dir_in_scratch_file (parameters$full_output_dir_with_slash,
                                             tzar_em_params$emulation_scratch_file_path)
        }

    return (parameters)
    }

#===============================================================================

