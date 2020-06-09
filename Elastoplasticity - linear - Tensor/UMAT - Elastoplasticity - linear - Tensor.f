      subroutine umat44 (cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
c Thanks to the tensor module we can utilise our tensorial equations, but LS-Dyna
c still only provides (input) and desires (output) vectorial (Voigt-type) quantities.
c So our subroutines are split into three parts:
c 1. Transform Voigt-vectorial quantities into Tensors
c 2. Computations with tensors
c 3. Transform the computed tensors into output vectors
c Use the tensor toolbox
      use Tensor
c Standard LS-Dyna declarations (added some explicit data types)
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      real(kind=8), dimension(*) :: cm, eps, sig, hsv
      dimension crv(lq1,2,*),cma(*),qmat(3,3)
      integer nnpcrv(*)
      character*5 etype
      logical failel,reject
      INTEGER8 idele
c Tensor declarations:
      type(Tensor2) :: d_eps,  ! tensorial strain increments
     &                 stress, ! resulting stress measure (small strain theory)
     &                 stress_vol, stress_dev, ! volumetric and deviatoric stress part
     &                 eps_p,  ! plastic strain tensor
     &                 stress_n, stress_vol_n, ! stress from the last converged load step
     &                 stress_dev_t, ! trial deviatoric stress tensor
     &                 n,      ! plastic evolution direction
     &                 Eye     ! second order unit tensor
c Scalars
      real(kind=8) alpha,     ! internal hardening variable for isotropic hardening
     &             Phi_t,     ! Trial yield function
     &             R_t,       ! Trial hardening stress
     &             d_lambda,  ! incremental Lagrange multiplier
     &             norm_stress_dev_t ! norm of the trial deviatoric stress
c Declare and extract the material parameters
      real(kind=8) lame_lambda, shearMod_mu, bulkMod_kappa
      real(kind=8) hardMod_K, yieldStress
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = cm(1) + 2./3. * shearMod_mu
      hardMod_K = cm(3)
      yieldStress = cm(4)
c 1. Transform Voigt-vectorial quantities into Tensors
c History variables
      alpha = hsv(1) ! Internal variable is stored as the first entry
      eps_p = symstore_2sa(hsv(2:7)) ! plastic strain tensor is stored as list entry 2 to 7
c Store the vectorial strain increments as a tensor.
c This also takes care of the doubled shear strains.
      d_eps = strain(eps,3,3,6)
c Store the input stress 'sig' (contains the stress components from the last converged load step)
c as Tensor 'stress_n'
      stress_n = symstore_2sa(sig)
c 2. Computations with tensors
c After all these transformation steps we are finally in the world of tensors
c and can use our standard tensorial algorithms.
c Second order identity tensor
      Eye = identity2(Eye)
c Volumetric part of the old (*_n) and new stress
      stress_vol = ( 1./3. * tr(stress_n) + bulkMod_kappa * tr(d_eps) )
     &             * Eye
c Deviatoric part of the old (*_n) and new deviatoric stress
      stress_dev_t = dev(stress_n) + 2.* shearMod_mu * dev(d_eps)
c Trial hardening stress R_t
      R_t = - hardMod_K * alpha
c Trial yield function Phi_t
      norm_stress_dev_t = norm(stress_dev_t)
      Phi_t = norm_stress_dev_t - sqrt(2./3.) * (yieldStress - R_t)
c Check the trial yield function
      if ( Phi_t < 0. ) then
          ! Purely elastic step. Trial elastic predicitor step was appropriate
          ! so we can use the computed trial values.
          stress = stress_vol + stress_dev_t
          ! Keep the history unchanged
          ! Store the Lagrange multiplier for the utan subroutine
          hsv(8) = 0.
      else
          ! The yield function is negative, so we are in the non-admissible stress space.
          ! Hence, we use a radial return to come back to the yield surface. For the simple
          ! linear isotropic hardening, the relations are linear, so we don't require additional iterations.
c Evolution direction for the radial return
          n = stress_dev_t / norm_stress_dev_t
c Lagrange multiplier increment
          d_lambda = Phi_t / ( 2.*shearMod_mu + 2./3. * hardMod_K )
c Compute the stress using the plastic correction          
          stress = stress_vol + stress_dev_t
     &             - 2. * shearMod_mu * d_lambda * n      
c Update the history variables according to the evolution equations.
          hsv(1) = alpha + d_lambda * sqrt(2./3.)
          hsv(2:7) = asarray(voigt(eps_p + d_lambda * n),6)
          hsv(8) = d_lambda
      endif
c 3. Transform the computed tensors into output vectors
c Save the stress into the return argument 'sig'
      sig(1:6) = asarray(voigt(stress),6)
c
      return
      end
