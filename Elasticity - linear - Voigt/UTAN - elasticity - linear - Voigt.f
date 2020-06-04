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
      include 'nlqparm'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*)
      integer nnpcrv(*)
      dimension es(6,*),qmat(3,3)
      logical failel,unsym
      character*5 etype
c
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
c @note Be aware of integer-divison also in Fortran similar to C++.
c Always use a dot after floating point numbers especially for division,
c even though we never declare variables as integer or double
      bulkMod_kappa = lame_lambda + 2./3. * shearMod_mu
      con1 = bulkMod_kappa + 4. * shearMod_mu/3.
      con2 = bulkMod_kappa - 2. * shearMod_mu/3.
c
      es(1,1) = con1
      es(2,2) = con1
      es(3,3) = con1
      es(1,2) = con2
      es(1,3) = con2
      es(2,3) = con2
      es(4,4) = shearMod_mu
      es(5,5) = shearMod_mu
      es(6,6) = shearMod_mu
c Set the symmetric entries that are non-zero
      es(2,1) = es(1,2)
      es(3,1) = es(1,3)
      es(3,2) = es(2,3)
c All the leftover entries of the tangent 'es' are zero, which equals the
c the initial value.
c
      return
      end
