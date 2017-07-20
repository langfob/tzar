## ------------------------------------------------------------------------
print_x <- function (x)
    {
    cat ("\nValue of x = '", x, "'\n\n", sep='')
    }

## ------------------------------------------------------------------------
print_x <- function (parameters)
    {
    cat ("\nValue of x = '", parameters$x, "'\n\n", sep='')
    }

parameters <- list (x="a value from a list of parameters")
print_x (parameters)

## ---- eval=FALSE---------------------------------------------------------
#  project_name: simple_program
#  runner_class: RRunner
#  
#  base_params:
#      x: 100

## ----eval=FALSE----------------------------------------------------------
#  library (tzar)
#  source ("print_x.R")
#  
#  main_function                 = print_x
#  projectPath                   =  "."
#  tzarEmulation_scratchFileName = "~/tzar_em_scratch.yaml"
#  
#  model_with_possible_tzar_emulation (parameters,
#                                      main_function,
#                                      projectPath,
#                                      tzarEmulation_scratchFileName
#                                      )
#  

## ----eval=FALSE----------------------------------------------------------
#  run_tzar (
#      emulatingTzar               = TRUE,
#      main_function               = print_x,    #  note, no quotes on name
#      projectPath                 = ".",
#      tzarJarPath                 = "~/tzar/tzar.jar",
#      emulation_scratch_file_path = "~/tzar_em_scratch.yaml"
#      )
#  

## ----eval=FALSE----------------------------------------------------------
#  run_tzar (
#      emulatingTzar               = FALSE,
#      main_function               = print_x,    #  note, no quotes on name
#      projectPath                 = ".",
#      tzarJarPath                 = "~/tzar/tzar.jar",
#      emulation_scratch_file_path = "~/tzar_em_scratch.yaml"
#      )
#  

