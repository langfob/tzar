#===============================================================================
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
