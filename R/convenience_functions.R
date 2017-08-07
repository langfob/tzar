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

#' Convenience function to run tzar in pkg with all appropriate variables set
#'
#' The name stands for "run Tzar Inside Package".  The function is intended to
#' be quick and easy to call over and over from the command line, so its
#' name is short and the call has no arguments.
#'
#' @param parameters List of parameters controlling the current run (usually
#'   decoded from project.yaml by tzar)
#'
#' @return Returns nothing
#' @export
#'
#' @examples \dontrun{
#' runtip ()
#'}

runtip <- function (parameters_yaml_file_path = "./project.yaml")
    {
    parameters = yaml::yaml.load_file (parameters_yaml_file_path)

    emulating_tzar                     = TRUE
    main_function                      = tzar_main
    project_path                       = "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"
    emulation_scratch_file_path        = "~/tzar_emulation_scratch.yaml"
    tzar_jar_path                      = "~/D/rdv-framework-latest-work/tzar.jar"

    copy_model_R_tzar_file             = TRUE
    model_R_tzar_src_dir               = "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"    #"."    #system.file("templates", package="bdpgxupaper")
    model_R_tzar_disguised_filename    = "model.R.tzar"
    overwrite_existing_model_R_dest    = TRUE
    required_model_R_filename_for_tzar = "model.R"

    return (
        run_tzar (
              emulating_tzar                     = emulating_tzar,
              main_function                      = main_function,
              project_path                       = project_path,
              emulation_scratch_file_path        = emulation_scratch_file_path,
              tzar_jar_path                      = tzar_jar_path,

              copy_model_R_tzar_file             = copy_model_R_tzar_file,
              model_R_tzar_src_dir               = model_R_tzar_src_dir,
              model_R_tzar_disguised_filename    = model_R_tzar_disguised_filename,
              overwrite_existing_model_R_dest    = overwrite_existing_model_R_dest,
              required_model_R_filename_for_tzar = required_model_R_filename_for_tzar
              )
            )
    }

#-------------------------------------------------------------------------------

#' Convenience function to run tzar outside pkg with all appropriate variables set
#'
#' The name stands for "run Tzar Outside Package".  The function is intended to
#' be quick and easy to call over and over from the command line, so its
#' name is short and the call has no arguments.
#'
#' @param parameters List of parameters controlling the current run (usually
#'   decoded from project.yaml by tzar)
#'
#' @return Returns nothing
#' @export
#'
#' @examples \dontrun{
#' runtop ()
#'}

runtop <- function (parameters_yaml_file_path = "./project.yaml")
    {
    emulating_tzar                     = TRUE
    main_function                      = tzar_main
    project_path                       = "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"
    emulation_scratch_file_path        = "~/tzar_emulation_scratch.yaml"
    tzar_jar_path                      = "~/D/rdv-framework-latest-work/tzar.jar"

    copy_model_R_tzar_file             = FALSE

    model_R_tzar_src_dir               = NULL
    model_R_tzar_disguised_filename    = NULL
    overwrite_existing_model_R_dest    = NULL
    required_model_R_filename_for_tzar = NULL

    return (
        run_tzar (
              emulating_tzar                     = emulating_tzar,
              main_function                      = main_function,
              project_path                       = project_path,
              emulation_scratch_file_path        = emulation_scratch_file_path,
              tzar_jar_path                      = tzar_jar_path,

              copy_model_R_tzar_file             = copy_model_R_tzar_file,
              model_R_tzar_src_dir               = model_R_tzar_src_dir,
              model_R_tzar_disguised_filename    = model_R_tzar_disguised_filename,
              overwrite_existing_model_R_dest    = overwrite_existing_model_R_dest,
              required_model_R_filename_for_tzar = required_model_R_filename_for_tzar
              )
            )
    }

#-------------------------------------------------------------------------------

#' Convenience function to run tzar WITHOUT tzar emulation

#' The name stands for "run Tzar Without Emulation".  The function is intended to
#' be quick and easy to call over and over from the command line, so its
#' name is short and the call has no arguments.
#'
#' Unlike runtip() and runtop(), this function is intended to be equivalent
#' to running tzar from the command line WITHOUT emulation.
#'
#' @param parameters List of parameters controlling the current run (usually
#'   decoded from project.yaml by tzar)
#'
#' @return Returns nothing
#' @export
#'
#' @examples \dontrun{
#' runtwoe ()
#'}

runtwoe <- function (parameters_yaml_file_path = "./project.yaml")
    {
    parameters = yaml::yaml.load_file (parameters_yaml_file_path)

    # project_path                       = "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"
    # tzar_jar_path                      = "~/D/rdv-framework-latest-work/tzar.jar"

    project_path                       = parameters$project_path
    tzar_jar_path                      = parameters$tzar_jar_path

    return (
            tzar_jar_path                      = tzar_jar_path,
            project_path                       = project_path
              )
    }

#===============================================================================
