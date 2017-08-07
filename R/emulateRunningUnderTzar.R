#===============================================================================

#                           emulateRunningUnderTzar.R

#===============================================================================

emulate_running_tzar = function (project_path,
                                 tzarEmulation_scratchFileName
                                 )
    {
        #-----------------------------------------------------------------------
        #  Probably never need to change these...
        #-----------------------------------------------------------------------

    tzarParametersSrcFileName           = "parameters.R"
    tzarEmulation_completedDirExtension = ".completedTzarEmulation"
    tzarInProgressExtension             = ".inprogress/"
    tzarFinishedExtension               = ""

        #-----------------------------------------------------------------------
        #  Need to set these variables just once, i.e., at start of a new project.
        #  Would never need to change after that for that project unless
        #  something strange like the path to the project or to tzar itself has
        #  changed.
        #  Note that the scratch file can go anywhere you want and it will be
        #  erased after the run if it is successful and you have inserted the
        #  call to the cleanup code at the end of your project's code.
        #  However, if your code crashes during the emulation, you may have to
        #  delete the file yourself.  I don't think it hurts anything if it's
        #  left lying around though.
        #-----------------------------------------------------------------------

    # #project_path = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R"
    # project_path = "~/D/Projects/ProblemDifficulty/src/bdprobdiff/R"

    # #tzar_jar_path = "~/D/rdv-framework/tzar.jar"
    # tzar_jar_path = "~/D/rdv-framework-latest-work/tzar.jar"

    # #tzarEmulation_scratchFileName = "~/D/rdv-framework/projects/rdvPackages/biodivprobgen/R/tzarEmulation_scratchFile.txt"
    # tzarEmulation_scratchFileName = "~/D/Projects/ProblemDifficulty/src/bdprobdiff/R/tzarEmulation_scratchFile.txt"

        #-----------------------------------------------------------------------
        #  Basing all of the stuff below on reading the rrunner.R file.
        #
        #  Run tzar with the current project.yaml file and a model.R file
        #  that does nothing other than
        #      - returns a successful completion
        #      - causes tzar to expand wildcards and create the output directory
        #        and write the json file and the parameters.R file,
        #      - then
        #
        #  To emulate the running under tzar, you just need to
        #  -  go to the output directory that tzar created
        #  -  source the parameters.R file from that directory
        #  -  start your normal code that would have run from the tzar
        #     output directory.
        #-----------------------------------------------------------------------

#    run_tzar_java_jar (tzar_jar_path, project_path)

        #----------------------------------------------------------
        #  tzar has wildcard-substituted the inProgress name throughout
        #  the parameters file, but when it completed its run, it renamed
        #  the directory to the finished name.
        #  We now want to reuse the parameters file, so we need to rename
        #  the directory back to the inProgress name.  Otherwise, we'd
        #  have to go through and substitute the finished directory name
        #  for all occurrences of the inProgress name in the parameters list.
        #  It might also be a bit misleading if the directory was left with
        #  the finished name after all is done even if the run may have
        #  crashed while running it outside tzar, so I think it's better
        #  to leave it named with inProgress.
        #
        #  - Read the inProgress dir name from the dumped file that
        #       contains nothing but that name.
        #       That file was written out at the end of the model.R
        #       code that does nothing but that when emulation is to be
        #       done.
        #
        #  - Next, strip off the inProgress extension to get
        #       the finished dir name and rename the finished dir
        #       back to inProgress.
        #
        #-----------------------------------------------------------------------

            #  Read dir name from something like:
            #      tzarEmulation_scratchFile.txt
            #  Resulting dir name is something like:
            #      "/Users/bill/tzar/outputdata/biodivprobgen/default_runset/827_default_scenario.inprogress/"
#    tzarInProgressDirName = readLines (tzarEmulation_scratchFileName)
    tzarInProgressDirName =
            get_tzarOutputDir_from_scratch_file (tzarEmulation_scratchFileName)

            #  Build the name of the directory that would result if tzar
            #  successfully ran to completion without emulation, e.g.,
            #      /Users/bill/tzar/outputdata/biodivprobgen/default_runset/828_default_scenario

    tzarFinishedDirName =
        gsub (tzarInProgressExtension,  #  e.g., ".inprogress/"
              tzarFinishedExtension,    #  e.g., ""
              tzarInProgressDirName)    #  The name loaded in previous command

            #  That is the name that will have been hung on the results of
            #  using the dummy model.R code to get tzar to build the
            #  directory structures and parameters list.
            #  However, the parameters list will have used the .inprogress
            #  extension instead of the finished directory name.
            #  So, to be able to use the parameters.R file as it was built
            #  during the dummy model.R run, we need to change the finished
            #  directory's name back to the .inprogress extension.
browser()
    file.rename (tzarFinishedDirName, tzarInProgressDirName)

        #-----------------------------------------------------------
        #  Finally, load the parameters list that tzar created and
        #  saved as an R file.
        #----------------------------------------------------------

    parametersListSourceFilename = paste0 (tzarInProgressDirName,
                                           "metadata/",  #  BTL added 2014 12 28
                                           tzarParametersSrcFileName)
    source (parametersListSourceFilename)

        #-----------------------------------------------------------
        #  Save directory names into the parameters list so that
        #  they can be used when cleaning up after emulation
        #  finishes, if it finishes successfully.
        #----------------------------------------------------------

    parameters$tzarInProgressDirName = tzarInProgressDirName

    parameters$tzarEmulationCompletedDirName =
        paste0 (tzarFinishedDirName, tzarEmulation_completedDirExtension)

    parameters$tzarEmulation_scratchFileName = tzarEmulation_scratchFileName

    return (invisible (parameters))
    }

#===============================================================================

