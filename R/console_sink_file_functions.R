#===============================================================================

                        #  console_sink_file_functions.R

#  Utilities for managing a console sink file.

#-------------------------------------------------------------------------------

#  Notes moved from bdpgxupaper::xu_paper_main():

#  When using RStudio, the console output buffer is currently limited and
#  you can lose informative console output from bdprobdiff in a big run.
#  To capture that output, tee the output to a scratch sink file.
#
#  NOTE:  For some reason, this sink causes a warning message after
#  the code comes back from a marxan run:
#      unused connection
#  I have no idea why this happens, especially because it doesn't always
#  happen.  Since I have warnings set to generate errors rather than
#  warnings, it stops the program by calling browser().  If I just hit Q,
#  then the program continues from there without any problems.
#  At the moment, trapping all the output is more important than having
#  this annoying little hitch, so I'm leaving all this in.
#  At production time, I'll need to either remove it or fix it.
#  I should add an issue for this in the github issue tracking.

#  2017 08 10 - BTL - Moving this into the tzar package.
# tzar_emulation_flag_and_console_sink_information =
#     tzar::get_tzar_emulation_flag_and_console_sink_if_requested (parameters)

#===============================================================================

#' Open console sink file for saving all console output during a run
#'

#' @param sink_file_path tzar_em_scratch_dir Location of tzar emulation scratch
#' directory as path string with no trailing slash
#' @param console_output_file_name console_output_file_name file name string for file to
#' contain console sink output without any path information in the string
#'
#' @return Returns console_sink_file_info list containing named elements
#' console_output_file_name, sink_file_path, temp_console_out_file
#' @export

open_sink_file <- function (console_out_file_name_with_path)
    {
            #  Open a file to echo console to.
    temp_console_out_file = file (console_out_file_name_with_path, open="wt")

        	#  Redirect console output to the file.
    sink (temp_console_out_file, split=TRUE)

    return (list (console_out_file_name_with_path =
                      console_out_file_name_with_path,
                  temp_console_out_file    = temp_console_out_file))
    }

#===============================================================================

#' Clean up the sink file created for console output if necessary
#'
#' @param echo_console_to_temp_file boolean
#' @param console_sink_file_info list containing named elements
#' console_output_file_name, sink_file_path, temp_console_out_file
#' @param full_output_dir_with_slash file

#' @return Returns nothing
#' @export

clean_up_console_sink <-
    function (echo_console_to_temp_file,
              console_sink_file_info,
              full_output_dir_with_slash)
    {
    cat ("\n\nIn clean_up_console_sink:\n")

        #  If you were echoing console output to a temp file,
        #  stop echoing and close the temp file.

    if (echo_console_to_temp_file)
        {
        cat ("\nClosing sink file.\n")

        console_out_file_name_with_path = console_sink_file_info$console_out_file_name_with_path
        temp_console_out_file = console_sink_file_info$temp_console_out_file

        sink()

        if (is.null (temp_console_out_file))
            {
            cat ("    temp_console_out_file is NULL\n")

            } else
            {
            close (temp_console_out_file)

                #  Move the console output file to the tzar output
                #  metadata area for the current run in case it's
                #  needed in later debugging to compare between
                #  runs, e.g., if something was being output in a
                #  previous run but is no longer output, etc..

            full_output_dir_WITHOUT_slash =
                substr (full_output_dir_with_slash, 1,
                        nchar(full_output_dir_with_slash)-1)

            dest = file.path (full_output_dir_WITHOUT_slash,
                              "metadata",
                              basename (console_out_file_name_with_path))

            cat ("\ndestination for sink file move = '", dest, "'\n")

            file.rename (console_out_file_name_with_path, dest)
            }
        }
    }

#===============================================================================

