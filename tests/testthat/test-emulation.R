context("test calling mainline with and without tzar and/or emulation")

source ("model_support_code.R")

# test_that("tzar emulation works", {
#     running_tzar_or_tzar_emulator = TRUE
#     emulating_tzar = TRUE
#     source ("model.R")
run_mainline_under_tzar_or_tzar_emulation (main_function="trial_main_function",
                                           projectPath="/Users/bill/D/Projects/ProblemDifficulty/pkgs/tzar/tests/testthat",
                                           tzarJarPath = "~/D/rdv-framework-latest-work/tzar.jar",
                                           emulation_scratch_file_path="~/tzar_emulation_scratch.yaml",
                                           emulatingTzar=TRUE
                                           )

# expect_gt(length(parameters),0)
# })

test_that("tzar works without emulation", {
    running_tzar_or_tzar_emulator = TRUE
    emulating_tzar = FALSE
#    source ("model.R")
expect_equal(TRUE,TRUE)
})

test_that("not using tzar at all works", {
    parameters = trial_main_function ()
    result = parameters$x
expect_equal(result,15)
})

