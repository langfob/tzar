#===============================================================================
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

get_parameters_data_from_tzar_emulation <- function (
        running_tzar_or_tzar_emulator=TRUE,
        emulatingTzar=TRUE)
    {
        #  Need to set emulation flag every time you swap between emulating
        #  and not emulating.
        #  This is the only variable you should need to set for that.
        #  Make the change in the file called emulatingTzarFlag.R so that
        #  every file that needs to know the value of this flag is using
        #  the synchronized to the same value.

#  2017 01 02 - BTL
#  Should I change this to use something like "options(bdpg....=...)" instead?

        #  NOTE: The mainline Does need to know the value of this flag
        #  throughout, because it tests it when it's doing cleanup after
        #  a failure or at the end of a successful run.
        #  So, it will at least need to be an input argument to the mainline
        #  function, even if no tzar or tzar emulation is done.

    # source (paste0 (sourceCodeLocationWithSlash, "emulatingTzarFlag.R"))
    # #emulatingTzar = TRUE


        #-----------

        #  This flag is only set here to make clear what is being handed to
        #  the get_parameters() call's first argument.  You could just put
        #  a TRUE or FALSE value there since this variable is not used anywhere
        #  else in the mainline.
    # running_tzar_or_tzar_emulator = TRUE

    parameters = get_parameters (running_tzar_or_tzar_emulator, emulatingTzar)

    return (parameters)
    }

#===============================================================================
