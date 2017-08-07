#===============================================================================

#                           convenience_functions.R

#===============================================================================

#' Convenience function to call run_tzar() when code is not part of a package
#'
#' @param emulating_tzar boolean with TRUE indicating main_function should be
#' run under tzar emulation and FALSE indicating run under normal tzar
#' @param main_function  function to call to run under tzar or tzar emulation
#' (NOTE: NOT a string), i.e., your main application code
#' @param project_path path of R code and project.yaml file for project
#' @param emulation_scratch_file_path path of scratch file for passing
#' tzarEmulation flag and tzarOutputDir between tzar and mainline function
#' @param tzar_jar_path Path to the jar file to use to run tzar
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' run_tzar (
#'          emulating_tzar              = TRUE,
#'          main_function               = trial_main_function,
#'          project_path                = ".",
#'          emulation_scratch_file_path = "~/tzar_emulation_scratch.yaml",
#'          tzar_jar_path               = "~/D/rdv-framework-latest-work/tzar.jar"
#'          )
#'}

run_tzar_outside_pkg <-
        function (emulating_tzar,
                  main_function,
                  project_path,
                  emulation_scratch_file_path,
                  tzar_jar_path
                  )
    {
    return (run_tzar (emulating_tzar                     = emulating_tzar,
                      main_function                      = main_function,
                      project_path                       = project_path,
                      emulation_scratch_file_path        = emulation_scratch_file_path,
                      tzar_jar_path                      = tzar_jar_path,

                      copy_model_R_tzar_file             = FALSE
                      )
            )
    }

#===============================================================================
