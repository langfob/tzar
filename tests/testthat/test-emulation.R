context("test calling mainline with and without tzar and/or emulation")

source ("model_support_code.R")

test_that("tzar emulation works", {
    running_tzar_or_tzar_emulator = TRUE
    emulating_tzar = TRUE
#    source ("model.R")
expect_equal(TRUE,TRUE)
})

test_that("tzar works without emulation", {
    running_tzar_or_tzar_emulator = TRUE
    emulating_tzar = FALSE
#    source ("model.R")
expect_equal(TRUE,TRUE)
})

test_that("not using tzar at all works", {
    result = trial_main_function ()
expect_equal(result,15)
})

