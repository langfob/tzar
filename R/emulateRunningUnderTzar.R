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
    cat ("\n\nemulating_tzar from scratch file = ", emulating_tzar, "\n", sep='')

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

#' Run a function under normal tzar or tzar emulation
#'
#' @param emulating_tzar boolean with TRUE indicating main_function should be
#' run under tzar emulation and FALSE indicating run under normal tzar
#' @param main_function  function to call to run under tzar or tzar emulation
#' (NOTE: NOT a string), i.e., your main application code
#' @param project_path path of R code and project.yaml file for project
#' @param tzar_jar_path Path to the jar file to use to run tzar
#' @param emulation_scratch_file_path path of scratch file for passing
#' tzarEmulation flag and tzarOutputDir between tzar and mainline function
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' run_tzar (
#'          emulating_tzar=TRUE,
#'          main_function=trial_main_function,
#'          project_path=".",
#'          tzar_jar_path = "~/D/rdv-framework-latest-work/tzar.jar",
#'          emulation_scratch_file_path="~/tzar_emulation_scratch.yaml"
#'          )
#'}

run_tzar <-
        function (emulating_tzar              = emulating_tzar,
                  main_function               = main,
                  project_path                = project_path,
                  tzar_jar_path               = tzar_jar_path,
                  emulation_scratch_file_path = emulation_scratch_file_path
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

    file.remove (emulation_scratch_file_path)    # parameters$tzarEmulation_scratchFileName)

    return (parameters)
    }

#===============================================================================

