        function stiffnessTensor4_to_LSD6x6(T)
        ! Transform a fourth order stiffness tensor to its
        ! LS-Dyna 6x6 "es" matrix representation.
        ! @note LS-Dyna vector notation (11,22,33,12,23,31)
        !       is different from Voigt (11,22,33,23,13,12)
        ! @test compared for anisotropic non-associative 4th order tensor (presumably non-sym matrix)
c
        implicit none
c
        real(kind=8), dimension(6,6) :: stiffnessTensor4_to_LSD6x6
        ! Fourth order input tensor
         type(Tensor4), intent(in) :: T
        ! Auxiliary variable to store data from "stiffnessTensor4_to_LSD6x6"
        ! only used because the function name is so long and cumbersome
         real(kind=8), dimension(6,6) :: LSD_6x6
        ! i: iteration index for "do"-loops
         integer i, j
        ! Scaling factors for components of tensor to matrix (scaleT_*)
         real(kind=8) scaleT_14, scaleT_44
        ! Define the scaling factors for the conversion from tensor to LS-Dyna matrix
        ! @note The following was created based on trial-error and is "NOT verified"
        ! @todo Why do we need 0.5 on certain values?
        !  This factor does not only affect unsym non-associative plasticity, but also improves Hill48 plasticity under 45°, ...
         scaleT_14 = 0.5d0
         scaleT_44 = 1.d0
c
        ! Fill first three rows
         do i=1,3
            LSD_6x6(i,1) = T%abcd(i,i,1,1)
            LSD_6x6(i,2) = T%abcd(i,i,2,2)
            LSD_6x6(i,3) = T%abcd(i,i,3,3)
            LSD_6x6(i,5) = scaleT_14*T%abcd(i,i,2,3)
            LSD_6x6(i,6) = scaleT_14*T%abcd(i,i,1,3)
            LSD_6x6(i,4) = scaleT_14*T%abcd(i,i,1,2)
         end do

        ! Fill fifth row
         LSD_6x6(5,1) = scaleT_14*T%abcd(2,3,1,1)
         LSD_6x6(5,2) = scaleT_14*T%abcd(2,3,2,2)
         LSD_6x6(5,3) = scaleT_14*T%abcd(2,3,3,3)
         LSD_6x6(5,5) = scaleT_44*T%abcd(2,3,2,3)
         LSD_6x6(5,6) = scaleT_44*T%abcd(2,3,1,3)
         LSD_6x6(5,4) = scaleT_44*T%abcd(2,3,1,2)

        ! Fill sixth row
         LSD_6x6(6,1) = scaleT_14*T%abcd(1,3,1,1)
         LSD_6x6(6,2) = scaleT_14*T%abcd(1,3,2,2)
         LSD_6x6(6,3) = scaleT_14*T%abcd(1,3,3,3)
         LSD_6x6(6,5) = scaleT_44*T%abcd(1,3,2,3)
         LSD_6x6(6,6) = scaleT_44*T%abcd(1,3,1,3)
         LSD_6x6(6,4) = scaleT_44*T%abcd(1,3,1,2)

        ! Fill fourth row
         LSD_6x6(4,1) = scaleT_14*T%abcd(1,2,1,1)
         LSD_6x6(4,2) = scaleT_14*T%abcd(1,2,2,2)
         LSD_6x6(4,3) = scaleT_14*T%abcd(1,2,3,3)
         LSD_6x6(4,5) = scaleT_44*T%abcd(1,2,2,3)
         LSD_6x6(4,6) = scaleT_44*T%abcd(1,2,1,3)
         LSD_6x6(4,4) = scaleT_44*T%abcd(1,2,1,2)
c
c Copy the 6x6 matrix into the output variable
        stiffnessTensor4_to_LSD6x6 = LSD_6x6
c
       end function stiffnessTensor4_to_LSD6x6
c
c ######################################################################
c
      function LSD6x6_to_stiffnessTensor4(es)
      ! Transform the LS-Dyna stiffness matrix "es" to
      ! its fourth order tensor representation
      ! @note LS-Dyna vector notation (11,22,33,12,23,31)
      !       is different from Voigt (11,22,33,23,13,12)
c
        implicit none
c
        real(kind=8), dimension(6,6), intent(in) :: es
        type(Tensor4) :: LSD6x6_to_stiffnessTensor4, Ten4
        integer i
        real(kind=8) scaleM_14, scaleM_44
c
        ! Define the scaling factors for the conversion from LS-Dyna matrix to tensor
        ! @note The following was created based on the trial-error
        !       values from "stiffnessTensor4_to_LSD6x6" and is "NOT verified"
         scaleM_14 = 2.d0
         scaleM_44 = 1.d0
c
        ! Fill tensor components (i,i,j,l) and (j,l,i,i)
         do i=1,3
            Ten4%abcd(i,i,1,1) = es(i,1)
            Ten4%abcd(i,i,1,2) = scaleM_14*es(i,4) ! @BUGfix: before "es(i,6)"
            Ten4%abcd(i,i,1,3) = scaleM_14*es(i,6)
            Ten4%abcd(i,i,2,1) = scaleM_14*es(i,4)
            Ten4%abcd(i,i,2,2) = es(i,2)
            Ten4%abcd(i,i,2,3) = scaleM_14*es(i,5)
            Ten4%abcd(i,i,3,1) = scaleM_14*es(i,6)
            Ten4%abcd(i,i,3,2) = scaleM_14*es(i,5)
            Ten4%abcd(i,i,3,3) = es(i,3)

            Ten4%abcd(1,2,i,i) = scaleM_14*es(4,i)
            Ten4%abcd(1,3,i,i) = scaleM_14*es(6,i)
            Ten4%abcd(2,1,i,i) = scaleM_14*es(4,i)
            Ten4%abcd(2,3,i,i) = scaleM_14*es(5,i)
            Ten4%abcd(3,1,i,i) = scaleM_14*es(6,i)
            Ten4%abcd(3,2,i,i) = scaleM_14*es(5,i)
         end do

        ! Fill entries (1,2,i,j) for i.NE.j
         Ten4%abcd(1,2,1,2) = scaleM_44*es(4,4)
         Ten4%abcd(1,2,1,3) = scaleM_44*es(4,6)
         Ten4%abcd(1,2,2,1) = scaleM_44*es(4,4)
         Ten4%abcd(1,2,2,3) = scaleM_44*es(4,5)
         Ten4%abcd(1,2,3,1) = scaleM_44*es(4,6)
         Ten4%abcd(1,2,3,2) = scaleM_44*es(4,5)

        ! Fill entries (1,3,i,j) for i.NE.j
         Ten4%abcd(1,3,1,2) = scaleM_44*es(6,4)
         Ten4%abcd(1,3,1,3) = scaleM_44*es(6,6)
         Ten4%abcd(1,3,2,1) = scaleM_44*es(6,4)
         Ten4%abcd(1,3,2,3) = scaleM_44*es(6,5)
         Ten4%abcd(1,3,3,1) = scaleM_44*es(6,6)
         Ten4%abcd(1,3,3,2) = scaleM_44*es(6,5)

        ! Fill entries (2,1,i,j) for i.NE.j
         Ten4%abcd(2,1,1,2) = scaleM_44*es(4,4)
         Ten4%abcd(2,1,1,3) = scaleM_44*es(4,6)
         Ten4%abcd(2,1,2,1) = scaleM_44*es(4,4)
         Ten4%abcd(2,1,2,3) = scaleM_44*es(4,5)
         Ten4%abcd(2,1,3,1) = scaleM_44*es(4,6)
         Ten4%abcd(2,1,3,2) = scaleM_44*es(4,5)

        ! Fill entries (2,3,i,j) for i.NE.j
         Ten4%abcd(2,3,1,2) = scaleM_44*es(5,4)
         Ten4%abcd(2,3,1,3) = scaleM_44*es(5,6)
         Ten4%abcd(2,3,2,1) = scaleM_44*es(5,4)
         Ten4%abcd(2,3,2,3) = scaleM_44*es(5,5)
         Ten4%abcd(2,3,3,1) = scaleM_44*es(5,6)
         Ten4%abcd(2,3,3,2) = scaleM_44*es(5,5)

        ! Fill entries (3,1,i,j) for i.NE.j
         Ten4%abcd(3,1,1,2) = scaleM_44*es(6,4)
         Ten4%abcd(3,1,1,3) = scaleM_44*es(6,6)
         Ten4%abcd(3,1,2,1) = scaleM_44*es(6,4)
         Ten4%abcd(3,1,2,3) = scaleM_44*es(6,5)
         Ten4%abcd(3,1,3,1) = scaleM_44*es(6,6)
         Ten4%abcd(3,1,3,2) = scaleM_44*es(6,5)

        ! Fill entries (1,2,i,j) for i.NE.j
         Ten4%abcd(3,2,1,2) = scaleM_44*es(5,4)
         Ten4%abcd(3,2,1,3) = scaleM_44*es(5,6)
         Ten4%abcd(3,2,2,1) = scaleM_44*es(5,4)
         Ten4%abcd(3,2,2,3) = scaleM_44*es(5,5)
         Ten4%abcd(3,2,3,1) = scaleM_44*es(5,6)
         Ten4%abcd(3,2,3,2) = scaleM_44*es(5,5)
c
c Copy the tensor into the output variable
        LSD6x6_to_stiffnessTensor4 = Ten4
c
       end function LSD6x6_to_stiffnessTensor4
