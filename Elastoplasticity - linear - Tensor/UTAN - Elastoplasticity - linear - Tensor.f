      subroutine utan44(cm,eps,sig,epsp,hsv,dt1,unsym,capa,etype,tt,
     1 temper,es,crv,nnpcrv,failel,cma,qmat)
c
c The computations of the tangent in Tensor notation needs to know whether
c the current quadrature has yielded or not. We utilise a trick by storing 
c the Lagrange multiplier 'd_lambda' as an additonal history variable to determine
c this. 
c Alternatives:
c * reevaluate the yield function and decide based
c     on this whether we need an elastic or elastoplastic tangent.
c     (be aware that utan is called with the updated stresses
c * compute the tangent together with the stresses in the subroutine umat44
c     and store the 6x6 matrix 'es' in the history 'hsv'
      use Tensor
c Standard LS-Dyna declarations (added explicit data types)
      include 'nlqparm'
      real(kind=8), dimension(*)   :: cm, eps, sig, hsv
      real(kind=8), dimension(6,*) :: es
      dimension crv(lq1,2,*),cma(*),qmat(3,3)
      integer nnpcrv(*)
      character*5 etype
      logical failel,reject
c Declarations
      type(Tensor2) :: d_eps,
     &                 stress, stress_dev,
     &                 stress_dev_t, n, Eye
      type(Tensor4) :: IxI,       ! dyadic product of second order unit tensor
     &                 I_dev,     ! deviatoric fourth order unit tensor
     &                 nxn,       ! dyadic product of the evolution directions 'n'
     &                 tangent_C  ! tangent modulus
c Scalars
      real(kind=8) d_lambda,  ! incremental Lagrange multiplier
     &             norm_stress_dev,  ! norm of the updated deviatoric stress
     &             norm_stress_dev_t ! norm of the trial deviatoric stress
c Declare and extract the material parameters
      real(kind=8) lame_lambda, shearMod_mu, bulkMod_kappa
      real(kind=8) hardMod_K, yieldStress
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = cm(1) + 2./3. * shearMod_mu
      hardMod_K = cm(3)
      yieldStress = cm(4)
c 1. 
c Recover the Lagrange multiplier    
      d_lambda = hsv(8)
c Store the vectorial strain increments as a tensor.
      d_eps = strain(eps,3,3,6)
c Store the input stress 'sig' as Tensor 'stress_n'
      stress = symstore_2sa(sig)
c 2.
c After these transformation steps we are finally in the world of tensors
c and can use our standard algorithms
c Second order identity tensor
      Eye = identity2(Eye)
c Fourth order tensors
      IxI = Eye.dya.Eye
      I_dev = (Eye.cdya.Eye) - 1./3.*(Eye.dya.Eye)
c Check the trial yield function
      if ( d_lambda <= 1e-12 ) then ! numerically zero
          ! Elastic, so we compute the elastic tangent
          tangent_C = bulkMod_kappa * IxI
     &                + 2. * shearMod_mu * I_dev
          else
          ! plastic
          ! LS-Dyna provides the updated stress that already contains the radial return.
          ! However, we can utilise a trick by computing the evolution direction based
          ! on the new stress 'stress', which is identical to the evolution direction
          ! based on the trial stress.
          norm_stress_dev = norm( dev(stress) )
          n = dev(stress) / norm_stress_dev
          ! With the evolution direction we can recover the trial deviatoric stress
          ! needed for the tangent.
          stress_dev_t = dev(stress) + 2. * shearMod_mu * d_lambda * n
          nxn = n.dya.n
          tangent_C = bulkMod_kappa * IxI
     &                + 2. * shearMod_mu * I_dev        
     &                - 4. * shearMod_mu * shearMod_mu
     &                  / ( 2.*shearMod_mu + 2./3. * hardMod_K )
     &                  * nxn
     &                - 4. * shearMod_mu * shearMod_mu
     &                  * d_lambda / norm_stress_dev
     &                  * ( I_dev - nxn )
      endif
c 3.
c Transform tensor 'tangent_C' into the matrix 'es'
      es(1:6,1:6) = asarray(voigt(tangent_C),6,6)
c
      return
      end
