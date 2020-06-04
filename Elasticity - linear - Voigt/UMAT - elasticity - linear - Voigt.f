      subroutine umat43(cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*),qmat(3,3)
      integer nnpcrv(*)
      character*5 etype
      logical failel,reject
      INTEGER8 idele
c We purposefully use umat43 that contains our desired code, so we can
c deactivate this warning
c      if (ncycle.eq.1) then
c        call usermsg('mat43')
c      endif
c
      lame_lambda = cm(1)
      shearMod_mu = cm(2)
      trEps = eps(1)+eps(2)+eps(3)
      bulkMod_kappa = lame_lambda + 2./3. * shearMod_mu
c      
c The input argument 'eps' only contains the strain increments, so the change in the
c strains compared to the last step. Hence, we compute the stress based on the last
c stress sig(X) plus the stress increment from the strain increment.
      sig(1)=sig(1)+lame_lambda * trEps + 2.*shearMod_mu*eps(1)   
      sig(2)=sig(2)+lame_lambda * trEps + 2.*shearMod_mu*eps(2)     
      sig(3)=sig(3)+lame_lambda * trEps + 2.*shearMod_mu*eps(3)     
      sig(4)=sig(4)+0 + 2.*shearMod_mu*eps(4) *0.5 !Voigt notation factor 0.5
      sig(5)=sig(5)+0 + 2.*shearMod_mu*eps(5) *0.5 !Voigt notation factor 0.5     
      sig(6)=sig(6)+0 + 2.*shearMod_mu*eps(6) *0.5 !Voigt notation factor 0.5    
c
      return
      end
