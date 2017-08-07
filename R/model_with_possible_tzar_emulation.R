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

model_with_possible_tzar_emulation <- function (parameters, main_function)
    {
    emulating_tzar = as_boolean (parameters$emulatingTzar)

    if (! emulating_tzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulating tzar")

        main_function (parameters = parameters)

        } else
        #---------------------  EMULATING  ---------------------
        {
        cat ("\n\n=====>  In model.R: EMULATING tzar")


        set_tzarOutputDir_in_scratch_file (parameters$fullOutputDirWithSlash,
                                           parameters$emulation_scratch_file_path)
        }

    return (parameters)
    }

#===============================================================================

