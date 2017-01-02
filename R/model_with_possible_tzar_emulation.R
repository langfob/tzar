#===============================================================================

                    #--------------------------------------#
                    # model_with_possible_tzar_emulation.R #
                    #                 for                  #
                    #    example-tzar-emulator-R project   #
                    #--------------------------------------#

#===============================================================================

model_with_possible_tzar_emulation <- function (main_function,
                                                emulatingTzar=TRUE)
    {
    cat ("\n\nCurrent working directory = '", getwd(), "'\n\n")

    if (! emulatingTzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulatingTzar")

        } else    #  emulating
        {
        tzarEmulation_scratchFileName =
            file.path (tempdir(), "tzarEmulation_scratchFile.txt")

        parameters = list()
        parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

        cat (parameters$fullOutputDirWithSlash, "\n",
             file = tzarEmulation_scratchFileName, sep='' )
        }

    main_function (parameters)
    }

#===============================================================================

