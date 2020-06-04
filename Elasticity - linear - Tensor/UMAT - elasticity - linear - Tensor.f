      subroutine umat49 (cm,eps,sig,epsp,hsv,dt1,capa,etype,tt,
     1 temper,failel,crv,nnpcrv,cma,qmat,elsiz,idele,reject)
c
c******************************************************************
c|  Livermore Software Technology Corporation  (LSTC)             |
c|  ------------------------------------------------------------  |
c|  Copyright 1987-2008 Livermore Software Tech. Corp             |
c|  All rights reserved                                           |
c******************************************************************
c #######        Elasticity using the tensor toolbox     ##########
c******************************************************************
c Use the tensor toolbox
c The position of this 'use' is crucial (first entry)
      use Tensor
c
      include 'nlqparm'
      include 'bk06.inc'
      include 'iounits.inc'
      dimension cm(*),eps(*),sig(*),hsv(*),crv(lq1,2,*),cma(*),qmat(3,3)
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
c The function 'str2ten_2s' transforms the strain 'eps' from the vector
c notation to the ttb tensor data type (correct assignment of vector to
c tensor index AND Voigt-factor 0.5), which is equivalent to:
c      d_eps%ab(1,1) = eps(1)
c      d_eps%ab(2,2) = eps(2)
c      d_eps%ab(3,3) = eps(3)
c      d_eps%ab(1,2) = eps(4) * 0.5
c      d_eps%ab(2,3) = eps(5) * 0.5
c      d_eps%ab(1,3) = eps(6) * 0.5
c      d_eps%ab(2,1) = eps(4) * 0.5
c      d_eps%ab(3,2) = eps(5) * 0.5
c      d_eps%ab(3,1) = eps(6) * 0.5
c One-liner:
c @todo Was this fnc renamed from voigtstrain to str2ten_2s ?
      d_eps = str2ten_2s(eps,3,3,6)
c
c The function 'symstore_2sa' stores a vector as a tensor,
c equivalent to:
c      stress_n%ab(1,1) = sig(1)
c      stress_n%ab(2,2) = sig(2)
c      stress_n%ab(3,3) = sig(3)
c      stress_n%ab(1,2) = sig(4)
c      stress_n%ab(2,3) = sig(5)
c      stress_n%ab(1,3) = sig(6)
c      stress_n%ab(2,1) = sig(4)
c      stress_n%ab(3,2) = sig(5)
c      stress_n%ab(3,1) = sig(6)
c One-liner:
      stress_n = symstore_2sa(sig)
c
c Our stress equation in tensor notation, finally
c ... happily, thanks to Andreas Dutzler!
      stress = stress_n + lame_lambda * tr(d_eps) * Eye
     &                  + 2.*shearMod_mu*d_eps
c Transform the stress tensor back into a vector, equivalent to:
c      sig(1) = stress%ab(1,1)
c      sig(2) = stress%ab(2,2)
c      sig(3) = stress%ab(3,3)
c      sig(4) = stress%ab(1,2)
c      sig(5) = stress%ab(2,3)
c      sig(6) = stress%ab(1,3)
c One-liner:
      sig(1:6) = asarray(voigt(stress),6)
c
c Everything is done with just a few lines of code ... perfect
c
      return
      end
