#===============================================================================

#                           once_per_project.R

#===============================================================================

#' get template files for running tzar emulation
#'
#' This is a convenience function to run one time at the start of using tzar
#' emulation on a project.  Tzar requires a model.R file and tzar emulation
#' requires a file like tzar_main.R to call the user's application code as
#' well as a tzar_emulation.yaml file to specify emulation control parameters.
#' The tzar package provides a template for each of these files to make it as
#' simple as possible to do emulation.
#'
#' One catch in using the templates is that when development is being done as
#' part of building a package, the model.R file can't be called model.R. This is
#' because when R builds a package, it runs all ".R" files in the package's R
#' directory since they are assumed to do nothing but define functions.  Since
#' model.R runs experiments instead of defining functions, this will not work
#' inside a package build.  Tzar emulation gets around this by disguising the
#' name of model.R as model.R.tzar and then renaming it to model.R just before a
#' tzar run, then renaming it back to model.R.tzar after the emulation run.
#'
#' Note that if tzar emulation is to be done in a normal R programming situation
#' that doesn't involve a package build, then it's fine for model.R to keep its
#' name as is.
#'
#' Note also that, for safety, the copying operation will not overwrite any
#' existing file with the same name in the target directory.
#'
#' @param target_dir Path of directory where template files are to be deposited
#' @param running_inside_a_package Boolean flag set to TRUE if emulation will be
#'   done inside a package build and FALSE otherwise
#'
#' @return NULL
#' @export
#'
#' @examples \dontrun{
#'     #  Copy template files to current directory for use in
#'     #  developing a package.
#' get_tzar_pkg_templates ()
#'
#'     #  Copy template files to R subdirectory for use in normal R development
#'     #  outsides of a package.
#' get_tzar_pkg_templates ("./R", FALSE)
#' }
get_tzar_pkg_templates <- function (target_dir = ".",
                                    running_inside_a_package = TRUE)
    {
    target_dir = normalizePath (target_dir)

    file.copy (system.file ("templates/tzar_main.R", package="tzar"),
               target_dir,
               overwrite=FALSE)

    file.copy (system.file ("templates/tzar_emulation.yaml", package="tzar"),
               target_dir,
               overwrite=FALSE)

        #-----------------------------------------------------------------------
        #  If model.R is to be part of a package, then it can't be named
        #  model.R since the package builder will run it at build time as
        #  part of running all ".R" files in the package's R directory.
        #  So, in that case, the name model.R needs to be disguised to
        #  not end in ".R".  We will arbitrarily choose to rename it with
        #  ".tzar" tacked onto the end.
        #  If not part of a package, then it's fine to have it called model.R.
        #-----------------------------------------------------------------------

    if (running_inside_a_package)
        {
        file.copy (system.file ("templates/model.R", package="tzar"),
                   file.path (target_dir, "model.R.tzar"),
                   overwrite=FALSE)
        } else
        {
        file.copy (system.file ("templates/model.R", package="tzar"),
                   target_dir,
                   overwrite=FALSE)
        }

    return (NULL)
    }

#===============================================================================
