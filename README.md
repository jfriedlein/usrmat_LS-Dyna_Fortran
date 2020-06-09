# usrmat_LS-Dyna_Fortran
Basics to implement user-defined materials (usrmat, umat) in LS-Dyna with Fortran

## References
* LS-Dyna user manual Vol. I, Appendix A "..."
* Kellner HowTo

## Requirements and suggestions
* An object version of the LS-Dyna version you wish to use. Everything outlined here refers to version R11.1. Their might be slight differences compared to older version, e.g. where to find the files. The object version is a compressed package (e.g. .zip) typically ending with `_lib.zip`. You can acquire this package from your LSTC support or, in case you possess the login credentials for the `ftp.lstc.com` download side section 'objects' (not 'user'), you can download the version from `https://ftp.lstc.com/objects/pc-dyna/` where all available version are listed (e.g. the here used 'ls-dyna_smp_d_R11_1_0_139588_winx64_ifort2017vs2017_lib.zip').
* For the coding you could use any text editor, however we recommend the following setup:
  * Visual Studio 2017
  * Intel Parallel Studio XE 2017 (Fortran compiler)

@todo Add an open source option (e.g. gfortran?)

## Test setup and compiler
To check whether everything works as desired, we simply compile the original LS-Dyna object files.
1. Unzip the object version (`*_lib.zip`) into your working directory.
2. Start the Intel Fortran Compiler, e.g. via start menu -> `Intel Parallel Studio XE 2017` -> `Compiler 17.0 Update 6 for Intel 64 Visual Studio 2017 environment`. A command window should open up.
3. Change the directory of the command window to your working directory.
4. Run the command `nmake` (Starts the nmake.exe) to compile the Fortran files and create the `lsdyna.exe`
5. Wait a bit until all files are compiled. When you run nmake for the first time, it usually takes a bit longer, because every file is compiled. Later on, when you implement material models, you typically only change two files, hence nmake only recompiles those two, which is much faster.
```
**note**
However, this also means that changes in external files, e.g. libraries or outsourced code, are not automatically detected and need to be compiled manually. The latter can achieved by simply messing the path in the include command up, call nmake, correct the wrong path and call nmake again. Now this include file is recompiled.
```

@todo Find a better and automated way to avoid this silly approach.

6. After the compilation finished successfully, you should have a file `lsdyna.exe` in your working directory. This standalone executable contains LS-Dyna together with your material models.
7. Start a LS-Dyna simulation, for instance from LS-Run, where you choose the created `lsdyna.exe` as the executable (e.g. instead of `[...]/ls-dyna_smp_d_R11.1_winx64_ifort160.exe`).
8. The simulation should run just the same as using the LSTC version 'ls-dyna_smp_d_R11.1_winx64_ifort160.exe`.

@todo Check whether there is indeed a noticable performance loss.

9. Now we can start implementing our own material models into the files of the working directory and compile and run it using the above steps.
10. For some reason, when calling nmake, even when you changed the Fortran files, the message `'lsdyna.exe' is up-to-date` is shown. As a simple workaround, just everytime delete the lsdyna.exe before you call nmake.

@todo Find a workaround or add a simple batch script, deleting lsdyna.exe and calling nmake.

## Implementation
Before we take a closer look at the files that need to be extended by our material models and how we do this. A few notes on the used programming language FORTRAN.

### A few notes on FORTRAN
The programming language Fortran and especially the older version used in LS-Dyna has some "features" that might (most certainly) be unknown or unexpected to programmers used to "more modern" languages, such as C++, Matlab, Python, ... So to start with you best consider a few Fortran tutorials or books to get to know the specifics of the language.
If you are still reading and skipped the last recommendation, you might be as naive as me. So for the impatient, but experienced C++/Matlab/Python programmers a few remarks to ease the start. Some "features" originate from the time of punchcards (Lochkarten), so maybe it helps to keep this motivation in mind. These notes won't teach you how to code Fortran, but only try to give you a head start. The specific syntax still needs to be figured out by you.
* You cannot start programming directly at the left hand side, but must keep a tab space (6 blanks???). The first few characters are required for special commands and identified by the compiler from their position. Similar to the holes punched at exactly the right place.
* The width of the code is limited to 66??? characters (width of a punchcard, can be extended by a compiler flag). So when your equations or lines of code get too long, you have to split them into more lines. This continuation of lines requires a special continuation character placed at the correct position (6. character) of the new lines as shown in the code snippet. Visual studio highlights any character at this specific place, so make sure to place it correctly. You can use any character (e.g. '&' or number the new lines '1', '2', ...), it only matters that there is something (=a hole).

```fortran
c In a single line:
        i = 1 + 2
c Or equivalently split up (the position of the continued line does not matter)
        i = 1
     &      + 2 
```

* When you check out code in the LS-Dyna files, you might be tempted to conclude that you don't have to declare variables. This is correct, because they are declared implicitly. Nevertheless, for unexperienced Fortran programmers this is the worst you can do. Why? Because implicitly every variable that starts (!) with 'i', 'j', 'k', 'l', 'm' or 'n' is declared as an integer. Hence, when you naively use a variable named `lame_lambda` or `norm_l2` without explicitly declaring them, they are integers. So no matter what value you assign to them, they only store the integer part. So in contrast to Matlab, where every undeclared variable is a floating point number, in Fortran the first character of the name can decide that, which might lead to unexpected, incomprehensible and frustrating results. Hence, declare every variable at the beginning.

todo Check use of `implicit none` and required additions to existing ls-dyna code

* For C++ programmers the concept of integer divison might already be known. But for everyone else, who hasn't yet had the pleasure, a small note (or just consult the internet aka google it). When you e.g. divide 1 by 3 as
```fortran
real a
a = 1/3`
```

and assign the value to the variable `a` (declared as 'real', which is similar to C++ 'double'). 'a' does NOT contain the floating point number '0.3333...' but is '0'. Why? The numbers '1' and '3' are integers, hence the fraction also acquires the data type integer leaving you with the integer part of one third, which is zero. One correct way to avoid this is

`a = 1./3.` or `a = 1.0/3.0`

Here the dots that follow the integer, mark them as floating point numbers and hence the variable `a` is '0.333...'. As a recommendation, always add the dot after coded numbers e.g. also in

'a = 2. * 5. * 0.5'

because you never know when you might change your mind and rewrite parts of equations using a divison.

## Our first user material
1. Open your working directory (the unpacked object version, e.g. `ls-dyna_smp_d_R11_1_0_139588_winx64_ifort2017vs2017_lib`) in Visual Studio.
2. Implement your material model code (computation of stress, history variables ...), in the file `dyn21umats.F`, for instance linear elasticity:
```
umat43
cm ! consult the material card
```
declare variables
write code
return sig
3. Following the above test setup: Delete the possibly existing lsdyna.exe in the working directory. Start the Fortran compiler as described in the above steps 2 and 3.
4. Run nmake.
5. The code should successfuly be compiled and no error message should be shown when the lsdyna.exe was created.
6. Run an LS-Dyna simulation using the freshly compiled lsdyna.exe.
```
Some notes on proper simulation settings for testing umats
* Full NR, ...
```
7. Often you can test the material model even without having to implement the tangent by running your simulation as explicit, which does not at all require a tangent (motto of explicit computation: 'Don't look, just go.'). If the material response is as expected, you can again switch to implicit.
8. Next we implement our tangent. This must be done in the file `dyn21utan.F` (user tangent) and in subroutine with the same ID (here 43). For linear elasticity the tangent is constant and independent of the input arguments. For more complicated models the umat-utan function split can cause some problems that are discussed later on. Here we just implement the constant tangent, which in Voigt notation fills a 6x6 matrix called `es`:
```
utan43
```

## Material models using tensors
In case the above equations in Voigt notation are not common to you, because you're used to tensor-based models and tensor notation. Don't give up hope! There is a superb Tensor Toolbox for Fortran (ttb, https://github.com/adtzlr/ttb) with a comprehensive documentation (https://adtzlr.github.io/ttb/) that enables you to use tensors and tensor operations. Regarding the installation of the toolbox I hand you over to the capable hands of Andreas outlining the steps here https://adtzlr.github.io/ttb/installation.html.

Here I want to continue with a detailed description on the usage of the toolbox in LS-Dyna.

[dyn21umats.F]:
```fortran
...
#define NOR4
#include ...
[...]
umat43
```
[dyn21utan.F]:
```fortran
utan43
```
(How compact, slim, insensitive to errors and beautiful tensors can be.)

## Some considerations on the split of material model (umat) and tangent (utan)
* Compute constant tangent in utan
* reconstruct data from inputs
* store `es` in hsv

@todo Add a figure that shows which values are input in usrmat and utan (e.g. new eps, old sig, tmp_sig, hsv ...)


## todo
* Check dyn21 etc. files in older versions
* Check LS-Dyna 2D (plane strain) format of eps and sig

