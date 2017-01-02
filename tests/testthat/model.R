#===============================================================================

                        #-----------------------------------#
                        #               model.R             #
                        #                 for               #
                        #  example-tzar-emulator-R project  #
                        #-----------------------------------#

#===============================================================================

genSetCoverProblem = function (parameters)
    {
    cat ("\n\nDummy call to gen set cover().\n\n")
    }

#===============================================================================

emulatingTzar = TRUE
main_function = genSetCoverProblem

model_with_possible_tzar_emulation (main_function, emulatingTzar)

#===============================================================================

