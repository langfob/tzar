#===============================================================================

                            #  run_tzar.R

#===============================================================================

#-------------------------------------------------------------------------------

#' Run a function under normal tzar or tzar emulation
#'
#' If you're building a package rather than writing freestanding
#' R code, R will execute all ".R" files in the package's R directory
#' every time the package is built.  This is a problem when using tzar
#' because tzar expects to find and run a file called model.R in the
#' directory with all the other R code for the project.  If the code
#' that builds the package finds that file, it will try to run the code in
#' model.R and there will be code not encapsulated in a function and
#' the builder will blow up when it runs that code.  For example,
#' you might need one or more library() calls in model.R and these
#' are not supposed to be executed inside package code.
#'
#' The way that run_tzar() is going to fake around this is to allow
#' you to to create a model.R by copying the code from some other
#' file into a file called model.R at the time tzar is run and then
#' remove it after tzar finishes.  This behavior is primarily
#' controlled by the boolean argument "copy_model_dot_R_tzar_file".
#' If that flag is TRUE, then run_tzar() will look at other
#' arguments to the function to determine source and destination
#' locations and file names and take care of the copying and cleaning
#' up after the run.
#'
#' If you are working on your project outside of building a package,
#' then it's not a problem to have the model.R code in the same
#' directory as your other R code that tzar expects to run for the
#' project.  In that case, just set the "copy_model_dot_R_tzar_file" to
#' FALSE and all the other arguments related to it will be ignored.
#'
#' NOTE:  Leaving the copying flag turned on does NOT hurt runs
#'        done outside of building a package, so it's recommended
#'        to just leave it turned on and put the code you would
#'        normally put in model.R in model.R.tzar instead and then
#'        let the run_tzar() manage all of that.  This way, you
#'        can use the emulator with the least amount of installation
#'        and management work for you when using the tzar package.

#' @param emulating_tzar boolean with TRUE indicating main_function should be
#' run under tzar emulation and FALSE indicating run under normal tzar
#' @param main_function  function to call to run under tzar or tzar emulation
#' (NOTE: NOT a string), i.e., your main application code
#' @param project_path path of R code and project.yaml file for project
#' @param emulation_scratch_file_path path of scratch file for passing
#' tzarEmulation flag and tzarOutputDir between tzar and mainline function
#' @param tzar_jar_path Path to the jar file to use to run tzar
#'
#' @param copy_model_dot_R_tzar_file Boolean flag indicating whether model.R must
#' be copied in (e.g., when running inside a package)
#' @param model_dot_R_tzar_SRC_dir Path to directory holding the model.R file to
#' use to run tzar
#' @param model_dot_R_tzar_disguised_filename Name (without path) of the file
#' containing the code to be run by tzar as model.R
#' @param overwrite_existing_model_dot_R_dest Boolean flag indicating whether
#' model.R being copied in should overwrite any existing model.R in destination
#' @param required_model_dot_R_filename_for_tzar Name of file that tzar expects to
#' find and execute to call user's application code from tzar (currently,
#' it's always "model.R")
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
#'          tzar_jar_path               = "~/D/rdv-framework-latest-work/tzar.jar",
#'          copy_model_dot_R_tzar_file             = FALSE,
#'          model_dot_R_tzar_src_dir               = model_dot_R_tzar_src_dir,
#'          model_dot_R_tzar_disguised_filename    = "model.R.tzar",
#'          overwrite_existing_model_dot_R_dest    = TRUE,
#'          required_model_dot_R_filename_for_tzar = "model.R"
#'          )
#'}

#-------------------------------------------------------------------------------

run_tzar <- function (parameters_yaml_file_path = "./project.yaml")

        # function (emulating_tzar,
        #           main_function,
        #           project_path,
        #           emulation_scratch_file_path,
        #           tzar_jar_path,
        #
        #           copy_model_dot_R_tzar_file             = FALSE,
        #           model_dot_R_tzar_src_dir               = ".",
        #           model_dot_R_tzar_disguised_filename    = "model.R.tzar",
        #           overwrite_existing_model_dot_R_dest    = FALSE,
        #           required_model_dot_R_filename_for_tzar = "model.R"
        #           )
    {
            #---------------------------------------------------------------
            #  Need to know a few parameter values that are in the tzar
            #  project.yaml file, but that file won't be loaded by tzar
            #  until run_tzar_java_jar() is called.  So, we need to read
            #  that file now.
            #
            #  Tzar will read it again later and modify the parameters
            #  loaded from it (e.g., building output directory name), so
            #  we will call the list loaded here "params" to differentiate
            #  it from the list loaded later as "parameters".
            #  It probably wouldn't matter if they were both called by
            #  the same name, but having them under different names will
            #  make it easier to compare them if there is a bug that might
            #  be related to which list is used at a given time.
            #---------------------------------------------------------------

    params = yaml::yaml.load_file (parameters_yaml_file_path)

    emulating_tzar = as_boolean (params$emulating_tzar)
    copy_model_dot_R_tzar_file = as_boolean (params$copy_model_dot_R_tzar_file)

            #---------------------------------------------------------------
            #  Get the full path to the emulation scratch file.
            #  Make sure the path is in canonical form
            #  for the platform in case there is any problem with it.
            #  Set mustWork=FALSE because the file should not be there and
            #  when a file is not there, normalizePath() gives a warning
            #  that we don't want to see.
            #---------------------------------------------------------------

    if (emulating_tzar)
        emulation_scratch_file_path =
            normalizePath (params$emulation_scratch_file_path,
                           mustWork=FALSE)

            #----------------------------------------------------------------
            #  If emulating tzar and there is no model.R file in the source
            #  code area, copy the template model.R file into the area.
            #----------------------------------------------------------------

    if (emulating_tzar & copy_model_dot_R_tzar_file)
            full_model_dot_R_DEST_path =
                    copy_model_dot_R_tzar_file_to_src_area (
                                params$model_dot_R_tzar_SRC_dir,
                                params$model_dot_R_tzar_disguised_filename,
                                params$project_path,
                                params$required_model_dot_R_filename_for_tzar,
                                params$overwrite_existing_model_dot_R_DEST)

            #--------------------------------------------------------------------
            #  Ready to make the actual call to tzar from the command line now.
            #--------------------------------------------------------------------

    run_tzar_java_jar (tzar_jar_path, project_path)

            #-------------------------------------------------------------------
            #  Tzar has now finished doing its run or crashed trying.
            #  There should be a fully laid out tzar output directory now.
            #
            #  If this was a real tzar run (i.e., without emulation),
            #  then there's nothing left to do.
            #
            #  If this is a tzar emulation run, it's now time to:
            #    - Collect parameters set by tzar so we can hand them to the
            #      real code.
            #    - Run the real code.
            #-------------------------------------------------------------------

    if (emulating_tzar)
        {
        cat ("\n\nIn run_tzar:  Finished running dummy EMULATION code under tzar.\n",
             "              Ready to go back and run real code outside of tzar...")

                #----------------------------------------------------------
                #  Collect parameters, including those built by tzar
                #  during the dummy run, e.g., output directory location.
                #----------------------------------------------------------

        parameters = emulate_running_tzar (project_path,
                                           emulation_scratch_file_path)

                #-------------------------------------------------------
                #  Finally, ready to run the user's code and clean up.
                #-------------------------------------------------------

        main_function (parameters)

        clean_up_after_tzar_emulation (parameters$tzarInProgressDirName,
                                       parameters$tzarEmulationCompletedDirName,
                                       copy_model_dot_R_tzar_file,
                                       full_model_dot_R_DEST_path,
                                       emulation_scratch_file_path)

        } else
        {
        cat ("\n\nIn run_tzar:  Finished running tzar WITHOUT emulation...")
        }

    return (invisible (parameters))
    }

#===============================================================================

