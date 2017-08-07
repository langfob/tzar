#===============================================================================

                    #--------------------------------------#
                    # model_with_possible_tzar_emulation.R #
                    #--------------------------------------#

#===============================================================================

#' model.R code for tzar or tzar emulation
#'
#' @param parameters  list of parameters built by tzar from project.yaml
#' @param main_function  name of function to call to run under tzar or tzar emulation
#' @param projectPath path of R code and project.yaml file for project
#' @param emulation_scratch_file_path path of scratch file for passing tzarEmulation flag and tzarOutputDir between tzar and mainline function
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' model_with_possible_tzar_emulation (parameters,
#'                                     main_function                 = trial_main_function,
#'                                     projectPath                   = ".",
#'                                     emulation_scratch_file_path   = "~/tzar_emulation_scratch.yaml"
#'                                    )
#'}

model_with_possible_tzar_emulation <- function (parameters,
                                                main_function,
                                                projectPath,
                                                emulation_scratch_file_path
                                                )
    {
    # emulatingTzar =
    #     get_emulating_tzar_from_scratch_file (emulation_scratch_file_path)
    emulating_tzar = as_boolean (parameters$emulatingTzar)

    if (! emulating_tzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulating tzar")

        main_function (parameters = parameters)

        } else                     #  EMULATING
        {
        cat ("\n\n=====>  In model.R: EMULATING tzar")

        set_tzarOutputDir_in_scratch_file (parameters$fullOutputDirWithSlash,
                                           emulation_scratch_file_path)

        parameters$tzarEmulation_scratchFileName = emulation_scratch_file_path
        }

    return (parameters)
    }

#===============================================================================

