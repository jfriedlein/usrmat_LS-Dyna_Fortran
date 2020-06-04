 subroutine utan44(cm,eps,sig,epsp,hsv,dt1,unsym,capa,etype,tt,
     1 temper,es,crv,nnpcrv,failel,cma,qmat)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c The computations of the tangent in Tensor notation also requires the split of
c the code into three parts.
      use Tensor
      include 'nlqparm'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*)
      integer nnpcrv(*)
      dimension es(6,*),qmat(3,3)
      logical failel,unsym
      character*5 etype
c Declarations
      type(Tensor2) :: d_eps,
     &                 stress, stress_vol, stress_dev,
     &                 stress_n, stress_vol_n,
     &                 stress_dev_t, n, Eye
      type(Tensor4)  :: tangent_C, IxI, I_dev, nxn

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
c We only need 'alpha', because we utilise the last stress,
c which already contains the history variable eps_p
      alpha = hsv(1)
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
c Deviatoric part of the old (*_n) and new deviatoric stress
      stress_dev_t = dev(stress_n) + 2.* shearMod_mu * dev(d_eps)
c Trial hardening stress R_t
      R_t = - hardMod_K * alpha
c Trial yield function Phi_t
      norm_stress_dev_t = norm(stress_dev_t)
      Phi_t = norm_stress_dev_t - sqrt(2./3.) * (yieldStress - R_t)
c Fourth order tensor
      IxI = Eye.dya.Eye
      I_dev = deviatoric_I4(Eye)
c Check the trial yield function
      if ( Phi_t < 0. ) then
          tangent_C = bulkMod_kappa * IxI
     &                + 2. * shearMod_mu * I_dev
      else
          n = stress_dev_t / norm_stress_dev_t
          d_lambda = Phi_t / ( 2.*shearMod_mu + 2./3. * hardMod_K )
          nxn = n.dya.n
          tangent_C = bulkMod_kappa * IxI
     &                + 2. * shearMod_mu * I_dev        
     &                - 4. * shearMod_mu * shearMod_mu
     &                  / ( 2.*shearMod_mu + 2./3. * hardMod_K )
     &                  * nxn
     &                - 4. * shearMod_mu * shearMod_mu
     &                  * d_lambda / norm_stress_dev_t 
     &                  * ( I_dev - nxn )
      endif
c 3.
c Transform tensor 'tangent_C' into the vectorial 'es'
      es(1:6,1:6) = asarray(voigt(tangent_C),6,6)
c
      return
      end
