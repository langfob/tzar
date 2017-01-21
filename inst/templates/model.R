#===============================================================================

                        #-----------------------------------#
                        #              model.R              #
                        #-----------------------------------#

#===============================================================================

library (tzar)

    #---------------------------------------------------------------------------
    #  If you're building a package and calling tzar from inside that package,
    #  uncomment this library call and put your package name in the call.
    #  If you're not building a package and you're using tzar with normal
    #  R code, then you can leave this line commented or just delete it.
    #---------------------------------------------------------------------------

#library (YOUR_PKG_NAME)

    #-----------------------------------------------------------------
    #  Call your project code via the "main_function" argument.
    #  You can change any or all of the last 3 arguments if you need
    #  to for your project.
    #  However, you won't need to do that for most projects.
    #-----------------------------------------------------------------

model_with_possible_tzar_emulation (
        parameters,
        main_function               = tzar_main,
        projectPath                 = ".",
        emulation_scratch_file_path = "~/tzar_emulation_scratch.yaml"
                                    )

#===============================================================================

