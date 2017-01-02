#===============================================================================

                    #--------------------------------------#
                    # model_with_possible_tzar_emulation.R #
                    #                 for                  #
                    #    example-tzar-emulator-R project   #
                    #--------------------------------------#

#===============================================================================

model_with_possible_tzar_emulation <- function (main_function,
                                                projectPath,
                                                tzarJarPath,
                                                running_tzar_or_tzar_emulator=TRUE,
                                                emulatingTzar=TRUE
                                                )
    {
    cat ("\n\nCurrent working directory = '", getwd(), "'\n\n")

    parameters = get_parameters (projectPath,
                                 tzarJarPath,
                                 tzarEmulation_scratchFileName,
                                 emulatingTzar
                                 )

    if (! emulatingTzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulatingTzar")

        } else    #  emulating
        {
        tzarEmulation_scratchFileName =
            file.path (tempdir(), "tzarEmulation_scratchFile.txt")

        parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

        cat (parameters$fullOutputDirWithSlash, "\n",
             file = tzarEmulation_scratchFileName, sep='' )
        }

    main_function (parameters,
                   running_tzar_or_tzar_emulator=running_tzar_or_tzar_emulator,
                   emulatingTzar=emulatingTzar
                   )

    ######
        #  COULD YOU PUT THE TZAR CLEANUP IN HERE TOO IF YOU MOVE THE
        #  main_function() CALL INTO THE ELSE ABOVE AND DUPLICATE THAT
        #  MAIN CALL IN THE IF BRANCH AS WELL?
        #  If so, that would completely separate the tzar emulation out
        #  of the user's code.
    ######


    }

#===============================================================================

