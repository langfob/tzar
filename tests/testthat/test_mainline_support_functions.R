#===============================================================================

                    #  test_mainline_support_functions.R

#===============================================================================

library (tzar)

context ("mainline_support_functions")

#===============================================================================

                #--------------------------------------------
                #  Test set_tzar_output_dir_in_scratch_file
                #--------------------------------------------

# emulation_scratch_file_name_with_path:
#     "~/tzar/tzar_emulation_scratch_area/tzar_em_scratch.yaml"


    #  Generate a directory name.
full_output_dir_with_slash            = paste0 (tempdir(), "/")
    #  Generate a file name that is guaranteed not to exist and then
    #  treat it like a directory name that you add a yaml file name to.
    #  This should give a non-existant file that is due to having a
    #  non-existant parent directory.
emulation_scratch_file_name_with_path = file.path (tempfile(),
                                                   "tzar_em_scratch.yaml")

test_that("set_tzar_output_dir_in_scratch_file: should fail if emulation scratch dir doesn't exist", {

    expect_failure (expect_error (set_tzar_output_dir_in_scratch_file (full_output_dir_with_slash,
                                                                       emulation_scratch_file_name_with_path)))
})

#===============================================================================

