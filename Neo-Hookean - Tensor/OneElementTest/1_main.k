*KEYWORD
*PARAMETER
$#   prmr1      val1     prmr2      val2     prmr3      val3     prmr4      val4
R tmax    1
$
*CONTROL_IMPLICIT_GENERAL
$#  imflag       dt0    imform      nsbs       igs     cnstn      form    zero_v
         1         1         2         1         1         0         0         0
*CONTROL_IMPLICIT_SOLUTION
$#  nsolvr    ilimit    maxref     dctol     ectol     rctol     lstol    abstol
        12         1        16  1.00E-20  1.00E-20  1.000E-8       0.9  -1.00E-6
$#   dnorm    diverg     istif   nlprint    nlnorm   d3itctl     cpchk     
         1         1         1         2         2         0         0
$#  arcctl    arcdir    arclen    arcmth    arcdmp    arcpsi    arcalf    arctim
         0         0       0.0         1         2         0         0         0
$#   lsmtd     lsdir      irad      srad      awgt      sred    
         4         2       0.0       0.0       0.0       0.0
*CONTROL_TERMINATION
$#  endtim    endcyc     dtmin    endeng    endmas     nosol     
     &tmax         0       1.0      0.01       0.0         0
*DATABASE_ELOUT
$#      dt    binary      lcur     ioopt   option1   option2   option3   option4
       1.0         3         0         1         9         0         0         0
*DATABASE_NODFOR
$#      dt    binary      lcur     ioopt     
       1.0         3         0         1
*DATABASE_NODAL_FORCE_GROUP
$#    nsid       cid   
         1         0
*DATABASE_NODOUT
$#      dt    binary      lcur     ioopt   option1   option2       
       1.0         3         0         1       0.0         0
*DATABASE_SECFORC
$#      dt    binary      lcur     ioopt     
       1.0         3         0         1
*DATABASE_BINARY_D3PLOT
$#      dt      lcdt      beam     npltc    psetid      
       1.0         0         0         0         0
$#   ioopt      rate    cutoff    window      type      pset    
         0       0.0       0.0       0.0         0         0
*BOUNDARY_PRESCRIBED_MOTION_SET
$#    nsid       dof       vad      lcid        sf       vid     death     birth
         1         1         2         1       1.0         01.00000E28       0.0
*CONSTRAINED_GLOBAL
$#      tc        rc       dir         x         y         z       tol  
         1         0         1       0.0       0.0       0.0       0.0
         2         0         2       0.0       0.0       0.0       0.0 
         3         0         3       0.0       0.0       0.0       0.0
*PART
$#                                                                         title
OneElement
$#     pid     secid       mid     eosid      hgid      grav    adpopt      tmid
         1         1         1         0         0         0         0         0
*SECTION_SOLID
$#   secid    elform       aet    unused    unused    unused    cohoff    unused
         1         2         0
*DEFINE_CURVE_TITLE
Linear_Load
$#    lcid      sidr       sfa       sfo      offa      offo    dattyp     lcint
         1         0       1.0       1.0       0.0       0.0         0         0
$#                a1                  o1  
                 0.0                 0.0
               &tmax                 5.0
*SET_NODE_LIST_TITLE
node set x+
$#     sid       da1       da2       da3       da4    solver      
         1       0.0       0.0       0.0       0.0MECH
$#    nid1      nid2      nid3      nid4      nid5      nid6      nid7      nid8
         2         4         6         8         0         0         0         0
*NODE
$#   nid               x               y               z      tc      rc  
       1             0.0             0.0             0.0       0       0
       2             1.0             0.0             0.0       0       0
       3             0.0             1.0             0.0       0       0
       4             1.0             1.0             0.0       0       0
       5             0.0             0.0             1.0       0       0
       6             1.0             0.0             1.0       0       0
       7             0.0             1.0             1.0       0       0
       8             1.0             1.0             1.0       0       0
*ELEMENT_SOLID
$#   eid     pid      n1      n2      n3      n4      n5      n6      n7      n8
       1       1       1       2       4       3       5       6       8       7
*INCLUDE
$../05_UMAT43_NeoHookean-Tensor.inc
../05_UMAT45_NeoHookean-Voigt.inc
$
*END
