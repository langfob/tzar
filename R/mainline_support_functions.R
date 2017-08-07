#===============================================================================

                        #  mainline_support_functions.R

#  This file contains small, incidental functions that support the two
#  main functions that control tzar emulation.

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

#' Convert NULL values to FALSE and non-NULLs to their logical value
#'
#' The core function as.logical() crashes if you give it a NULL.
#' This convenience function turns those NULLs into FALSE and preserves
#' the same output as as.logical() for non-NULLs.
#'
#' It probably needs a bit more work to make it behave the same way as
#' as.logical() does for vectors.  For the moment, this is just working
#' on single values when they are NULL.

as_boolean <- function (value)
    {
    if (is.null (params_value)) FALSE else as.logical (value)
    }

#===============================================================================

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

try_to_write_model_dot_R_file_to_work_area <-
                            function (full_model_dot_R_SRC_path,
                                      full_model_dot_R_DEST_path,
                                      overwrite_existing_model_dot_R_DEST = FALSE)
    {
    if (file.exists (full_model_dot_R_SRC_path))
        {
        cat ("\n\nIn write_model_dot_R_file_to_work_area():  overwrite_existing_model_dot_R_DEST = '",
             overwrite_existing_model_dot_R_DEST, "'\n", sep='')

        if (!overwrite_existing_model_dot_R_DEST & file.exists (full_model_dot_R_DEST_path))
            {
            stop (paste0 ("\nIn write_model_dot_R_file_to_work_area:  full_model_dot_R_DEST_path = '",
                          full_model_dot_R_DEST_path, "' either exists.\n\n"))

            } else  #  DEST exists but we're allowed to overwrite it
            {
            file.copy (full_model_dot_R_SRC_path, full_model_dot_R_DEST_path,
                       overwrite = TRUE)
            }
        } else
        {
        stop (paste0 ("\nIn write_model_dot_R_file_to_work_area:  full_model_dot_R_SRC_path = '",
                      full_model_dot_R_SRC_path, "' does not exist.\n\n"))
        }
    }

#===============================================================================

#'  Get rid of any traces of running tzar emulation if emulating.
#'
#'  Need to rename the output directory to something to do
#'  with emulation so that if you go back to a pile of directories
#'  and find runs with strange output, you know that it's because
#'  you were playing around with the code in the emulator.
#'  Otherwise, you might have partial results in a run that
#'  appeared to have run to completion because tzar DID run to
#'  completion on the dummy model.R code that enabled the
#'  emulation to build the tzar directories and parameters.
#'
#'  Can't do this earlier because you don't know how many
#'  things inside the parameters list have the inprogress name
#'  built into them by tzar.  If you changed the inprogress
#'  directory name before running the user code, then the run
#'  would be looking for the wrong directory.
#'
#'  However, if tzar itself knew that this was going to be an
#'  emulation name, it could just use the emulation name wherever
#'  it now uses the in progress name and it could skip the renaming
#'  after the run is complete.  If those two things were happening,
#'  then this cleanup code would be unnecessary.

clean_up_after_tzar_emulation = function (tzarInProgressDirName,
                                          tzarEmulationCompletedDirName,
                                          copy_model_dot_R_tzar_file,
                                          full_model_dot_R_DEST_path,
                                          emulation_scratch_file_path)
    {
    file.rename (tzarInProgressDirName, tzarEmulationCompletedDirName)

    cat ("\n\nFinal tzar output is in:\n    '", tzarEmulationCompletedDirName,
         "'\n\n", sep='')

    if (copy_model_dot_R_tzar_file)  file.remove (full_model_dot_R_DEST_path)

    file.remove (emulation_scratch_file_path)
    }

#===============================================================================

        #----------------------------------------------------------------------
        #  If emulating tzar and there is no model.R file in the source code
        #  area, copy the template model.R file into the area.
        #  This is only necessary if doing tzar emulation from inside an R
        #  package (because every ".R" file gets run during the package build
        #  and model.R contains code other than function and variable
        #  declarations and so, will cause the build to fail).
        #----------------------------------------------------------------------

copy_model_dot_R_tzar_file_to_src_area <- function (model_dot_R_tzar_SRC_dir,
                                                model_dot_R_tzar_disguised_filename,
                                                project_path,
                                                required_model_dot_R_filename_for_tzar,
                                                overwrite_existing_model_dot_R_DEST)
    {
    full_model_dot_R_SRC_path =
      normalizePath (file.path (model_dot_R_tzar_SRC_dir,
                                model_dot_R_tzar_disguised_filename))
    full_model_dot_R_DEST_path =
      normalizePath (file.path (project_path,
                                required_model_dot_R_filename_for_tzar),
                     mustWork=FALSE)

    try_to_write_model_dot_R_file_to_work_area (full_model_dot_R_SRC_path,
                                            full_model_dot_R_DEST_path,
                                            overwrite_existing_model_dot_R_DEST)

    return (full_model_dot_R_DEST_path)
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

