#===============================================================================

                        #  console_sink_file_functions.R

#  Utilities for managing a console sink file.

#===============================================================================

#' Open console sink file for saving all console output during a run if asked
#'
#' @param emulating_tzar boolean
#' @param echo_console_to_temp_file boolean
#' @param full_output_dir_with_slash path string
#' @param console_output_file_name file name string
#'
#' @return Returns List containing emulating_tzar flag,
#' echo_console_to_temp_file flag, and temp_console_out_file.
#' @export

open_sink_file_if_requested <-
    function (emulating_tzar, echo_console_to_temp_file,
              full_output_dir_with_slash,
              console_output_file_name = "console_sink_output.temp.txt")
    {
    temp_console_out_file = NULL

    if (emulating_tzar & echo_console_to_temp_file)
        {
        sink_file_path = paste0 (full_output_dir_with_slash, console_output_file_name)

            #  Open a file to echo console to.
        temp_console_out_file <- file (sink_file_path, open="wt")

        	#  Redirect console output to the file.
        sink (temp_console_out_file, split=TRUE)
        }

    return (list (emulating_tzar=emulating_tzar,
                  echo_console_to_temp_file=echo_console_to_temp_file,
                  temp_console_out_file=temp_console_out_file))
    }

#-------------------------------------------------------------------------------

#' Get value for tzar emulation flag and create console sink file if asked
#'
#' @param parameters List of parameters read from project.yaml file.

#' @return Returns List containing emulating_tzar flag,
#' echo_console_to_temp_file flag, and temp_console_out_file.
#' @export

get_tzar_emulation_flag_and_console_sink_if_requested <- function (parameters)
    {
    # echo_console_to_temp_file = TRUE
    # if (! is.null (parameters$echo_console_to_temp_file))
    #     echo_console_to_temp_file = parameters$echo_console_to_temp_file
    echo_console_to_temp_file = tzar::as_boolean (parameters$echo_console_to_temp_file)

    # emulating_tzar = FALSE
    # if (! is.null (parameters$emulating_tzar))
    #     emulating_tzar = parameters$emulating_tzar
    emulating_tzar = tzar::as_boolean (parameters$emulating_tzar)

    return (open_sink_file_if_requested (emulating_tzar,
                                         echo_console_to_temp_file,
                                         parameters$full_output_dir_with_slash))
    }

#===============================================================================

#' Clean up the sink file created for console output if requested
#'
#' @param tzar_emulation_flag_and_console_sink_information List containing
#' emulating_tzar flag, echo_console_to_temp_file flag, and
#' temp_console_out_file.

#' @return Returns nothing
#' @export

clean_up_console_sink_if_necessary <-
    function (tzar_emulation_flag_and_console_sink_information)
    {
    emulating_tzar =
        tzar_emulation_flag_and_console_sink_information$emulating_tzar

    echo_console_to_temp_file =
        tzar_emulation_flag_and_console_sink_information$echo_console_to_temp_file

    temp_console_out_file =
        tzar_emulation_flag_and_console_sink_information$temp_console_out_file

    cat ("\n\nIn clean_up_tzar_emulation:\n")
    cat ("    emulating_tzar         = ", emulating_tzar, "\n")
    cat ("    echo_console_to_temp_file = ", echo_console_to_temp_file, "\n")
    if (is.null (temp_console_out_file))
        cat ("    temp_console_out_file is NULL\n")

        #  If you were echoing console output to a temp file,
        #  stop echoing and close the temp file.

    if (emulating_tzar & echo_console_to_temp_file)
        {
        cat ("\nClosing sink file.\n")

        sink()
        if (! is.null (temp_console_out_file))  close (temp_console_out_file)
        }
    }

#===============================================================================

