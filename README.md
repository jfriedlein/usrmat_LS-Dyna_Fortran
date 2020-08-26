# usrmat_LS-Dyna_Fortran
Basics to implement user-defined materials (usrmat, umat, utan) in LS-Dyna with Fortran

## What is this all about?
LS-Dyna offers the interfaces and solvers to, among many other things, simulate mechanical systems and the related material behaviour. To reproduce realistic material responses, we need to utilise adequate material models. In case, standard available models cannot generate valid results, new user-defined material models can be implemented. The latter typically requires a stress-strain routine (umat, computes the stress for a given strain) and for implicit analyses also the stress-strain tangent (utan, how the strain changes the stress). This guide introduces the basics to implement user-defined material models in LS-Dyna using the standard Fortran interface.

## Software requirements and suggestions
To implement and apply UMAT-routines we recommend the following software and tools:
* An object version of the LS-Dyna version you wish to use. Everything outlined here refers to version R11.1. Their might be slight differences compared to older version, e.g. where to find the files. The object version is a compressed package (e.g. .zip) typically ending with `_lib.zip`. You can acquire this package from your LSTC support or, in case you possess the login credentials for the `ftp.lstc.com` download side section 'objects' (not 'user'), you can download the version from `https://ftp.lstc.com/objects/pc-dyna/` where all available version are listed (e.g. the here used 'ls-dyna_smp_d_R11_1_0_139588_winx64_ifort2017vs2017_lib.zip').

For the coding:
* You could use any text editor, however we recommend: Visual Studio 2017 (+ plugin [Word highlight with margin](https://marketplace.visualstudio.com/items?itemName=TrungKienPhan.WordHighlight-18439) to keep a clear head in the existing code)
* For the compilation of the Fortran `.f/.F` files you need a Fortran compiler, e.g. Intel Parallel Studio XE 2017

**@todo** Add an open source option (e.g. gfortran?, Notepad (Syntax: "Fortran with fixed format"))

## Test setup and compiler
To check whether everything works as desired, we simply compile the original LS-Dyna object files.
1. Unzip the object version (`*_lib.zip`) into your working directory `{working directory}`.
2. Start the Intel Fortran Compiler, e.g. via start menu -> `Intel Parallel Studio XE 2017` -> `Compiler 17.0 Update 6 for Intel 64 Visual Studio 2017 environment`. A command window should open up.
3. Change the directory of the command window to your working directory.
4. Run the command `nmake` (Starts the nmake.exe) to compile the Fortran files and create the `lsdyna.exe`
5. Wait a bit until all files are compiled. When you run nmake for the first time, it usually takes a bit longer, because every file is compiled. Later on, when you implement material models, you typically only change two files, hence nmake only recompiles those two, which is much faster.

> **note**
>
> However, this also means that changes in external files, e.g. libraries or outsourced codes, are not automatically detected and need to be compiled manually. The latter can be achieved by simply messing up the path in the include command, calling nmake, correcting the wrong path and calling nmake again. Now this include file is also recompiled.

**@todo** Find a better and automated way to avoid this silly approach.

6. After the compilation finished successfully, you should have a file `lsdyna.exe` in your working directory. This standalone executable contains LS-Dyna together with your material models.

@todo Test possible issues when passing the "standalone" exe around.

7. Start an LS-Dyna simulation, for instance from LS-Run, where you choose the created `lsdyna.exe` as the executable (e.g. instead of `[...]/ls-dyna_smp_d_R11.1_winx64_ifort160.exe` you choose `{working directory}/lsdyna.exe`).
8. The simulation should run just the same as using the LSTC version 'ls-dyna_smp_d_R11.1_winx64_ifort160.exe`.

@todo Check whether there is indeed a noticable performance loss by using the self-compiled exe.

9. Now we can start implementing our own material models into the files of the working directory and compile and run it using the above steps.
10. For some reason, when calling nmake, even when you changed the Fortran files, the message `'lsdyna.exe' is up-to-date` is shown and the files aren't compiled. As a simple workaround, just delete the lsdyna.exe everytime before you call nmake. This can be accomplished using the `start_nmake.bat` available in this repository. First, you should enter the paths to your working directory inside the batch file. Then just execute the .bat file and enter "del lsdyna.exe & nmake", which deletes the possibly already existing lsdyna.exe and execute nmake to create a new lsdyna.exe.

## Implementation
Before we take a closer look at the files that need to be extended by our material models and how we do this. A few notes on the used programming language FORTRAN.

### A few notes on FORTRAN
The programming language Fortran and especially the older version used in LS-Dyna has some "features" that might (most certainly) be unknown or unexpected to programmers used to "more modern" languages, such as C++, Matlab, Python, ... So to start with you best consider a few Fortran tutorials or books to get to know the specifics of the language.
If you are still reading and skipped the last recommendation, you might be as naive as me. So for the impatient, but experienced C++/Matlab/Python programmers a few remarks to ease the start. Some "features" originate from the time of punchcards (Lochkarten), so maybe it helps to keep this motivation in mind. These notes won't teach you how to code Fortran, but only try to give you a head start. The specific syntax still needs to be figured out by you.
* You cannot start programming directly at the left hand side, but must keep a tab space (6 blanks). The first few characters are required for special commands (line continuation, reference, ...) and identified by the compiler from their position. Similar to the holes punched at exactly the right place.
* The width of the code is limited to a certain amount of characters (width of a punchcard, can be extended by a compiler flag, marked in Visual Studio). So when your equations or lines of code get too long, you have to split them into more lines. This continuation of lines requires a special continuation character placed at the correct position (6. character) of the new lines as shown in the code snippet. Visual Studio highlights any character at this specific place, so make sure to place it correctly. You can use any character (e.g. '&' or number the new lines '1', '2', ...), it only matters that there is something (=a hole).

```fortran
c In a single line:
      i = 1 + 2 + 3 + 4
c Or equivalently split up
      i = 1 + 2
     &      + 3
     &  + 4  ! The horizontal position of the continued line does not matter.
```

* When you check out code in the LS-Dyna files, you might be tempted to conclude that you don't have to declare variables. This is correct, because they are declared implicitly. Nevertheless, for unexperienced Fortran programmers this is the worst you can do. Why? Because implicitly every variable that starts (!) with 'i', 'j', 'k', 'l', 'm' or 'n' is declared as an integer. Hence, when you naively use a variable named `lame_lambda` or `norm_l2` without explicitly declaring them, they are integers. So no matter what value you assign to them, they only store the integer part. So in contrast to Matlab, where every undeclared variable is a floating point number, in Fortran the first character of the name can decide that, which might lead to unexpected, incomprehensible and frustrating results. Hence, declare EVERY variable at the beginning.

todo Check use of `implicit none` and required additions to existing ls-dyna code.

* For C++ programmers the concept of integer divison might already be known. But for everyone else, who hasn't yet had the pleasure, a small note (or just consult the internet aka google it). When you e.g. divide 1 by 3 as
```fortran
real a
a = 1/3
```
and assign the value to the variable `a` (declared as 'real', which is similar to C++ 'double'). `a` does NOT contain the desired floating point number '0.3333...' but is '0'. Why? The numbers '1' and '3' are integers, hence the fraction also acquires the data type integer leaving you with the integer part of one third, which is zero. One correct way to avoid this is

`a = 1./3.` or `a = 1.0/3.0`

Here, the dots that follow the integer, mark them as floating point numbers and hence the variable `a` is '0.333...'. As a recommendation, always add the dot after coded numbers e.g. also in

`a = 2. * 5. * 0.5`

because you never know when you might change your mind and rewrite parts of equations using a divison.

Some more basics on Fortran (and Abaqus user interfaces) can be found in this [PDF](https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/Further%20documents/EN234FEA_tutorial_2017%20with%20Fortran%20phrase-book.pdf) by the Brown University.

## Our first user material
1. Open your working directory (the folder with the unpacked object version, e.g. `ls-dyna_smp_d_R11_1_0_139588_winx64_ifort2017vs2017_lib`) in Visual Studio.
2. Implement your material model code (computation of stress, history variables ...), in the file `dyn21umats.F`, for instance linear elasticity. We code our model in the first unused umat, here umat43. Note that we right away start with tensor based models.

[dyn21umats.F]:
```fortran
#define NOR4
#include 'ttb/ttb_library.F'
[...]
      subroutine umat43 (cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
c Use the tensor toolbox
c The position of this 'use' is crucial (first entry)
      use Tensor
c
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*),qmat(3,3)
c Input and output arguments (see the beginning of the 'dyn21umats.F' file)
c cm: contains the material parameters set in the material card (P1 ...)
c eps: increments (!) in the strain (difference between current strain and last converged load step),
c      stored as eps_11, eps_22, eps_33, eps_12, eps_23, eps_31
c sig: stresses from the last converged load step, stored in the same order as the strain 'eps'
c hsv: list of history variables (length: NHV, set in the material card)
      integer nnpcrv(*)
      logical failel,reject
      character*5 etype
      INTEGER8 idele
c Declarations
      real lame_lambda, shearMod_mu, bulkMod_kappa
      type(Tensor2) :: Eye, d_eps, stress, stress_n
c Material parameters
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = lame_lambda + 2./3. * shearMod_mu
c Second order identity tensor
      Eye = identity2(Eye)
c
c The function 'strain' transforms the strain 'eps' from the vector
c notation to the ttb tensor data type (correct assignment of vector to
c tensor index AND Voigt-factor 0.5).
      d_eps = strain(eps,3,3,6)
c
c The function 'symstore_2sa' stores the array 'sig' as the tensor 'stress_n',
      stress_n = symstore_2sa(sig)
c
c Our usual stress equation in tensor notation instead of Voigt, finally
c ... happily, thanks to Andreas Dutzler [https://github.com/adtzlr/ttb]!
c Be aware, that we get the strain increments, so we have to modify our
c usual equations a bit. (Gets irrelevant when you use finite strains and
c the deformation gradient.)
      stress = stress_n + lame_lambda * tr(d_eps) * Eye
     &                  + 2.*shearMod_mu*d_eps
c Transform the stress tensor back into a vector, equivalent to:
      sig(1:6) = asarray(voigt(stress),6)
c
c Everything is done with just a few lines of code ... perfect
c
      return
      end
```
(Note how compact, slim, insensitive to errors and beautiful tensors can be.)

3. Following the above test setup: Delete the possibly existing lsdyna.exe in the working directory. Start the Fortran compiler as described in the above steps 2 and 3.
4. Run nmake.
5. The code should successfully be compiled and no error message ought to be shown when the lsdyna.exe was created.
6. Run an LS-Dyna simulation using the freshly compiled lsdyna.exe and select your material model in the material card (outline below in the section `material card`). Also consider the section on the solver settings below.
7. Often you can test the material model even without having to implement the tangent (note: We haven't implemented the tangent yet.) by running your simulation as explicit, which does not at all require a tangent (motto of explicit computation: 'Don't look, just go.'). If the material response is as expected, you can again switch to implicit.
8. Next we implement our tangent. This must be done in the file `dyn21utan.F` (user tangent) and in the subroutine with the same ID (here 43). For linear elasticity the tangent is constant and independent of the input arguments. For more complicated models the umat-utan function split can cause some problems that are discussed later on. Here we just implement the constant tangent, which in Voigt notation fills a 6x6 matrix called `es`:
[dyn21utan.F]:
```fortran
      subroutine utan43(cm,eps,sig,epsp,hsv,dt1,unsym,capa,etype,tt,
     1 temper,es,crv,nnpcrv,failel,cma,qmat)
c
c******************************************************************
c The computations of the tangent in Tensor notation also requires the split of
c the code into three parts.
c 1. Transform the arrays to tensors.
c 2. Compute the quantities with tensors.
c 3. Transform the tensorial results back to arrays.
      use Tensor
      include 'nlqparm'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*)
c cm, eps: as  above
c sig: output stress from the material model umat (not from the last converged step)
c hsv: output history from the umat (not from the last converged step)
c for details: see section below
      integer nnpcrv(*)
      dimension es(6,*),qmat(3,3)
      logical failel,unsym
      character*5 etype
c Declarations
      type(Tensor2) :: Eye
      type(Tensor4)  :: tangent_C, IxI, I_dev
c
      real lame_lambda, shearMod_mu, bulkMod_kappa
      real con1, con2
c Material parameters
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = cm(1) + 2./3. * shearMod_mu
c Second order identity tensor
      Eye = identity2(Eye)
c Fourth order tensors
      IxI = Eye.dya.Eye
      I_dev = (Eye.cdya.Eye) - 1./3.*(Eye.dya.Eye)
c Compute the tangent modulus as a fourth order tensor
      tangent_C = bulkMod_kappa * IxI
     &            + 2. * shearMod_mu * I_dev
c Transform tensor 'tangent_C' into the matrix 'es'
      es(1:6,1:6) = asarray(voigt(tangent_C),6,6)
c
      return
      end
```

## Some notes on proper simulation and solver settings for testing umats
The setup of an LS-Dyna keyword file for the comprehensive testing of umats feels like another "airport Berlin", and of course, this section is still "work in progress".

To check the correctness of the umat (first ignoring the utan), you can use an explicit simulation as stated above. To check your implemented tangent, you must use an implicit computation and best get to the bottom of your resulting convergence rate (requires various solver settings, a snippet given in the following figure). xxx outlines some very good aspects in his UMAT workshop in the section on ["UMAT verification"](https://sites.google.com/site/aenader/umat-workshop/umat-verification).

<img src="https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/images/CONTROL_IMPLICIT_SOLUTION%20-%20Einstellungen.png" width="500">

More details on the setup of these simulations will be given here in the future (small appetiser: [Numerical example for LS-Dyna"](https://github.com/jfriedlein/Numerical_examples_in_LS-Dyna)).

@todo maybe add one-element test, explain the settings and finish this section before the airport


## Material models using tensors
In case you like the above equations in Tensor notation and you are not familiar with the in LS-Dyna usual Voigt notation. There is a superb Tensor Toolbox for Fortran (ttb, https://github.com/adtzlr/ttb) with a comprehensive documentation (https://adtzlr.github.io/ttb/) that enables you to use tensors and tensor operations. Regarding the setup of the toolbox, I hand you over to the capable hands of Andreas outlining the steps here https://adtzlr.github.io/ttb/installation.html.
You can find a more advanced example in the ttb documentation specific for LS-Dyna (currently e.g. at: ["LS-Dyna Tensor Neo-Hooke"](https://github.com/jfriedlein/ttb/blob/example_LSDYNA/docs/example_neohooke-LSDYNA.md)).

@todo Add the link when the example is added. Refer to some more example files (elasto-plasticity, ...)

## Outline of the interface for umat and utan
The following figure shows the typically relevant input/output arguments.

<img src="https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/images/UMAT_UTAN%20-%20arguments.png" width="500">

@todo Check if the tangent es can also be used as an input in utan (e.g. computing an incremental tangent, sounds like bs, right?)

The UMAT-subroutine gets the incremental strain `eps` in Voigt (!) notation. Hence, the shear components contain twice the xy, yz and zx components (all automatically handled by the ttb tensor toolbox).

<a href="https://www.codecogs.com/eqnedit.php?latex=\Delta&space;\boldsymbol{\varepsilon}_\ell&space;=&space;\boldsymbol{\varepsilon}_\ell&space;-&space;\boldsymbol{\varepsilon}_n" target="_blank"><img src="https://latex.codecogs.com/gif.latex?\Delta&space;\boldsymbol{\varepsilon}_\ell&space;=&space;\boldsymbol{\varepsilon}_\ell&space;-&space;\boldsymbol{\varepsilon}_n" title="\Delta \boldsymbol{\varepsilon}_\ell = \boldsymbol{\varepsilon}_\ell - \boldsymbol{\varepsilon}_n" /></a>

Here, the index `l` denotes the values from the current iteration and `n` the values from the last converged load step. Some background information and context regarding the herein used notation can be found in the following scheme.

<img src="https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/images/general%20solution%20method.png" width="500">

So let's move on. Secondly, we receive the stresses `sig` that contain the Cauchy stress from the last converged load step `n`. The history variables, such as the plastic strain or the hardening for plasticity, are summarised in the list `hsv`. Material parameters, like the Young's modulus or Poisson's ratio, set in the material card, are stored in the list `cm`. For the above example the first and second Lame parameters are stored in P1 and P2, respectively. Lastly, we can also find the deformation gradient `F` after setting the option `IHYPER` in the history.

Now the material model must compute the new Cauchy stress with index `tmp` and update the history variables.

In the UTAN-routine we receive the temporary Cauchy stress and history from UMAT. With this we have to compute the tangent. In the world of tensors the latter needs to be the fourth order Eulerian tangent moduli `E`.

## Some considerations on the split of material model (umat) and tangent (utan)
Unfornuately, because LS-Dyna was born "explicitly" (but contains full implicit capabilites, see  ["LS-Dyna solvers"](https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/issues/1#issuecomment-642446156)) the material model routine `umat` (stress and history update) and the tangent `utan` (for implicit only) are located in separate subroutines and files. Hence, at first glance it is not straightforward to generate a complicated consistent tangent lacking access and knowledge of quantities computed in the umat routine. For elasto-plasticity as an example, inside the umat routine you determine whether the current step is elastic or plastic and compute the stress accordingly. Obviously, the tangent in utan needs to be set up such that it fits to the chosen elastic or plastic response. But the deciding criterion (here the yield criterion) or quantity (plastic multiplier) is not available in utan (and might be cumbersome to salvage).

So, what options do we have to work around this issue/complication? I came up with the following variants (if you found alternatives, please let me know):
* Compute a constant tangent in utan: For completeness this option is also added here. Of course, if your tangent is constant and independent of the strains/history/... (as for the above small strain elasticity), you can simply implement it as it is.
* Reconstruct data from inputs: Sometimes it is possible to simply reconstruct the data needed for the tangent from the standard input arguments (strain increment, stress, deformation gradient). This was done for a Neo-Hookean material model (currently available here: ["LS-Dyna Tensor Neo-Hooke"](https://github.com/jfriedlein/ttb/blob/example_LSDYNA/docs/example_neohooke-LSDYNA.md)), where the tangent depends only on the deformation gradient, which is an input argument in the list `hsv` also for the tangent (see section `interfaces`).
* Save minimum set of auxiliary quantities in hsv: Another option is to store only the variables that you need for the reconstruction of the tangent in the history `hsv`. For instance, for the above briefly stated elasto-plastic model, the plastic multiplier would be sufficient to generate the tangent (decide elastic/plastic step and compute consistent tangent). However, be aware that you might have to apply some tricks to get all quantities you usually need for the tangent. For example, for the consistent elastoplastic tangent we need the elastic trial stress, which is computed in the umat routine based on the input stress `sig` (stress from the last converged load step `n`). However, in utan the input argument `sig` contains the updated stress (index `tmp` in section `interfaces`). So, you would have to salvage the trial stress from the new stress (opposite sign). An example can be found here [utan for elasto-plasticity using the plastic multiplier](https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/Elastoplasticity%20-%20linear%20-%20Tensor/UTAN%20-%20Elastoplasticity%20-%20linear%20-%20Tensor.f).
* Store the entire 6x6 tangent matrix `es` in hsv:  This option is sometimes my last resort, especially when the computation of the tangent is absurdly complicated, expensive and practically impossibly to reconstruct outside of the umat. Here, we compute the tangent inside the umat routine (as one might be used to) and save its 6x6 matrix representation as 36 entries in the history list `hsv`. When the utan routine is called by LS-Dyna, we simply retrieve the 36 entries and return them properly arranged in the `es` tangent matrix. Yes, this approach is a bit heavy on memory, but still works quite well. To avoid mixing up the history variables in the hsv list, in particular if you save several actual history variables in hsv besides the tangent and the derformation gradient, you can use this [hsv-manager](https://github.com/jfriedlein/history_hsv-manager_LS-Dyna). This allows you to manage the entire history from a single central position and just call for what you want without caring about its storage location. For standard materials the tangent `es` is symmetric, hence the unique 21 entries of the upper triangular part would be sufficient. If you see fit to implement this optimised version, you are welcome to add this to the hsv-manager. Howerver, for the more general cases of non-symmetric tangents (option `unsym` in utan) we still require all 36 entries.

@todo add an example of the "es in hsv" approch and the boilerplate code for utan

## Example material card
All of the above was done without even considering LS-Dyna or its pre-/postprocessing (here done via LS-PrePost). In order to apply the material model to a simulation, you need to setup a parameter for the keyword file. First, create a parameter `*MAT_USER_DEFINED_MATERIAL_MODELS` to refer to your user material. The material id in the option "MT" must equal the id in umatXX and utanXX. The value of "NHV" sets the number of used history variables, here (for elasticity) none are used in the material model. The option "IHYPER=1" stores the deformation gradient in the history "hsv" on top of the defined "NHV". The parameters "P1" and "P2", for instance, contain the Young's modulus in "cm(1)" and the Poisson ratio in "cm(2)" in the picture, respectively. For our above elasticity material, we would type the values of the first and second Lame parameters into P1 and P2, respectively.

<img src="https://github.com/jfriedlein/usrmat_LS-Dyna_Fortran/blob/master/images/LSDYNA%20-%20material-card%20example.png" width="500">

## References/Further reading
Now you are well advised to check out some other resources on this topic, such as:
* LS-Dyna user manual Vol. I, Appendix A "User Defined Materials" [LSTC Download Manuals](http://lstc.com/download/manuals)
* ["How To - user defined material models with LS-Dyna on Windows"](https://www.researchgate.net/publication/327623424_How_To_-_user_defined_material_models_with_LS-Dyna_on_Windows) by Leon Kellner
* ["An Overview of  User Defined Interfaces in LS-DYNA"](https://www.dynamore.de/de/download/papers/forum10/papers/L-I-01.pdf) by Tobias Erhart
* ["UMAT Workshop by Nader Abedrabbo"](https://sites.google.com/site/aenader/umat-workshop)

## todo
* Check dyn21 etc. files in older versions
* Check LS-Dyna 2D (plane strain) format of eps and sig (axial-symmetry is 6 and 6 as in 3D)

