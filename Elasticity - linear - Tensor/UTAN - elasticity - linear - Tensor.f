      subroutine utan43(cm,eps,sig,epsp,hsv,dt1,unsym,capa,etype,tt,
     1 temper,es,crv,nnpcrv,failel,cma,qmat)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c
      use Tensor
      include 'nlqparm'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*)
      integer nnpcrv(*)
      dimension es(6,*),qmat(3,3)
      logical failel,unsym
      character*5 etype
c Declarations
      type(Tensor2) :: Eye
      type(Tensor4)  :: tangent_C, IxI, I_dev

      real lame_lambda, shearMod_mu, bulkMod_kappa
      real con1, con2
c Material parameters
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      bulkMod_kappa = cm(1) + 2./3. * shearMod_mu
c Second order identity tensor
      Eye = identity2(Eye)
c Fourth order tensor
      IxI = Eye.dya.Eye
      I_dev = deviatoric_I4(Eye)
c Compute the tangent modulus as a fourth order tensor
      tangent_C = bulkMod_kappa * IxI
     &            + 2. * shearMod_mu * I_dev
c Transform tensor 'tangent_C' into the vectorial 'es'
      es(1:6,1:6) = asarray(voigt(tangent_C),6,6)
c
      return
      end
