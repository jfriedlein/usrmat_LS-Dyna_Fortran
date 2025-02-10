      subroutine umat43 (cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
      use Tensor
c
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      real(kind=8), dimension(*) :: cm, eps, sig, hsv
      dimension crv(lq1,2,*),cma(*),qmat(3,3)
      logical failel,reject
      integer nnpcrv(*)
      character*5 etype
      INTEGER8 idele
c
      type(Tensor2) :: defoGrad_F
      double precision :: det_F
      type(Tensor2) :: cauchyStress_sig, Eye
      double precision YoungsMod_E, Poisson_nu, lame_lambda, shearMod_mu
c
      YoungsMod_E = cm(1)
      Poisson_nu =  cm(2)
c
      lame_lambda = YoungsMod_E * Poisson_nu
     &              / ( (1.+Poisson_nu)*(1.-2.*Poisson_nu) )
      shearMod_mu = .5 * YoungsMod_E / (1.+Poisson_nu)
c
      Eye = identity2(Eye)
c
      defoGrad_F%ab(1,1) = hsv(1)
      defoGrad_F%ab(2,1) = hsv(2)
      defoGrad_F%ab(3,1) = hsv(3)
      defoGrad_F%ab(1,2) = hsv(4)
      defoGrad_F%ab(2,2) = hsv(5)
      defoGrad_F%ab(3,2) = hsv(6)
      defoGrad_F%ab(1,3) = hsv(7)
      defoGrad_F%ab(2,3) = hsv(8)
      defoGrad_F%ab(3,3) = hsv(9)
c    
      det_F = det(defoGrad_F)
c
      cauchyStress_sig = 1./det_F * (
     &      shearMod_mu * ( (defoGrad_F * transpose(defoGrad_F)) - Eye )
     &      + lame_lambda * log(det_F) * Eye )
c
      sig(1:6) = asarray(voigt(cauchyStress_sig),6)
c
      return
      end
