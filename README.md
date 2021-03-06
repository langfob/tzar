
<!-- README.md is generated from README.Rmd. Please edit that file -->


# tzar

Since this README gets most of its exercise as a quick reminder of 1) the main steps involved in using the package and 2) fixes for commonly occurring problems, those two sections occur first here.  The usual introductory explanation of the package and how to install it are given further down, starting at the heading "Introduction" and continuing from there.

------------------------------------------------------------

##  Quick Start

### Installation  
You can install the R package for running tzar from within R using the 
following commands which retrieve the package from github:  
```R
# install.packages ("devtools")    #  Uncomment line if devtools is not installed
devtools::install_github ("langfob/tzar")
```

### Basic user steps required to enable tzar emulation

For each project that uses tzar emulation, you will need to do the steps below, once at the start of the project. There are a few of these steps but they are all pretty simple.  Note that each of the steps is explained in much more detail further down in this document.  Only the basic idea of each is summarized in  this section.  

###  Once for each project:

- *Load the tzar package library*
    - e.g., via `library (tzar)`
- *Copy the template files* from the tzar package inst/templates area to your source code area
    - Do this using `get_tzar_pkg_templates()` in your source area, which will copy:
        - tzar_main.R
        - model.R (into model.R or model.R.tzar, see Details section below)
        - tzar_emulation.yaml
-  *Edit each file* to match your project and options as necessary
- Make sure that 
    - you have your *_project.yaml_ file* in tzar's projectPath directory and 
    - its base_params section contains the following line to retrieve the directory where tzar writes a run's output:
```
    full_output_dir_with_slash: $$output_path$$
```

### Each time you run your R code under tzar emulation:
- *Call `runt` or `run_tzar`* at command line

------------------------------------------------------------

## Simple example (with lots of explanation)

Once you have installed the tzar package, you can verify that everything is working by stepping through this simple example.

####  Create a test directory and move into it.

Create a directory called `tzar_em_example` anywhere you like, then cd into it.

```
mkdir tzar_em_example
cd tzar_em_example
```

#### Create a simple project.yaml file in the test directory

If this was an existing project, you would probably already have a project.yaml file, but since you're doing this example from scratch, we need to create one.  So, create a project.yaml file and paste the following lines into it to give the minimal required information for a tzar project.yaml file:
```
project_name: tzar_em_example
runner_class: RRunner

base_params:
    full_output_dir_with_slash: $$output_path$$    #  REQUIRED for emulation.
    some_other_variable: 5                         #  An example user variable
```

Note that yaml will have a heart attack if the indentations are tabs instead of spaces, so be sure that there are no tabs.

####  Get the tzar template files

Start R and check that you are sitting in the `tzar_em_example` directory using the `getwd` command.  If not, then move there using the `setwd` command.  

Load the `tzar` package (assuming you've already installed it) and get the tzar template files.  Since you're not doing this testing inside of building a package, set the function's 2nd argument to specify that you're not going to be running the emulator inside a package build:
```R
library (tzar)
get_tzar_pkg_templates (target_dir = ".", running_inside_a_package = FALSE)
```

Counting the project.yaml file, there should now be 4 files in the directory:  
```
> library (tzar)
> get_tzar_pkg_templates (target_dir = ".", running_inside_a_package = FALSE)
NULL

> dir()
[1] "model.R"             "project.yaml"        "tzar_emulation.yaml"
[4] "tzar_main.R"        
```

####  Modify the template files to suit this example  

Open the template files in a text editor and do the project-specific setup modifications to each of them.  

Note that in what follows, all instances of `tzar_main` throughout the code are replaced with `my_main_code` just to show that you can put whatever you want there.  There is nothing special about `tzar_main`; it's just an easy convention that minimizes editing when doing this setup work across different projects.

**First**, for this very simple example, **model.R** can be chopped down to just these two lines:
```
library (tzar)
tzar::model_with_possible_tzar_emulation (
                    parameters,
                    main_function = tzar_main,
                    tzar_emulation_yaml_file_path = "./tzar_emulation.yaml")
```

**Second**, everything in **tzar_main.R** can be replaced with the lines in the code box below.  These lines define 2 functions that replace the 2 functions in the template. 

The first function is `my_main_code` which would be the mainline routine for all of your project code.  

- Aside: Normally, in a big project, the `my_main_code()` function would probably already be in some other ".R" file.  In that case:
    - you would probably plug the name `my_main_code` into the center of the `tzar_main()` function definition as it appears in the template file rather than including the definition of the `my_main_code()` function in `tzar_main.R`.  
    - your model.R code would specify the `main_function = my_main_code` argument using `tzar_main` instead, i.e., `main_function = tzar_main`.  

The second function, `runt()` is short for "run tzar" and is a project-specific convenience function that saves you having to type out the much longer, more complex call to `run_tzar` that is given inside the definition of `runt()` here.  

- You don't even need to have a function like this defined at all if you don't mind typing out the full `run_tzar` command.
- If you do define this function, you can call it anything that is convenient for you because it's never referred to by any functions in the tzar package.  Originally, it was called `rt`, but that conflicted with a base R method.  `runt` was just a short mnemonic name unlikely to conflict.  

Here, the arguments to `run_tzar` inside `runt` are slightly modified from the template so that they match this project.  In particular,   

- the "/R" parts of the yaml paths are removed since there is no R directory here.
- the `main_function` argument is changed from `tzar_main` to `my_main_code`.

```R
my_main_code <- function (parameters, emulating_tzar=FALSE)
    {
    cat ("\nInside my_main_code():")
    cat ("\n    parameters$full_output_dir_with_slash = \n'",
         parameters$full_output_dir_with_slash,
         "'")
    cat ("\n    parameters$some_other_variable = '",
         parameters$some_other_variable,
         "'\n")
    }

runt <- function ()
    {
    tzar::run_tzar (main_function = my_main_code,
                    parameters_yaml_file_path = "./project.yaml",
                    tzar_emulation_yaml_file_path = "./tzar_emulation.yaml")
    }
```

**Finally**, edit **tzar_emulation.yaml** to reflect this simple example.

No values need to be changed except for the tzar_jar_name_with_path.  You need to replace "[FULL PATH TO YOUR TZAR JAR]" with the full path and file name for the tzar jar file on your machine, e.g., "~/tzar_jars/tzar-0.5.5.jar". 

```
emulating_tzar:                         TRUE

echo_console_to_temp_file:              TRUE
console_out_file_name_with_path:        "./console_sink_output.tzar_em.txt"

project_path:                           "."
tzar_jar_name_with_path:                "[FULL PATH TO YOUR TZAR JAR]"
emulation_scratch_file_name_with_path:  "./tzar_em_scratch.yaml"

copy_model_dot_R_tzar_file:             FALSE
model_dot_R_tzar_SRC_dir:               "."
model_dot_R_tzar_disguised_filename:    "model.R.tzar"
required_model_dot_R_filename_for_tzar: "model.R"
overwrite_existing_model_dot_R_DEST:    FALSE
```

####  Run the code

You should now be ready to load the main code in R and then run the emulation.  Assuming you're still in the tzar_em_example directory:

```R
source ("tzar_main.R")
runt()
```

This produces the output in the box below.  The beginning of the output is boilerplate that can be ignored.  (NOTE:  In what follows below, the text appearing as "[...]" will be replaced by path information specific to your machine.)

```
> runt()
Created 1 runs. 
Outputdir: [...]/tzar_em_example/default_runset/1_default_scenario.inprogress 
Running model: [...]/tzar_em_example/., run_id: 1, Project name: tzar_em_example, Scenario name: default_scenario, Flags:  
Run 1 succeeded. 
Executed 1 runs: 1 succeeded. 0 failed 

In run_tzar:  Finished running dummy EMULATION code under tzar.
               Ready to go back and run real code outside of tzar...
```

However, after the boilerplate, notice the following things:

- The value of `parameters$full_output_dir_with_slash` has captured the directory that tzar built for your program's run, i.e., `[...]/tzar_em_example/default_runset/1_default_scenario.inprogress/`.
    - Notice the `.inprogress` extension on the directory name.  
        - That is the name of the directory while the emulation is running.  
        - If it runs to completion, the emulator replaces that extension with `.completedTzarEmulation` to show that this was an emulation run.
        - If it fails during emulation, the extension will still say `.inprogress` since the cleanup stage was never reached.

- The value of `parameters$some_other_variable` is printed as "5", as it should since that's the value in the project.yaml file.

```
Inside my_main_code():
    parameters$full_output_dir_with_slash = 
' [...]/tzar_em_example/default_runset/1_default_scenario.inprogress/ '
    parameters$some_other_variable = ' 5 '
```

- The output then shows the location of the final outputs after the emulator has renamed everything to indicate successful completion of the emulation.  If you examine the `1_default_scenario.completedTzarEmulation` directory you will find the usual tzar metadata files in the `metadata` subdirectory.

```
Final tzar output is in:
    '[...]/tzar_em_example/default_runset/1_default_scenario.completedTzarEmulation'
```

- Because the tzar_emulation.yaml file in this example sets the `echo_console_to_temp_file` flag to TRUE, there should also be a copy of the console sink output in the metadata directory of `1_default_scenario.completedTzarEmulation`.  

```
In clean_up_console_sink:

Closing sink file.

destination for sink file move = ' [...]/tzar_em_example/default_runset/1_default_scenario.inprogress/metadata/console_sink_output.tzar_em.txt '


In run_tzar:  Finished running tzar WITH emulation... 
```
- If you open that file in a text editor, you should see something like this:

```


In run_tzar:  Finished running dummy EMULATION code under tzar.
               Ready to go back and run real code outside of tzar...
Inside my_main_code():
    parameters$full_output_dir_with_slash = 
' [...]/tzar_em_example/default_runset/1_default_scenario.inprogress/ '
    parameters$some_other_variable = ' 5 '


Final tzar output is in:
    '[...]/tzar_em_example/default_runset/1_default_scenario.completedTzarEmulation'



In clean_up_console_sink:

Closing sink file.
```

That's the end of the simple example.  Next, we discuss some common problems that can come up in tzar  emulation, particularly when you're first using it.

------------------------------------------------------------

## Common emulation errors and fixes

#### model.R when using tzar emulation *while building a package*
No matter what problem you're having while using tzar emulation inside of 
building a package, look first to see if R/model.R exists.  If it does, then 
you should probably delete it and retry whatever you're doing (e.g., running 
`runt()` or doing a Build, etc.)  The presence of model.R (instead of 
having it built automatically from model.R.tzar) seems to cause all kinds 
of strange errors whose messages make no mention at all of model.R and lead 
you astray.  

This kind of a problem generally only occurs when you're doing a build after you've just done a run that crashed.  When the emulator options flag that you're doing emulation inside a package, the emulator will automatically delete the model.R file at the end of a successful emulation run.  However, if it crashes during the run, it never gets to the cleanup and never deletes the model.R and you get the errors discussed here.

Note however, all of this only applies when you're using tzar emulation in 
building a package, i.e., in a case where the model.R.tzar file is copied 
as model.R.  If you're not working inside a package, then model.R does not 
need to be copied and *should* be sitting there and should **not** be 
deleted.  See explanations in Section *"runt() and tzar emulation inside a 
package"* below for why.

#### "cyclic namespace dependency" error when doing a package build after a model run that crashed
- This seems to happen when 
    - the emulator is creating model.R by copying model.R.tzar before each run and 
    - the previous run crashed without cleaning up and deleting the model.R file
- It's unclear why this leads to the build problem, but the solution seems to be to just delete the model.R file and try the build again.
    

#### No repetitions - Only single model runs are allowed under emulation
The emulator only allows single runs of the model because it's giving control 
back to the single R process that called it.  If there were multiple 
repetitions, it would not be clear which process to hand control back to. 
Consequently, you should not have multiple repetitions invoked in a tzar 
yaml file's *repetitions* section during emulation.  

------------------------------------------------------------

------------------------------------------------------------

## Introduction

This R package encapsulates R-related code for getting some of the benefits of using the java-based code-running tool called tzar while still having access to debugging.  

The java program called tzar provides significant assistance for managing a set of computer experiments by scheduling, tracking, and documenting many different runs with many different program runs with many different parameter settings.  tzar itself is documented at and downloadable from 
https://tzar-framework.atlassian.net/wiki/display/TD/Tzar+documentation.

Unfortunately, because java tzar spawns separate processes for each run of the underlying experiment's R code, it can be difficult to debug that code since you no longer have access to the running process in the same way that you do when running the code inside RStudio or an R command line session.  This is particularly problematic when your R code is making use of variables whose values are provided by tzar such as the location of the java tzar output directory for the current experiment's run.  

The code in the tzar R package described here is primarily the R code required for emulating running tzar so that you get the tzar setup, file naming, and parameter file building without fully running tzar. This allows you to run your code inside of R or RStudio in a way that allows you to do debugging, which is difficult or impossible to do when tzar has control of the entire process, e.g., on a remote machine.

Note that in the explanations below, there are a number of small things that 
you have to pay attention to, but they are primarily things that you do one 
time for your project and after that, everything happens behind the scenes. 
Your use of tzar emulation is then reduced to a single call such as 
`runt()`.  Those functions are explained below.

The reason for all this is that the whole process is a complete hack aimed at deceiving java tzar into doing what we want.  There has been talk of adding a "dry run" option to tzar to properly do what this hack does, but so far, it's just talk.  In the meantime, this hack works with little intervention on your part once it is set up for a given project.  Note that if you prefer not to install this package and don't mind doing a bit more intervention every time you do a run, a simple procedure for doing that is explained later in this README under the heading "The basic idea behind the emulator".


------------------------------------------------------------

------------------------------------------------------------


#  ... README from here on is not finished...

Most of it is old text from before the change to using the tzar_emulation.yaml file instead of hard-coding arguments to some functions.


------------------------------------------------------------

------------------------------------------------------------

## Emulation control file tzar_emulation.yaml
Tzar emulation is controlled by a separate yaml file where emulation options 
and parameters are stored.  By default, this file is called tzar_emulation.yaml 
but you can specify any name you want.  

blah blah blah

project.yaml must contain the following line in the base_params section:
    full_output_dir_with_slash: $$output_path$$



------------------------------------------------------------

## runt() and run_tzar()
```run_tzar()``` is the function that you call to do the work of running your code 
under tzar emulation, however, it's generally much less typing to do it using a  
helper function such as `runt()` that supplies all of your commonly used 
arguments for calling ```run_tzar()```.  

####  runt() and tzar emulation *inside* a package being built
When tzar runs, it needs to find and run a file called model.R and that file 
is where you have some or all of your program's code or make calls to 
elements of that code.  The only problem with this is that when R builds  
a package, it runs every ".R" file in the R directory of the package, on the 
assumption that these files contain function definitions rather than live code. 
Unfortunately, this includes the "model.R" file required by tzar. 
Since that code runs a model rather than defines a function, you don't want 
it to be called when R is building a package (e.g., when/if CRAN is building 
your package).  

    emulating_tzar:                         TRUE
    echo_console_to_temp_file:              TRUE

    project_path:                           "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"
    tzar_jar_path:                          "~/D/rdv-framework-latest-work/tzar.jar"
    emulation_scratch_file_path:            "~/tzar/tzar_emulation_scratch_area/tzar_emulation_scratch.yaml"

    copy_model_dot_R_tzar_file:             TRUE
    model_dot_R_tzar_SRC_dir:               "/Users/bill/D/Projects/ProblemDifficulty/pkgs/bdpgxupaper/R"    #"."    #system.file("templates", package="bdpgxupaper")
    model_dot_R_tzar_disguised_filename:    "model.R.tzar"
    required_model_dot_R_filename_for_tzar: "model.R"
    overwrite_existing_model_dot_R_DEST:    TRUE

One way to get around this is to rename model.R to something else and then copy 
that file into a new model.R when tzar emulation is run.  That is what 
```run_tzar()``` does when the emulation control parameters ```emulating_tzar``` 
and ```copy_model_dot_R_tzar_file``` are set to TRUE in the control file. 
First it does the copy and then it calls run_tzar() 
for you with the appropriate arguments.  "runtip" stands for "run tzar 
emulation inside a package".  

Because there are various parts of this process 
that are specific to your program, runtip() is provided as a template that you 
must modify.  The template code is in the file inst/templates/tzar_main.R.  You 
copy that file into your R area and modify that copy of the file to fit your 
project.  That file will then be the one that is run by R when it builds the 
package.  

####  runt() and tzar emulation outside a package
If you are not building a package (and therefore, R is not automatically 
running every ".R" file in your code directory), then you don't have to worry 
about renaming the "model.R" file to hide it.  Instead, you can have your 
model.R file in with your other R code and you can run tzar 
emulation by calling run_top() instead of run_tip().  The runtop() function 
is also templated in the inst/templates/tzar_main.R file and you need to 
modify it in the copy of tzar_main.R inside your R code directory just as 
you would have modified the runtip() function.  Similarly, you could just 
use run_tzar() directly if you prefer.  runtop() is just a convenience function. 

####  Running tzar without emulation
Once you have your code ready to a point where you no longer want to run 
emulation, then you no longer run runtip() or runtop() or run_tzar().  You 
just run tzar with the usual tzar command line invocation under java.

------------------------------------------------------------

###  The basic idea behind the emulator (for experienced tzar users)

The basic idea is that running tzar with an empty model.R produces all the same setup as running with a model.R that calls your application code.  Consequently, you could run tzar with an empty model.R, go look for the most recent directory that tzar had created, then source the parameters.R file from that directory.  At that point, you could run your own application code with the newly loaded parameters list and it would be nearly indistinguishable from running your code under tzar but you would have control of your code for debugging, etc.  

The emulator just automatically manages the finding, loading, and running for you.  It also manages a few other details of directory naming to indicate that a job ran and/or failed under emulation.  In the end, the most useful thing is that it allows you to have a single, quickly typed function call of your choice (e.g., `runt()`) that can be run over and over again when you're doing many rapid cycles of run/debug/fix/rerun.

------------------------------------------------------------

##  Details of each step in using the emulator

- **Copy the R template files** from the package into the R source code area where you want to work.
    - In the code below, replace *YOUR_R_WORKING_AREA* with the location of the R code for your project.
    - Also, note that *get_tzar_R_templates()* has two arguments that you can modify if you need to, i.e., the target directory and a flag indicating whether model.R should be renamed to model.R.tzar or left as model.R.  It never hurts to leave the flag set to the default value of TRUE because that will never accidentally overwrite a model.R file that you may have already created in your work area.


```r
library (tzar)
get_tzar_R_templates ("YOUR_R_WORKING_AREA")
```

- **Edit model.R (or model.R.tzar if that's what was copied in)**
    - If building a package, **load your package** in model.R
        - Uncomment "#library (YOUR_PKG_NAME)"
        - Replace YOUR_PKG_NAME with the name of your package
    - **Set the following arguments** of the function called **in model.R** if their default values are not appropriate for your project.  In most cases, you shouldn't need to change their default values, particularly when you are first learning how to use tzar emulation.
        - main_function
        - projectPath
        - emulation_scratch_file_path

- **Edit tzar_main.R**
    - **Replace the dummy code in the tzar_main() function** with code appropriate to your project.
        - For the first test of using tzar emulation in your project, you probably want to just leave the dummy code there and make sure that the tzar call works and echoes the values from the project.yaml file.
        - Subsequently, tzar_main() will probably just contain a single call to the main function of your project with the parameters list as the only argument.
    - **Edit arguments to calls in runtip() and/or runtop()** to match your project.
        - runtip() and runtop() are convenience functions to allow you to quickly run tzar emulation at the command line without having to constantly retype long lists of arguments that are nearly always the same within a given project.
            - runt**i**p() is the function for working INSIDE building a package
            - runt**o**p() is the function for working OUTSIDE building a package, i.e., when just doing normal R development.
            - If you're building a package, then you won't even need the runtop() function in that project so you can even delete or ignore the runt**o**p() function.  
            - Similarly, if you're not building a package and expect to never try to turn the code you're working on into a package, then you won't need runt**i**p() and can delete or ignore it.
        - The arguments for runtip() and runtop() are listed below and are the same for both functions.  Bold arguments are the ones whose default values probably need to be replaced.  The others can be modified but probably don't need to be:
            - emulating_tzar
            - main_function
            - **project_path** (e.g., "~/mypkg/R")
            - emulation_scratch_file_path
            - **tzar_jar_path** (e.g., "~/myTzarJarDir/tzar.jar")
            - copy_model_R_tzar_file
            - model_R_tzar_src_dir
            - model_R_tzar_disguised_filename
            - overwrite_existing_model_R_dest
                - If you're inexperienced with the emulator, it's best to leave this set to the default value of FALSE.  Details about this flag are given in a separate note below.
            - required_model_R_filename_for_tzar
   
- Make sure that the **tzar package is loaded** for your code.  
    - If just running normal R code, then including "library(tzar)" somewhere works.
    - If building a package, then you need to include tzar in your Suggests or Depends in your package's DESCRIPTION file.  
        - If you're only using tzar while building the package and a user of your package would not use tzar, then it can just be in the Suggests instead of in the Depends.  

- Make sure that you have a **project.yaml file in the projectPath directory**.   
    - This is a tzar requirement and not specific to tzar emulation.
    - **When running emulation** rather than normal tzar, make sure that the **project.yaml file is only doing a single run** rather than using tzar's ability to generate lots of runs (e.g., with a repetitions section).  
        - If you were to generate multiple runs, there would be ambiguity because there would be more than one place to look for the parameters.R file that tzar generates.
        
- After all of that setup is done, each time you want to do a run of your application code under tzar or tzar emulation:
    - Call runtip() at the R command prompt if you're running as part of developing a package
    - Call runtop() at the R command prompt if you're running normal R code that is outside of developing a package.

------------------------------------------------------------

####  Details about the *overwrite_existing_model_R_dest* in runt() calls

The *overwrite_existing_model_R_dest* flag in calls to runtip() and runtop() is primarily there as a precaution to make sure that tzar emulation doesn't overwrite some existing version of model.R that you might have built in your R directory before starting to use tzar emulation.  This is necessary because the emulator may be copying model.R.tzar into model.R and that could destroy your existing work if you've already built a model.R file.  If you do have an existing model.R with contents you want included in tzar emulation, you'll have to combine the contents of your model.R and the template model.R to make sure that the emulator also has what it needs.  

In general, the safest thing to do is to leave this flag as FALSE.  However, in the early stages of developing a package your code may crash in ways that mean the emulator never gets to clean up after itself.  In that case, its copied version of model.R from the previous run might still be left in the R directory when the copy from model.R.tzar tries to take place and the attempted overwrite will throw an error, even though it's not really an error in this case.  It's just being extra cautious not to destroy work you may have done that it didn't know about.  

If you do get this error about attempting to overwrite model.R and it's just the leftover model.R from a previous copy, you just have to delete the old model.R and this will let the emulator copy the model.R.tzar into model.R.  If the *overwrite_existing_model_R_dest* flag is set to TRUE instead of FALSE, then model.R will always be overwritten and you won't have to worry about any of this but it won't be defaulting to the safest behavior.  

If you're working in a package and have only been working on model.R.tzar with the emulator copying it each time into model.R with no separate model.R of your own, then this is no problem.  Setting *overwrite_existing_model_R_dest* to TRUE is fine in that case and will save you from having to delete the old model.R when your code has crashes severe enough to not allow the emulator to clean up after itself.  This should be rare though.

