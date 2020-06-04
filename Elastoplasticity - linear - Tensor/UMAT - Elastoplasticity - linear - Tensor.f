subroutine umat44 (cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c Thanks to the tensor module we can utilise our tensorial equations, but LS-Dyna
c still only provides (input) and desires (output) vectorial quantities.
c So our subroutines are split into three parts:
c 1. Transform vectorial quantities into Tensors
c 2. Computations with tensors
c 3. Transform the computed tensors into output vectors
      use Tensor
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*),qmat(3,3)
      integer nnpcrv(*)
      character*5 etype
      logical failel,reject
      INTEGER8 idele
c
c Declarations:
c Arrays must be declared as such
c But nevertheless declare every single variable,
c else you will get utter bs at some point.
c @todo A definition later on giving the variable its value, seems
c to be insufficient?
c https://web.stanford.edu/class/me200c/tutorial_77/05_variables.html:
c Data type 'real' is similar to C++ 'double' for floating point numbers
c 'integer' -> C++ 'int'
c 'double precision' -> C++ 'double' in double precision
c 'logical' -> C++ 'bool'
      type(Tensor2) :: d_eps,
     &                 stress, stress_vol, stress_dev,
     &                 eps_p,
     &                 stress_n, stress_vol_n,
     &                 stress_dev_t, n, Eye
      real Phi_t
      real lame_lambda, shearMod_mu, bulkMod_kappa
      real hardMod_K, yieldStress
      real alpha, R_t, d_lambda, norm_stress_dev_t
c Material parameters
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = cm(1) + 2./3. * shearMod_mu
      hardMod_K = cm(3)
      yieldStress = cm(4)
c 1.
c History variables
      alpha = hsv(1)
      eps_p = symstore_2sa(hsv(2:7))
c Store the vectorial strain increments as a tensor.
c This also takes care of the doubled shear strains
      d_eps = str2ten_2s(eps,3,3,6)
c 2.
c After all these transformation steps we are finally in the world of tensor
c and can use our standard algorithms
c Second order identity tensor
      Eye = identity2(Eye)
c Store the input stress 'sig' as Tensor 'stress_n'
      stress_n = symstore_2sa(sig)
c Volumetric part of the old and new stress
      stress_vol = vol(stress_n) + bulkMod_kappa * tr(d_eps) * Eye
c Deviatoric part of the old (*_n) and new deviatoric stress
      stress_dev_t = dev(stress_n) + 2.* shearMod_mu * dev(d_eps)
c Trial hardening stress R_t
      R_t = - hardMod_K * alpha
c Trial yield function Phi_t
      norm_stress_dev_t = norm(stress_dev_t)
      Phi_t = norm_stress_dev_t - sqrt(2./3.) * (yieldStress - R_t)
c Check the trial yield function
      if ( Phi_t < 0. ) then
          stress = stress_vol + stress_dev_t
          ! Keep the history unchanged
      else
          n = stress_dev_t / norm_stress_dev_t
          d_lambda = Phi_t / ( 2.*shearMod_mu + 2./3. * hardMod_K )
          hsv(1) = alpha + d_lambda * sqrt(2./3.)
          hsv(2:7) = asarray(voigt(eps_p + d_lambda * n),6)
          stress = stress_vol + stress_dev_t
     &             - 2. * shearMod_mu * d_lambda * n
      endif
c 3.
c Save the stress into the return argument
c @todo Use a nicer function to transform a tensor to the vector 'sig'
      sig(1:6) = asarray(voigt(stress),6)
c
      return
      end
