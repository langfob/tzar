#===============================================================================

                        #  model.R or model.R.tzar

#  If this code is to be used under tzar and NOT to be part of building a
#  package, then this file should be called model.R.

#  If instead, this will be part of building a package and occur in the R
#  directory of that package during a build, then its name cannot end in ".R".
#  By default, the tzar emulator's copying mechanism assumes that this file
#  will be called model.R.tzar (but you can call it whatever you want and
#  specify that name to the emulator in the emulator's yaml control file).
#  When emulation is run, this file will be copied in the same directory
#  as model.R.  During cleanup at the end of the emulation run, model.R will
#  be deleted but model.R.tzar will be left untouched.

#===============================================================================

library (tzar)

    #---------------------------------------------------------------------------
    #  If you're building a package and calling tzar from inside that package,
    #  uncomment this library call and put your package name in the call.
    #  If you're not building a package and you're using tzar with normal
    #  R code, then you can leave this line commented or just delete it.
    #  This is also where you would put library calls for any other libraries
    #  that you want included for the tzar run, e.g., if you needed some
    #  specialty database library.
    #---------------------------------------------------------------------------

#library (YOUR_PKG_NAME)

    #-----------------------------------------------------------------
    #  Call your project code via the "main_function" argument.
    #  You can call your main function anything you want.
    #  Just give its name where the example "tzar_main" function
    #  name is given below.
    #-----------------------------------------------------------------

tzar::model_with_possible_tzar_emulation (parameters,
                                          main_function = tzar_main,
                                          tzar_emulation_yaml_file_path = "./tzar_emulation.yaml")

#===============================================================================

