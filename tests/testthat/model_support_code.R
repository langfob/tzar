#===============================================================================

                        #-----------------------------------#
                        #       model_support_code.R        #
                        #-----------------------------------#

#===============================================================================

local_build_parameters_list <- function ()
    {
    parameters = list()
    parameters$x = 15
    parameters$y = "twenty"

    return (parameters)
    }

#===============================================================================

    # *****  2017 01 02 - BTL
    #  This function is only here to hold the code until I figure out where
    #  it needs to go in the bdpg code.
    #  It doesn't belong in the tzar package.
    # *****

open_console_output_file_if_necessary <- function (emulatingTzar,
                                                   echoConsoleToTempFile)
    {
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

    # echoConsoleToTempFile = TRUE
    if (emulatingTzar & echoConsoleToTempFile)
        {
            #  Open a file to echo console to.
        tempConsoleOutFile <- file ("consoleSinkOutput.temp.txt", open="wt")

            #  Redirect console output to the file.
        sink (tempConsoleOutFile, split=TRUE)
        }
    }

#===============================================================================

genSetCoverProblem (parameters,
                    ...
#                    running_tzar_or_tzar_emulator=FALSE,
#                    emulatingTzar=FALSE
                    )
    {
    cat ("\n\nDummy call to gen set cover().\n\n")

    cat ("\nrunning_tzar_or_tzar_emulator = ", running_tzar_or_tzar_emulator)
    cat ("\nemulatingTzar                 = ", emulatingTzar)

    # open_console_output_file_if_necessary (emulatingTzar,
    #                                        echoConsoleToTempFile)
    }

#===============================================================================
#===============================================================================

