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

The basic idea is that running tzar with an empty model.R produces all the same setup as running with a model.R that calls your applciation code. Consequently, you could run tzar with an empty model.R, go look for the most recent directory that tzar had created, then load the parameters.R file from that directory. At that point, you could run your own application code with the newly loaded parameters list and it would be nearly indistinguishable from running your code under tzar but you would have control of your code for debugging, etc.

The emulator just automatically manages the finding, loading, and running for you. It also manages a few other details of directory naming to indicate that a job ran and/or failed under emulation.To use the emulator, you just have to add a call to one of the emulator's functions in your model.R and another one in your application code.

<table style="width:83%;">
<colgroup>
<col width="83%" />
</colgroup>
<tbody>
<tr class="odd">
<td align="left">## SUMMARY: User steps required to enable tzar emulation</td>
</tr>
<tr class="even">
<td align="left">For each project that uses tzar emulation, you will need to do the steps below, once at the start of the project. There are a few of these steps but they are all pretty simple. - The reason for all this is that the whole process is a complete hack aimed at deceiving tzar into doing what we want. There has been talk of adding a &quot;dry run&quot; option to tzar to properly do what this hack does, but so far, it's just talk. In the meantime, this hack works.</td>
</tr>
<tr class="odd">
<td align="left">### Main steps - The main setup steps are: - Copy the <em>tzar_main</em> and <em>model</em> template files from the tzar package - Edit the <em>model</em> template if necessary - Edit the <em>tzar_main</em> template to match your project's directories, etc. - Make sure that the <strong>tzar package is loaded</strong>. - Make sure that you have a <strong>project.yaml file in the projectPath directory</strong>. - Run <em>runttip()</em> or <em>runtop()</em> each time you want to run tzar</td>
</tr>
<tr class="even">
<td align="left">### Details of each step</td>
</tr>
<tr class="odd">
<td align="left">- <strong>Copy the R template files</strong> from the package into the R source code area where you want to work. - In the code below, replace <em>YOUR_R_WORKING_AREA</em> with the location of the R code for your project. - Also, note that <em>get_tzar_R_templates()</em> has two arguments that you can modify if you need to, i.e., the target directory and a flag indicating whether model.R should be renamed to model.R.tzar or left as model.R. It never hurts to leave the</td>
</tr>
<tr class="even">
<td align="left"><code>r library (tzar) get_tzar_R_templates (&quot;YOUR_R_WORKING_AREA&quot;)</code></td>
</tr>
<tr class="odd">
<td align="left">- <strong>Edit model.R (or model.R.tzar if that's what was copied in)</strong> - <strong>Load your package</strong> in model.R if building a package - Uncomment &quot;#library (YOUR_PKG_NAME)&quot; - Replace YOUR_PKG_NAME with the name of your package - <strong>Set the following arguments</strong> of the function called <strong>in model.R</strong> if their default values are not appropriate for your project. In most cases, you shouldn't need to change their default values, particularly when you are first learning how to use tzar emulation. - main_function - projectPath - emulation_scratch_file_path</td>
</tr>
<tr class="even">
<td align="left">- <strong>Edit tzar_main.R</strong> - <strong>Replace the dummy code in the tzar_main() function</strong> with code appropriate to your project. - For the first test of using tzar emulation in your project, you probably want o just leave the dummy code there and make sure that the tzar call works and echoes the values from the project.yaml file. - Subsequently, tzar_main() will probably just contain a single call to the main function of your project with the parameters list as the only argument. - <strong>Edit arguments to calls in runtip() and/or runtop()</strong> to match your project. - runtip() and runtop() are convenience functions to allow you to quickly run tzar emulation at the command line without having to constantly retype long lists of arguments that are nearly always the same within a given project. - runt<strong>i</strong>p() is the function for working INSIDE building a package - runt<strong>o</strong>p() is the function for working OUTSIDE building a package, i.e., when just doing normal R development. - If you're building a package, then you won't even need the runtop() function in that project so you can even delete or ignore the runt<strong>o</strong>p() function. - Similarly, if you're not building a package and expect to never try to turn the code you're working on into a package, then you won't need runt<strong>i</strong>p() and can delete or ignore it. - The arguments for runtip() and runtop() are listed below and are the same for both functions. Bold arguments are the ones whose default values probably need to be replaced. The others can be modified but probably don't need to be: - emulating_tzar - main_function - <strong>project_path</strong> (e.g., &quot;~/mypkg/R&quot;) - emulation_scratch_file_path - <strong>tzar_jar_path</strong> (e.g., &quot;~/myTzarJarDir/tzar.jar&quot;) - copy_model_R_tzar_file - model_R_tzar_src_dir - model_R_tzar_disguised_filename - overwrite_existing_model_R_dest - If you're inexperienced with the emulator, it's best to leave this set to the default value of FALSE. Details about this flag are given in a separate note below. - required_model_R_filename_for_tzar</td>
</tr>
<tr class="odd">
<td align="left">- Make sure that the <strong>tzar package is loaded</strong> for your code, e.g., &quot;library(tzar)&quot;.</td>
</tr>
<tr class="even">
<td align="left">- Make sure that you have a <strong>project.yaml file in the projectPath directory</strong>. - This is a tzar requirement and not specific to tzar emulation. - <strong>When running emulation</strong> rather than normal tzar, make sure that the <strong>project.yaml file is only doing a single run</strong> rather than using tzar's ability to generate lots of runs (e.g., with a repetitions section). - If you were to generate multiple runs, there would be ambiguity because there would be more than one place to look for the parameters.R file that tzar generates.</td>
</tr>
</tbody>
</table>

#### Details about the *overwrite\_existing\_model\_R\_dest* in runtip() and runtop() calls

The *overwrite\_existing\_model\_R\_dest* flag in calls to runtip() and runtop() primarily there as a precaution to make sure that tzar emulation doesn't overwrite some existing version of model.R that you might have built in your R directory before starting to use tzar emulation. This is necessary because the emulator may be copying model.R.tzar into model.R and that could destroy your existing work if you've already built a model.R file. If you do have an existing model.R with contents you want included in tzar emulation, you'll have to merge the contents of your model.R and the template model.R to make sure that the emulator also has what it needs.

In general, the safest thing to do is to leave this flag as FALSE. However, in the early stages of developing a package your code may crash in ways that mean the emulator never gets to clean up after itself. In that case, its copied version of model.R from the previous run might still be left in the R directory when the copy from model.R.tzar tries to take place and the attempted overwrite will throw an error, even though it's not really an error in this case. It's just being extra cautious not to destroy work you may have done that it didn't know about.

If you do get this error about attempting to overwrite model.R and it's just the leftover model.R from a previous copy, you just have to delete the old model.R and this will let the emulator copy the model.R.tzar into model.R. If the *overwrite\_existing\_model\_R-dest* flag is set to TRUE instead of FALSE, then model.R will always be overwritten and you won't have to worry about any of this but it won't be defaulting to the safest behavior.

If you're working in a package and have only been working on model.R.tzar with the emulator copying it each time into model.R with no separate model.R of your own, then this is no problem. Setting *overwrite\_existing\_model\_R-dest* is fine in that case and will save you from having to delete the old model.R when your code has crashes severe enough to not allow the emulator to clean up after itself. This should be rare though.

------------------------------------------------------------------------
