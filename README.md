<!-- README.md is generated from README.Rmd. Please edit that file -->
tzar
====

This package encapsulates R-related code for using the tzar code-running tool to manage doing lots of experiments. tzar itself is documented at and downloadable from <https://tzar-framework.atlassian.net/wiki/display/TD/Tzar+documentation>.

The code in the tzar R package is primarily the R code required for emulating running tzar so that you get the tzar setup, file naming, and parameter file building without fully running tzar. This allows you to run your code inside of R or RStudio in a way that allows you to do debugging, which is difficult or impossible to do when tzar has control of the entire process, e.g., on a remote machine.

Installation
------------

You can install the R package for running tzar from within R using the following commands which retrieve the package from github:

``` r
# install.packages ("devtools")  
devtools::install_github ("langfob/tzar")
```

The basic idea behind the emulator (for experienced tzar users)
---------------------------------------------------------------

The basic idea is that running tzar with an empty model.R produces all the same setup as running with a model.R that calls your application code. Consequently, you could run tzar with an empty model.R, go look for the most recent directory that tzar had created, then load the parameters.R file from that directory. At that point, you could run your own application code with the newly loaded parameters list and it would be nearly indistinguishable from running your code under tzar but you would have control of your code for debugging, etc. The emulator just automatically manages the finding, loading, and running for you. It also manages a few other details of directory naming to indicate that a job ran and/or failed under emulation.

SUMMARY: User steps required to enable tzar emulation
-----------------------------------------------------

For each project that uses tzar emulation, you will need to do the steps below, once at the start of the project. There are a few of these steps but they are all pretty simple.
- The reason for all this is that the whole process is a complete hack aimed at deceiving tzar into doing what we want. There has been talk of adding a "dry run" option to tzar to properly do what this hack does, but so far, it's just talk. In the meantime, this hack works.

### The basic idea

-   **Once for each project** where you want to use tzar emulation:
    -   **Copy the *tzar\_main* and *model* template files** from the tzar package
    -   **Edit the *model* template** if necessary
    -   **Edit the *tzar\_main* template** to match your project's directories, etc.
    -   Make sure that the ***tzar package* is loaded**.
    -   Make sure that you have a ***project.yaml* file in the projectPath directory**.
-   **Each time you want to run tzar or tzar emulation** on that project:
    -   **Run runtip() or runtop()**

### Details of each step

-   **Copy the R template files** from the package into the R source code area where you want to work.
    -   In the code below, replace *YOUR\_R\_WORKING\_AREA* with the location of the R code for your project.
    -   Also, note that *get\_tzar\_R\_templates()* has two arguments that you can modify if you need to, i.e., the target directory and a flag indicating whether model.R should be renamed to model.R.tzar or left as model.R. It never hurts to leave the flag set to the default value of TRUE because that will never accidentally overwrite a model.R file that you may have already created in your work area.

``` r
library (tzar)
get_tzar_R_templates ("YOUR_R_WORKING_AREA")
```

-   **Edit model.R (or model.R.tzar if that's what was copied in)**
    -   If building a package, **load your package** in model.R
        -   Uncomment "\#library (YOUR\_PKG\_NAME)"
        -   Replace YOUR\_PKG\_NAME with the name of your package
    -   **Set the following arguments** of the function called **in model.R** if their default values are not appropriate for your project. In most cases, you shouldn't need to change their default values, particularly when you are first learning how to use tzar emulation.
        -   main\_function
        -   projectPath
        -   emulation\_scratch\_file\_path
-   **Edit tzar\_main.R**
    -   **Replace the dummy code in the tzar\_main() function** with code appropriate to your project.
        -   For the first test of using tzar emulation in your project, you probably want to just leave the dummy code there and make sure that the tzar call works and echoes the values from the project.yaml file.
        -   Subsequently, tzar\_main() will probably just contain a single call to the main function of your project with the parameters list as the only argument.
    -   **Edit arguments to calls in runtip() and/or runtop()** to match your project.
        -   runtip() and runtop() are convenience functions to allow you to quickly run tzar emulation at the command line without having to constantly retype long lists of arguments that are nearly always the same within a given project.
            -   runt**i**p() is the function for working INSIDE building a package
            -   runt**o**p() is the function for working OUTSIDE building a package, i.e., when just doing normal R development.
            -   If you're building a package, then you won't even need the runtop() function in that project so you can even delete or ignore the runt**o**p() function.
            -   Similarly, if you're not building a package and expect to never try to turn the code you're working on into a package, then you won't need runt**i**p() and can delete or ignore it.
        -   The arguments for runtip() and runtop() are listed below and are the same for both functions. Bold arguments are the ones whose default values probably need to be replaced. The others can be modified but probably don't need to be:
            -   emulating\_tzar
            -   main\_function
            -   **project\_path** (e.g., "~/mypkg/R")
            -   emulation\_scratch\_file\_path
            -   **tzar\_jar\_path** (e.g., "~/myTzarJarDir/tzar.jar")
            -   copy\_model\_R\_tzar\_file
            -   model\_R\_tzar\_src\_dir
            -   model\_R\_tzar\_disguised\_filename
            -   overwrite\_existing\_model\_R\_dest
                -   If you're inexperienced with the emulator, it's best to leave this set to the default value of FALSE. Details about this flag are given in a separate note below.
            -   required\_model\_R\_filename\_for\_tzar
-   Make sure that the **tzar package is loaded** for your code.
    -   If just running normal R code, then including "library(tzar)" somewhere works.
    -   If building a package, then you need to include tzar in your Suggests or Depends in your package's DESCRIPTION file.
        -   If you're only using tzar while building the package and a user of your package would not use tzar, then it can just be in the Suggests instead of in the Depends.
-   Make sure that you have a **project.yaml file in the projectPath directory**.
    -   This is a tzar requirement and not specific to tzar emulation.
    -   **When running emulation** rather than normal tzar, make sure that the **project.yaml file is only doing a single run** rather than using tzar's ability to generate lots of runs (e.g., with a repetitions section).
        -   If you were to generate multiple runs, there would be ambiguity because there would be more than one place to look for the parameters.R file that tzar generates.

------------------------------------------------------------------------

#### Details about the *overwrite\_existing\_model\_R\_dest* in runtip() and runtop() calls

The *overwrite\_existing\_model\_R\_dest* flag in calls to runtip() and runtop() is primarily there as a precaution to make sure that tzar emulation doesn't overwrite some existing version of model.R that you might have built in your R directory before starting to use tzar emulation. This is necessary because the emulator may be copying model.R.tzar into model.R and that could destroy your existing work if you've already built a model.R file. If you do have an existing model.R with contents you want included in tzar emulation, you'll have to combine the contents of your model.R and the template model.R to make sure that the emulator also has what it needs.

In general, the safest thing to do is to leave this flag as FALSE. However, in the early stages of developing a package your code may crash in ways that mean the emulator never gets to clean up after itself. In that case, its copied version of model.R from the previous run might still be left in the R directory when the copy from model.R.tzar tries to take place and the attempted overwrite will throw an error, even though it's not really an error in this case. It's just being extra cautious not to destroy work you may have done that it didn't know about.

If you do get this error about attempting to overwrite model.R and it's just the leftover model.R from a previous copy, you just have to delete the old model.R and this will let the emulator copy the model.R.tzar into model.R. If the *overwrite\_existing\_model\_R\_dest* flag is set to TRUE instead of FALSE, then model.R will always be overwritten and you won't have to worry about any of this but it won't be defaulting to the safest behavior.

If you're working in a package and have only been working on model.R.tzar with the emulator copying it each time into model.R with no separate model.R of your own, then this is no problem. Setting *overwrite\_existing\_model\_R\_dest* to TRUE is fine in that case and will save you from having to delete the old model.R when your code has crashes severe enough to not allow the emulator to clean up after itself. This should be rare though.

------------------------------------------------------------------------
