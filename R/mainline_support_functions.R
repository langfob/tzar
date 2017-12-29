#===============================================================================

                        #  mainline_support_functions.R

#  This file contains small, incidental functions that support the two
#  main functions that control tzar emulation.

#===============================================================================

#' Run the tzar jar under java
#'
#' @param tzar_jar_name_with_path Path of directory where tzar jar is found
#' @param project_path Path of directory where user code to be run is found

#' @return NULL
#' @export

run_tzar_java_jar <- function (tzar_jar_name_with_path, project_path)
    {
    tzar_cmd = paste ("-jar", tzar_jar_name_with_path, "execlocalruns", project_path)
    current.os = utils::sessionInfo()$R.version$os

    if (current.os == 'mingw32')
        {
        tzarsim.exit.code = system (paste0 ('java ', tzar_cmd))
        } else
        {
        tzarsim.exit.code = system2 ('java', tzar_cmd, env="DISPLAY=:1")
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

#' @param value value to be converted to boolean

#' @return input value as a boolean
#' @export

as_boolean <- function (value)
    {
    if (is.null (value)) FALSE else as.logical (value)
    }

#===============================================================================

set_tzar_output_dir_in_scratch_file <- function (full_output_dir_with_slash,
                                                 emulation_scratch_file_path)
    {
        #  Make sure the directory exists for writing the scratch file.
        #  If it doesn't, then create that directory and any above it in the
        #  path that don't exist.
    dir = dirname (emulation_scratch_file_path)
    if (! dir.exists (dir))  dir.create (dir, recursive=TRUE)

    scratch_file = file (emulation_scratch_file_path, "w")
    cat ("full_output_dir_with_slash: ", full_output_dir_with_slash, "\n", file=scratch_file, sep='')
    close (scratch_file)
    }

#-------------------------------------------------------------------------------

get_tzar_output_dir_from_scratch_file <- function (emulation_scratch_file_path)
    {
    scratch_values = yaml::yaml.load_file (emulation_scratch_file_path)
    full_output_dir_with_slash = scratch_values$full_output_dir_with_slash

    return (full_output_dir_with_slash)
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

        #----------------------------------------------------------------------
        #  If emulating tzar and there is no model.R file in the source code
        #  area, copy the template model.R file into the area.
        #  This is only necessary if doing tzar emulation from inside an R
        #  package (because every ".R" file gets run during the package build
        #  and model.R contains code other than function and variable
        #  declarations and so, will cause the build to fail).
        #----------------------------------------------------------------------

copy_model_dot_R_tzar_file_to_src_area <-
                        function (model_dot_R_tzar_SRC_dir,
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

clean_up_after_tzar_emulation <- function (tzar_in_progress_dir_name,
                                           tzar_emulation_completed_dir_name,
                                           copy_model_dot_R_tzar_file,
                                           full_model_dot_R_DEST_path,
                                           emulation_scratch_file_path,
                                           echo_console_to_temp_file,
                                           console_sink_file_info,
                                           full_output_dir_with_slash)
    {
    cat ("\n\nFinal tzar output is in:\n    '", tzar_emulation_completed_dir_name,
         "'\n\n", sep='')

    if (file.exists (emulation_scratch_file_path))
        {
        file.remove (emulation_scratch_file_path)
        }

    clean_up_console_sink (echo_console_to_temp_file,
                           console_sink_file_info,
                           full_output_dir_with_slash)

    file.rename (tzar_in_progress_dir_name, tzar_emulation_completed_dir_name)
     }

#===============================================================================

handle_error_clean_up_after_tzar_emulation_crash <-
                                        function (tzar_in_progress_dir_name,
                                                  emulation_scratch_file_path,
                                                  echo_console_to_temp_file,
                                                  console_sink_file_info,
                                                  full_output_dir_with_slash)
    {
        #----------------------------------------------------------------
        #  Write to output to flag that the emulation run crashed.
        #  Using message() to make it bright red and hard to miss in
        #  console output.
        #  However, that message doesn't seem to show up in the console
        #  sink file, so write the same message out using cat too.
        #----------------------------------------------------------------

    cat ("\n**********  TZAR EMULATION RUN CRASHED  **********",
         "\n**********       CLEANING UP NOW        **********\n")

    message (paste0 ("\n**************************************************",
                     "\n**********  TZAR EMULATION RUN CRASHED  **********",
                     "\n**********       CLEANING UP NOW        **********",
                     "\n**************************************************"))

        #----------------------------------------------------------------
        #  Remove the emulation scratch file and move the console sink
        #  file to the metadata area of the current run that is being
        #  aborted.
        #----------------------------------------------------------------

    cat ("\nCurrent tzar output area is:\n    '", tzar_in_progress_dir_name,
         "'", sep='')

    if (file.exists (emulation_scratch_file_path))
        {
        cat ("\nRemoving emulation scratch file = '", emulation_scratch_file_path, sep='')
        file.remove (emulation_scratch_file_path)
        }

    if (echo_console_to_temp_file)
        {
        clean_up_console_sink (echo_console_to_temp_file,
                               console_sink_file_info,
                               full_output_dir_with_slash)
        }
     }

#===============================================================================

#####  IS THIS STILL USED?  SEE TZAR PACKAGE ISSUE 5.
#####  BTL - 2017 08 07

get_parameters <- function (project_path,
#                            tzar_jar_name_with_path,
                            tzar_emulation_scratch_file_name,
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
#                                         tzar_jar_name_with_path,
                                         tzar_emulation_scratch_file_name
                                         )
        }

    return (parameters)
    }

#===============================================================================

