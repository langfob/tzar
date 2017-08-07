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

#' Run the tzar jar under java
#'
#' @param tzar_jar_path Path of directory where tzar jar is found
#' @param project_path Path of directory where user code to be run is found

#' @return NULL
#' @export

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
browser()
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

    return (invisible (parameters))
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

#####  IS THIS STILL USED?  SEE TZAR PACKAGE ISSUE 5.
#####  BTL - 2017 08 07

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
        #  running.

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
#' controlled by the boolean argument "copy_model_R_tzar_file".
#' If that flag is TRUE, then run_tzar() will look at other
#' arguments to the function to determine source and destination
#' locations and file names and take care of the copying and cleaning
#' up after the run.
#'
#' If you are working on your project outside of building a package,
#' then it's not a problem to have the model.R code in the same
#' directory as your other R code that tzar expects to run for the
#' project.  In that case, just set the "copy_model_R_tzar_file" to
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
        #----------------------------------------------------------------------
        #  If there is no model.R file in the source code area,
        #  then copy the template model.R file into the area.
        #  This is only necessary if doing tzar emulation from inside an R
        #  package (because every ".R" file gets run during the package build
        #  and model.R contains code other than function and variable
        #  declarations and so, will cause the build to fail).
        #----------------------------------------------------------------------

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

browser()
        #--------------------------------------------------------------------
        #  Ready to make the actual call to tzar from the command line now.
        #--------------------------------------------------------------------

    run_tzar_java_jar (tzar_jar_path, project_path)

        #----------------------------------------------------------------------
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
        #----------------------------------------------------------------------

    if (emulating_tzar)
        {
        cat ("\n\nIn run_tzar:  Finished running dummy EMULATION code under tzar.\n",
             "              Ready to go back and run real code outside of tzar...")

            #-------------------------------------------------------------------
            #  Make sure the path to the scratch file is in canonical form for
            #  the platform in case there is any problem with it.
            #  Set mustWork=FALSE because the file should not be there and
            #  when a file is not there, normalizePath() gives a warning that
            #  we don't want to see.
            #-------------------------------------------------------------------

        emulation_scratch_file_path = normalizePath (emulation_scratch_file_path,
                                                     mustWork=FALSE)

###  Not necessary now that emulating_tzar is set in project.yaml?
###  2017 08 06 - BTL.
        set_emulating_tzar_in_scratch_file (emulating_tzar,
                                            emulation_scratch_file_path)

            #--------------------------------------------------------
            #  Collect parameters set by tzar during the dummy run,
            #  e.g., output directory location.
            #--------------------------------------------------------

        parameters = emulateRunningTzar (project_path,
                                         emulation_scratch_file_path
                                         )

        main_function (parameters)

        cleanUpAfterTzarEmulation (parameters)

        } else
        {
        cat ("\n\nIn run_tzar:  Finished running tzar WITHOUT emulation...")
        }

        #--------------------------------------------------------
        #  Tzar and/or real code is all finished now, so
        #  get rid of any traces of the emulation if emulating.
        #
        #  QUESTION (2017 08 06 - BTL):
        #  It seems like these two actions would only occur
        #  under emulation.  Is that true?
        #  If so, should probably move them into the function
        #  cleanUpAfterTzarEmulation().
        #--------------------------------------------------------

    if (copy_model_R_tzar_file)  file.remove (full_model_R_dest_path)
    file.remove (emulation_scratch_file_path)

    return (invisible (parameters))
    }

#===============================================================================

