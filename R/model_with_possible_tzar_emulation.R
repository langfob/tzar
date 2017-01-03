#===============================================================================

                    #--------------------------------------#
                    # model_with_possible_tzar_emulation.R #
                    #                 for                  #
                    #    example-tzar-emulator-R project   #
                    #--------------------------------------#

#===============================================================================

build_scratch_file_name <- function ()
    {
    # tzarEmulation_scratchFileName =
    #     file.path (tempdir(), "tzarEmulation_scratchFile.txt")

    tzarEmulation_scratchFileName =
        file.path ("/Users/bill/D/Projects/ProblemDifficulty/pkgs/tzar/tests/testthat",
                   "tzarEmulation_scratchFile.txt")

    return (tzarEmulation_scratchFileName)
    }

#===============================================================================

#' correct model.R code for tzar or tzar emulation
#'
#' @param parameters  list of parameters build by tzar from project.yaml
#' @param main_function  name of function to call to run under tzar or tzar emulation
#' @param projectPath path of R code and project.yaml file for project
#' @param tzarJarPath path of jar file containing executable tzar code
#' @param running_tzar_or_tzar_emulator boolean indicating TRUE if tzar or tzar emulation is to be run; FALSE otherwise
#' @param emulatingTzar boolean indicating TRUE if emulation tzar; FALSE if running tzar without emulation
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' correct_model_with_possible_tzar_emulation (parameters,
#'                                     main_function                 = trial_main_function,
#'                                     projectPath                   = ".",
#'                                     tzarJarPath                   = "~/D/rdv-framework-latest-work/tzar.jar",
#'                                     running_tzar_or_tzar_emulator = TRUE,
#'                                     emulatingTzar                 = TRUE
#'                                    )
#'}
correct_model_with_possible_tzar_emulation <- function (parameters,
                                                        main_function,
                                                projectPath,
                                                tzarJarPath,
                                                running_tzar_or_tzar_emulator=TRUE,
                                                emulatingTzar=TRUE
                                                )
    {
    if (! emulatingTzar)
        {
        cat ("\n\n=====>  In model.R: NOT emulatingTzar")

        main_function (parameters = parameters,
                       running_tzar_or_tzar_emulator = running_tzar_or_tzar_emulator,
                       emulatingTzar=emulatingTzar
                       )

        } else    #  emulating
        {
        cat ("\n\n=====>  In model.R: emulatingTzar")

        tzarEmulation_scratchFileName = build_scratch_file_name ()
                #"~/D/Projects/ProblemDifficulty/src/bdprobdiff/R/tzarEmulation_scratchFile.txt"

        parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

        cat (parameters$fullOutputDirWithSlash, "\n",
           file = tzarEmulation_scratchFileName, sep='' )
        }
    }

#===============================================================================

#' model.R code for tzar or tzar emulation
#'
#' @param main_function  name of function to call to run under tzar or tzar emulation
#' @param projectPath path of R code and project.yaml file for project
#' @param tzarJarPath path of jar file containing executable tzar code
#' @param running_tzar_or_tzar_emulator boolean indicating TRUE if tzar or tzar emulation is to be run; FALSE otherwise
#' @param emulatingTzar boolean indicating TRUE if emulation tzar; FALSE if running tzar without emulation
#'
#' @return parameters list of parameters loaded from project.yaml file
#' @export
#'
#' @examples \dontrun{
#' wrong_model_with_possible_tzar_emulation (main_function                 = trial_main_function,
#'                                     projectPath                   = ".",
#'                                     tzarJarPath                   = "~/D/rdv-framework-latest-work/tzar.jar",
#'                                     running_tzar_or_tzar_emulator = TRUE,
#'                                     emulatingTzar                 = TRUE
#'                                    )
#'}
wrong_model_with_possible_tzar_emulation <- function (main_function,
                                                projectPath,
                                                tzarJarPath,
                                                running_tzar_or_tzar_emulator=TRUE,
                                                emulatingTzar=TRUE
                                                )
    {
    cat ("\n\nCurrent working directory = '", getwd())
    setwd (projectPath)
    cat ("\n\nCurrent working directory = '", getwd())

    # tzarEmulation_scratchFileName =
    #     file.path (tempdir(), "tzarEmulation_scratchFile.txt")

    tzarEmulation_scratchFileName =
        file.path ("/Users/bill/D/Projects/ProblemDifficulty/pkgs/tzar/tests/testthat",
                   "tzarEmulation_scratchFile.txt")

    if (! emulatingTzar)
        {
        cat ("\n\n=====>  In model_with_possible_tzar_emulation(): NOT emulatingTzar")

#  source the mainline code here...
        main_function (parameters,
               running_tzar_or_tzar_emulator=running_tzar_or_tzar_emulator,
               emulatingTzar=emulatingTzar
               )

        } else    #  emulating
        {
        cat ("\n\n=====>  In model_with_possible_tzar_emulation(): emulatingTzar")

        }

cat ("\n\nAbout to get_parameters ('",
     projectPath, "', '", tzarJarPath, "', '", tzarEmulation_scratchFileName,
     "', ", emulatingTzar, ")")

    parameters = get_parameters (normalizePath (projectPath),
                                 normalizePath (tzarJarPath),
                                 normalizePath (tzarEmulation_scratchFileName),
                                 emulatingTzar
                                 )

cat ("\n\nAfter get_parameters(), parameters$fullOutputDirWithSlash = '",
     parameters$fullOutputDirWithSlash, "'\n")
browser()

        #  Retrieve the fullOutputDirWithSlash created by tzar
        #  that it saved in the parameters list and
        #  write it to the tzar emulation temporary file so that
        #  the main_function can figure out where tzar's output
        #  directory is.

    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName
    cat (parameters$fullOutputDirWithSlash, "\n",
         file = tzarEmulation_scratchFileName, sep='' )

    main_function (parameters,
                   running_tzar_or_tzar_emulator=running_tzar_or_tzar_emulator,
                   emulatingTzar=emulatingTzar
                   )

cat ("\n\nBack from main_function.\n")

    ######
        #  COULD YOU PUT THE TZAR CLEANUP IN HERE TOO IF YOU MOVE THE
        #  main_function() CALL INTO THE ELSE ABOVE AND DUPLICATE THAT
        #  MAIN CALL IN THE IF BRANCH AS WELL?
        #  If so, that would completely separate the tzar emulation out
        #  of the user's code.
    ######

    return (parameters)
    }

#===============================================================================

