#===============================================================================

#                           emulateRunningUnderTzar.R

#  source ('emulateRunningUnderTzar.R')

#  History:

#  2014 ... - BTL
#       Need to look up the creation stuff in the example from May or
#       whatever month it was.

#  2014 12 28 - BTL
#       Making it work under biodivprobgen.
#       Made the following changes throughout the code in here and the
#       biodivprobgen code that calls this code:
#           - Changed name of flag from "emulateRunningTzar" to
#             "emulatingTzar".  Not sure if this was necessary but it
#             seemed like both the flag and the function had the same
#             name and that didn't seem like a good idea.
#           - Changed all code in biodivprobgen to use full path names
#             since not all of the source() calls were finding their
#             target code files.  I think that's because something in
#             tzar or somewhere does a cd into the biodivprobgen directory
#             but the source files are in biodivprobgen/R.
#           - Most important change was to add "metadata/" in the middle
#             of parametersListSourceFilename since River changed the tzar
#             output directory structure after I had created this
#             emulation code originally.
#           - Second most important change: had to add a missing variable
#             to the project.yaml file, i.e., the variable that captures
#             the output directory path.

#  2016 03 27 - BTL
#       Moving all of the tzar variables (like path names) inside the function
#       instead of having them as global variables or function arguments.
#       This is because they will probably never change and I'm trying to
#       make everything into functions.  I haven't quite figured out how I'm
#       going to abstract all the tzar and tzar emulation stuff out yet, so
#       this is probably just a temporary plug to fix this.

#===============================================================================

run_tzar_java_jar <- function (tzar_jar_path, project_path)
    {
    tzarCmd = paste ("-jar", tzar_jar_path, "execlocalruns", project_path)
    current.os = utils::sessionInfo()$R.version$os

    if (current.os == 'mingw32')
        {
        tzarsim.exit.code = system (paste0 ('java ', tzarCmd))
        } else
        {
        tzarsim.exit.code = system2 ('java', tzarCmd, env="DISPLAY=:1")
        }
    }

#===============================================================================

set_emulating_tzar_in_scratch_file <- function (emulating_tzar,
                                               emulation_scratch_file_path)
    {
    scratch_file = file (emulation_scratch_file_path, "w")
    cat ("emulating_tzar: ", emulating_tzar, "\n", file=scratch_file, sep='')
    close (scratch_file)
    }

#-----------------------------------

get_emulating_tzar_from_scratch_file <- function (emulation_scratch_file_path)
    {
    scratch_values = yaml::yaml.load_file (emulation_scratch_file_path)

    emulating_tzar = as.logical (scratch_values$emulating_tzar)

    return (emulating_tzar)
    }

#-------------------------------------------------------------------------------

set_tzarOutputDir_in_scratch_file <- function (tzarOutputDir,
                                               emulation_scratch_file_path)
    {
    scratch_file = file (emulation_scratch_file_path, "w")
    cat ("tzarOutputDir: ", tzarOutputDir, "\n", file=scratch_file, sep='')
    close (scratch_file)
    }

#-----------------------------------

get_tzarOutputDir_from_scratch_file <- function (emulation_scratch_file_path)
    {
    scratch_values = yaml::yaml.load_file (emulation_scratch_file_path)
    tzarOutputDir = scratch_values$tzarOutputDir

    return (tzarOutputDir)
    }

#===============================================================================

#' get R template files for running tzar emulation
#'
#' This is a convenience function to run one time at the start of using tzar
#' emulation on a project.  Tzar requires a model.R file and tzar emulation
#' requires a file like tzar_main.R to call the user's application code.  The
#' tzar package provides a template for each of these two files to make it as
#' simple as possible to do emulation.
#'
#' One catch in using the templates is that when development is being done as
#' part of building a package, the model.R file can't be called model.R. This is
#' because when R builds a package, it runs all ".R" files in the package's R
#' directory since they are assumed to do nothing but define functions.  Since
#' model.R runs experiments instead of defining functions, this will not work
#' inside a package build.  Tzar emulation gets around this by disguising the
#' name of model.R as model.R.tzar and then renaming it to model.R just before a
#' tzar run, then renaming it back to model.R.tzar after the emulation run.
#'
#' Note that if tzar emulation is to be done in a normal R programming situation
#' that doesn't involve a package build, then it's fine for model.R to keep its
#' name as is.
#'
#' @param target_dir Path of directory where template files are to be deposited
#' @param running_inside_a_package Boolean flag set to TRUE if emulation will be
#'   done inside a package build and FALSE otherwise
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#'     #  Copy template files to current directory for use in
#'     #  developing a package.
#' get_tzar_R_templates ()
#'
#'     #  Copy template files to R subdirectory for use in normal R development
#'     #  outsides of a package.
#' get_tzar_R_templates ("./R", FALSE)
#' }
get_tzar_R_templates <- function (target_dir = ".",
                                  running_inside_a_package = TRUE)
    {
    target_dir = normalizePath (target_dir)

    file.copy (system.file ("templates/tzar_main.R", package="tzar"),
               target_dir)

        #-----------------------------------------------------------------------
        #  If model.R is to be part of a package, then it can't be named
        #  model.R since the package builder will run it at build time as
        #  part of running all ".R" files in the package's R directory.
        #  So, in that case, the name model.R needs to be disguised to
        #  not end in ".R".  We will arbitrarily choose to rename it with
        #  ".tzar" tacked onto the end.
        #  If not part of a package, then it's fine to have it called model.R.
        #-----------------------------------------------------------------------

    if (running_inside_a_package)
        {
        file.copy (system.file ("templates/model.R", package="tzar"),
                   file.path (target_dir, "model.R.tzar"))
        } else
        {
        file.copy (system.file ("templates/model.R", package="tzar"),
                   target_dir)
        }

    return (NULL)
    }

#===============================================================================

emulateRunningTzar = function (project_path,
                               tzarEmulation_scratchFileName
                               )
    {
        #-----------------------------------------------------------------------
        #  Probably never need to change these...
        #-----------------------------------------------------------------------

    tzarParametersSrcFileName           = "parameters.R"
    tzarEmulation_completedDirExtension = ".completedTzarEmulation"
    tzarInProgressExtension             = ".inprogress/"
    tzarFinishedExtension               = ""

        #-----------------------------------------------------------------------
        #  Need to set these variables just once, i.e., at start of a new project.
        #  Would never need to change after that for that project unless
        #  something strange like the path to the project or to tzar itself has
        #  changed.
        #  Note that the scratch file can go anywhere you want and it will be
        #  erased after the run if it is successful and you have inserted the
        #  call to the cleanup code at the end of your project's code.
        #  However, if your code crashes during the emulation, you may have to
        #  delete the file yourself.  I don't think it hurts anything if it's
        #  left lying around though.
        #-----------------------------------------------------------------------

    # #project_path = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R"
    # project_path = "~/D/Projects/ProblemDifficulty/src/bdprobdiff/R"

    # #tzar_jar_path = "~/D/rdv-framework/tzar.jar"
    # tzar_jar_path = "~/D/rdv-framework-latest-work/tzar.jar"

    # #tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"
    # tzarEmulation_scratchFileName = "~/D/Projects/ProblemDifficulty/src/bdprobdiff/R/tzarEmulation_scratchFile.txt"

        #-----------------------------------------------------------------------
        #  Basing all of the stuff below on reading the rrunner.R file.
        #
        #  Run tzar with the current project.yaml file and a model.R file
        #  that does nothing other than
        #      - returns a successful completion
        #      - causes tzar to expand wildcards and create the output directory
        #        and write the json file and the parameters.R file,
        #      - then
        #
        #  To emulate the running under tzar, you just need to
        #  -  go to the output directory that tzar created
        #  -  source the parameters.R file from that directory
        #  -  start your normal code that would have run from the tzar
        #     output directory.
        #-----------------------------------------------------------------------

#    run_tzar_java_jar (tzar_jar_path, project_path)

        #----------------------------------------------------------
        #  tzar has wildcard-substituted the inProgress name throughout
        #  the parameters file, but when it completed its run, it renamed
        #  the directory to the finished name.
        #  We now want to reuse the parameters file, so we need to rename
        #  the directory back to the inProgress name.  Otherwise, we'd
        #  have to go through and substitute the finished directory name
        #  for all occurrences of the inProgress name in the parameters list.
        #  It might also be a bit misleading if the directory was left with
        #  the finished name after all is done even if the run may have
        #  crashed while running it outside tzar, so I think it's better
        #  to leave it named with inProgress.
        #
        #  - Read the inProgress dir name from the dumped file that
        #       contains nothing but that name.
        #       That file was written out at the end of the model.R
        #       code that does nothing but that when emulation is to be
        #       done.
        #
        #  - Next, strip off the inProgress extension to get
        #       the finished dir name and rename the finished dir
        #       back to inProgress.
        #
        #-----------------------------------------------------------------------

            #  Read dir name from something like:
            #      tzarEmulation_scratchFile.txt
            #  Resulting dir name is something like:
            #      "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/827_default_scenario.inprogress/"
#    tzarInProgressDirName = readLines (tzarEmulation_scratchFileName)
    tzarInProgressDirName =
            get_tzarOutputDir_from_scratch_file (tzarEmulation_scratchFileName)

            #  Build the name of the directory that would result if tzar
            #  successfully ran to completion without emulation, e.g.,
            #      /Users/bill/tzar/outputdata/biodivprobgen/default_runset/828_default_scenario

    tzarFinishedDirName =
        gsub (tzarInProgressExtension,  #  e.g., ".inprogress/"
              tzarFinishedExtension,    #  e.g., ""
              tzarInProgressDirName)    #  The name loaded in previous command

            #  That is the name that will have been hung on the results of
            #  using the dummy model.R code to get tzar to build the
            #  directory structures and parameters list.
            #  However, the parameters list will have used the .inprogress
            #  extension instead of the finished directory name.
            #  So, to be able to use the parameters.R file as it was built
            #  during the dummy model.R run, we need to change the finished
            #  directory's name back to the .inprogress extension.

    file.rename (tzarFinishedDirName, tzarInProgressDirName)

        #-----------------------------------------------------------
        #  Finally, load the parameters list that tzar created and
        #  saved as an R file.
        #----------------------------------------------------------

    parametersListSourceFilename = paste0 (tzarInProgressDirName,
                                           "metadata/",  #  BTL added 2014 12 28
                                           tzarParametersSrcFileName)
    source (parametersListSourceFilename)

        #-----------------------------------------------------------
        #  Save directory names into the parameters list so that
        #  they can be used when cleaning up after emulation
        #  finishes, if it finishes successfully.
        #----------------------------------------------------------

    parameters$tzarInProgressDirName = tzarInProgressDirName

    parameters$tzarEmulationCompletedDirName =
        paste0 (tzarFinishedDirName, tzarEmulation_completedDirExtension)

    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

    return (parameters)
    }

#-------------------------------------------------------------------------------

cleanUpAfterTzarEmulation = function (parameters)
    {
        #  Need to rename the output directory to something to do
        #  with emulation so that if you go back to a pile of directories
        #  and find runs with strange output, you know that it's because
        #  you were playing around with the code in the emulator.
        #  Otherwise, you might have partial results in a run that
        #  appeared to have run to completion because tzar DID run to
        #  completion on the dummy model.R code that enabled the
        #  emulation to build the tzar directories and parameters.
        #
        #  Can't do this earlier because you don't know how many
        #  things inside the parameters list have the inprogress name
        #  built into them by tzar.  If you changed the inprogress
        #  directory name before running the user code, then the run
        #  would be looking for the wrong directory.
        #
        #  However, if tzar itself knew that this was going to be an
        #  emulation name, it could just use the emulation name wherever
        #  it now uses the in progress name and it could skip the renaming
        #  after the run is complete.  If those two things were happening,
        #  then this cleanup code would be unnecessary.

    file.rename (parameters$tzarInProgressDirName,
                 parameters$tzarEmulationCompletedDirName)

    cat ("\n\nFinal tzar output is in:\n    '",
         parameters$tzarEmulationCompletedDirName,
         "'\n\n", sep='')
    }

#===============================================================================

get_parameters <- function (project_path,
#                            tzar_jar_path,
                            tzarEmulation_scratchFileName,
                            emulating_tzar=FALSE
                            )
    {
    #---------------------------------------------------------------------------

        #  This is the only code you need to run the emulator.
        #  However, if you want it to clean up the tzar directory name extensions
        #  after it is finished, you also need to run the routine called
        #  cleanUpAfterTzarEmulation() after your project code has finished
        #  running, e.g., as the last act in this file.

    if (emulating_tzar)
        {
        cat ("\n\nIn generateSetCoverProblem:  emulating running under tzar...")

        parameters = emulateRunningTzar (project_path,
#                                         tzar_jar_path,
                                         tzarEmulation_scratchFileName
                                         )
        }

    return (parameters)
    }

#===============================================================================

try_to_write_model_R_file_to_work_area <-
                            function (full_model_R_src_path,
                                      full_model_R_dest_path,
                                      overwrite_existing_model_R_dest = TRUE)
    {
    if (file.exists (full_model_R_src_path))
        {
        cat ("\n\nIn write_model_R_file_to_work_area():  overwrite_existing_model_R_dest = '",
             overwrite_existing_model_R_dest, "'\n", sep='')

        if (!overwrite_existing_model_R_dest & file.exists (full_model_R_dest_path))
            {
            stop (paste0 ("\nIn write_model_R_file_to_work_area:  full_model_R_dest_path = '",
                          full_model_R_dest_path, "' either exists.\n\n"))

            } else  #  dest exists but we're allowed to overwrite it
            {
            file.copy (full_model_R_src_path, full_model_R_dest_path,
                       overwrite = TRUE)
            }
        } else
        {
        stop (paste0 ("\nIn write_model_R_file_to_work_area:  full_model_R_src_path = '",
                      full_model_R_src_path, "' does not exist.\n\n"))
        }
    }

#===============================================================================

#' Run a function under normal tzar or tzar emulation
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
#' @param copy_model_R_tzar_file Boolean flag indicating whether model.R must
#' be copied in (e.g., when running inside a package)
#' @param model_R_tzar_src_dir Path to directory holding the model.R file to
#' use to run tzar
#' @param model_R_tzar_disguised_filename Name (without path) of the file
#' containing the code to be run by tzar as model.R
#' @param overwrite_existing_model_R_dest Boolean flag indicating whether
#' model.R being copied in should overwrite any existing model.R in destination
#' @param required_model_R_filename_for_tzar Name of file that tzar expects to
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
#'          copy_model_R_tzar_file             = FALSE,
#'          model_R_tzar_src_dir               = model_R_tzar_src_dir,
#'          model_R_tzar_disguised_filename    = "model.R.tzar",
#'          overwrite_existing_model_R_dest    = TRUE,
#'          required_model_R_filename_for_tzar = "model.R"
#'          )
#'}

run_tzar <-
        function (emulating_tzar,
                  main_function,
                  project_path,
                  emulation_scratch_file_path,
                  tzar_jar_path,

                  copy_model_R_tzar_file             = FALSE,
                  model_R_tzar_src_dir               = ".",
                  model_R_tzar_disguised_filename    = "model.R.tzar",
                  overwrite_existing_model_R_dest    = FALSE,
                  required_model_R_filename_for_tzar = "model.R"
                  )
    {
        #  Make sure the path to the scratch file is in canonical form for
        #  the platform in case there is any problem with it.
        #  Set mustWork=FALSE because the file should not be there and
        #  when a file is not there, normalizePath() gives a warning that
        #  we don't want to see.

    emulation_scratch_file_path = normalizePath (emulation_scratch_file_path,
                                                 mustWork=FALSE)
    set_emulating_tzar_in_scratch_file (emulating_tzar,
                                       emulation_scratch_file_path)

        #  If you're working inside a package rather than as freestanding
        #  R code, R will execute all ".R" files in the package's R directory
        #  every time the package is built.  This is a problem when using tzar
        #  because tzar expects to find and run a file called model.R in the
        #  directory with all the other R code for the project.  If the
        #  package builder finds that file, it will try to run the code in
        #  model.R and there will be code not encapsulated in a function and
        #  the builder will blow up when it runs that code.  For example,
        #  you might need one or more library() calls in model.R and these
        #  are not supposed to be executed inside package code.
        #
        #  The way that run_tzar() is going to fake around this is to allow
        #  you to to create a model.R by copying the code from some other
        #  file into a file called model.R at the time tzar is run and then
        #  remove it after tzar finishes.  This behavior is primarily
        #  controlled by the boolean argument "copy_model_R_tzar_file".
        #  If that flag is TRUE, then run_tzar() will look at other
        #  arguments to the function to determine source and destination
        #  locations and file names and take care of the copying and cleaning
        #  up after the run.
        #
        #  If you are working on your project outside of building a package,
        #  then it's not a problem to have the model.R code in the same
        #  directory as your other R code that tzar expects to run for the
        #  project.  In that case, just set the "copy_model_R_tzar_file" to
        #  FALSE and all the other arguments related to it will be ignored.
        #
        #  NOTE:  Leaving the copying flag turned on does NOT hurt runs
        #         done outside of building a package, so it's recommended
        #         to just leave it turned on and put the code you would
        #         normally put in model.R in model.R.tzar instead and then
        #         let the run_tzar() manage all of that.  This way, you
        #         can use the emulator with the least amount of installation
        #         and management work for you when using the tzar package.

    if (copy_model_R_tzar_file)
        {
        full_model_R_src_path =
            normalizePath (file.path (model_R_tzar_src_dir,
                                      model_R_tzar_disguised_filename))
        full_model_R_dest_path =
            normalizePath (file.path (project_path,
                                      required_model_R_filename_for_tzar),
                           mustWork=FALSE)

        try_to_write_model_R_file_to_work_area (full_model_R_src_path,
                                                full_model_R_dest_path,
                                                overwrite_existing_model_R_dest)
        }

    run_tzar_java_jar (tzar_jar_path, project_path)

    if (emulating_tzar)
        {
        cat ("\n\nIn run_tzar:  emulating running under tzar...")

        parameters = emulateRunningTzar (project_path,
                                         emulation_scratch_file_path
                                         )

        main_function (parameters)

        cleanUpAfterTzarEmulation (parameters)

        } else
        {
        cat ("\n\nIn run_tzar:  running tzar WITHOUT emulation...")
        }

    if (copy_model_R_tzar_file)    #  If model.R was copied in, get rid of it.
        file.remove (full_model_R_dest_path)

    file.remove (emulation_scratch_file_path)    # parameters$tzarEmulation_scratchFileName)

    return (parameters)
    }

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

