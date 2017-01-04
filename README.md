<!-- README.md is generated from README.Rmd. Please edit that file -->
tzar
====

This package encapsulates R-related code for using the tzar code-running tool to manage doing lots of experiments. At the moment, this is primarily the R code required for emulating running tzar so that you get the tzar setup, file naming, and parameter file building without fully running tzar.

This allows you to run your code inside of R or RStudio in a way that allows you to do debugging, which is difficult or impossible to do when tzar has control of the entire process, e.g., on a remote machine.

Installation
------------

You can install tzar from github with:

``` r
# install.packages ("devtools")  
devtools::install_github ("langfob/tzar")
```

Simple example
--------------

Here is a simple example program to illustrate how to use the tzar emulator and how it works. We will consider a trivial program to print the value of a variable x. Not all of the example will make perfect sense until you have read the vignette, but it will give you a concrete idea of how you use tzar emulation and that should help make the details in the vignette easier to understand.

Suppose that we want to build a program that will just print the value of an input parameter x. Call the program print\_x() and suppose that it is in a file called print\_x.R.

``` r
print_x <- function (x)
    {
    cat ("\nValue of x = '", x, "'\n\n", sep='')
    }
```

### Print a value from a parameters list.

``` r
print_x <- function (parameters)
    {
    cat ("\nValue of x = '", parameters$x, "'\n\n", sep='')
    }

parameters <- list (x="a value from a list of parameters")
print_x (parameters)
#> 
#> Value of x = 'a value from a list of parameters'
```

### Print a value from a parameters list specified in a project.yaml file

Suppose that the project.yaml file contains:

``` yaml
project_name: simple_program
runner_class: RRunner

base_params:
    x: 100
```

#### To run under tzar emulation

We have to do 2 things:

-   First, we would have to edit the **model.R** file to set the argument variables correctly. Assuming that:

    -   the tzar jar file was in the directory "~/tzar"
    -   we want the tzar emulation scratch file in our home directory
        -   tzar emulation requires the use of a tiny scratch file that you don't need to know anything about, other than specifying where to put it.
        -   The file is deleted at the end of the run, so its location is not terribly important.
    -   the R code is in the current working directory

``` r
library (tzar)
source ("print_x.R")

main_function                 = print_x
projectPath                   =  "."
tzarEmulation_scratchFileName = "~/tzar_em_scratch.yaml"

model_with_possible_tzar_emulation (parameters,
                                    main_function,
                                    projectPath,
                                    tzarEmulation_scratchFileName
                                    )
```

-   Second, we would make a **function call** something like this one at the R prompt to run the program under tzar emulation:

``` r
run_mainline_under_tzar_or_tzar_emulation (
    main_function               = print_x,    #  note, no quotes on name
    projectPath                 = ".",
    tzarJarPath                 = "~/tzar/tzar.jar", 
    emulation_scratch_file_path = "~/tzar_em_scratch.yaml",
    emulatingTzar               = TRUE
    )
```

#### To run under normal tzar without emulation

We would leave model.R as above and then just change the final argument to run\_mainline\_under\_tzar\_or\_tzar\_emulation(), i.e., change emulatingTzar to FALSE:

``` r
run_mainline_under_tzar_or_tzar_emulation (
    main_function               = print_x,    #  note, no quotes on name
    projectPath                 = ".",
    tzarJarPath                 = "~/tzar/tzar.jar", 
    emulation_scratch_file_path = "~/tzar_em_scratch.yaml",
    emulatingTzar               = FALSE
    )
```

User steps required to enable tzar emulation
--------------------------------------------

For each project that uses tzar emulation, you will need to do the steps below, once at the start of the project. There are a fair number of these steps but they are all pretty simple. The reason for all this is that the whole process is a complete hack aimed at deceiving tzar into doing what we want. There has been talk of adding a "dry run" option to tzar to properly do what this hack does, but so far, it's just talk. In the meantime, this hack works.

-   **Copy the model.R file** from the package into your R source code area and in it, **set the following values** of the function called **in model.R**:
    -   variables to set
        -   main\_function
        -   projectPath
        -   tzarJarPath
        -   emulation\_scratch\_file\_path
    -   You may be able to add other code to the model.R file, but there are no guarantees that it will still run correctly if you do. You can examine the code in the function called there (model\_with\_possible\_tzar\_emulation()) to see whether other additions to model.R will be a problem. Generally though, model.R only exists to call your own code and won't need anything other than what is given in the template version.
-   Make sure that your **mainline application function has just one argument, a *parameters* argument**, regardless of whether it's used in your code or not.
-   Make sure that the **tzar package is loaded** for your code, e.g., "library(tzar)".
-   Make sure that you have a **project.yaml file in the projectPath directory**.
    -   This is a tzar requirement and not specific to tzar emulation.
-   **When running emulation** rather than normal tzar, make sure that the **project.yaml file is only doing a single run** rather than using tzar's ability to generate lots of runs (e.g., with a repetitions section).
    -   If you were to generate multiple runs, there would be ambiguity because there would be more than one place to look for the parameters.R file that tzar generates.
-   **Call the following function** at the R prompt or on RStudio's command line to invoke the whole process, i.e., to run your mainline application code under tzar or tzar emulation:

``` r
run_mainline_under_tzar_or_tzar_emulation (main_function,
                                           projectPath,
                                           tzarJarPath, 
                                           emulation_scratch_file_path,
                                           emulatingTzar
                                           )
```
