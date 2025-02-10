      subroutine utan43(cm,eps,sig,epsp,hsv,dt1,unsym,capa,etype,tt,
     1 temper,es,crv,nnpcrv,failel,cma,qmat)
c
      use Tensor
c
      include 'nlqparm'
      real(kind=8), dimension (*) :: cm, eps, sig, hsv
      dimension crv(lq1,2,*),cma(*)
      integer nnpcrv(*)
      dimension es(6,*),qmat(3,3)
      logical failel,unsym
      character*5 etype
c
       type(Tensor2) :: defoGrad_F
       double precision :: det_F
       type(Tensor2) :: Eye
       type(Tensor4) :: tangent_E
      double precision YoungsMod_E, Poisson_nu, lame_lambda, shearMod_mu
c
      YoungsMod_E = cm(1)
      Poisson_nu = cm(2)
c
      lame_lambda = YoungsMod_E * Poisson_nu
     &              / ((1.+Poisson_nu)*(1.-2.*Poisson_nu))
      shearMod_mu = .5*YoungsMod_E / (1.+Poisson_nu)
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
      tangent_E = 1./det_F * (
     &       lame_lambda * (Eye.dya.Eye)
     &       + ( 2. * ( shearMod_mu - lame_lambda * log(det_F) )
     &              * identity4(Eye) )
     &       )
c
      es(1:6,1:6) = asarray(voigt(tangent_E),6,6)
c      
      return
      end
