c Store a fourth order tensor as a list with 36 entries       
       function ten_4_to_list_36(T)
        !implicit none
        
       ! @todo maybe check size of ten_4_to_list_36
        type(Tensor4), intent(in) :: T
        real*8, dimension(36) :: ten_4_to_list_36
        real*8, dimension(6,6) :: es
        integer :: i,j
        es(1:6,1:6) = asarray(asvoigt(T),6,6)

        !forall(i=1:6,j=1:6) ten_4_to_list_36(j+(i-1)*6) = es(i,j)
        do i=1,6
        do j=1,6
            ten_4_to_list_36(j+(i-1)*6) = es(i,j)
        enddo
        enddo

      end function ten_4_to_list_36

c Retrieve from a list with 36 entries the 6x6 matrix     
      function list_36_to_array_6x6(list)
        !implicit none
        
        real*8, dimension(36), intent(in) :: list
        real*8, dimension(6,6) :: list_36_to_array_6x6
        integer :: i,j

        !forall(i=1:6,j=1:6) list_36_to_array_6x6(i,j) = list(j+(i-1)*6)
        do i=1,6
        do j=1,6
           list_36_to_array_6x6(i,j) = list(j+(i-1)*6)
        enddo
        enddo

      end function list_36_to_array_6x6
      
c Retrieve from a list with 21 entries the symmetric 6x6 matrix     
      function list_21_to_array_sym6x6(list)
        !implicit none
        
        real*8, dimension(21), intent(in) :: list
        real*8, dimension(6,6) :: list_21_to_array_sym6x6

        ! @todo Find a more elegant way to store and retrieve this
        list_21_to_array_sym6x6(1,1) = list(1)

        list_21_to_array_sym6x6(1,2) = list(2)
        list_21_to_array_sym6x6(2,1) = list_21_to_array_sym6x6(1,2)
        list_21_to_array_sym6x6(2,2) = list(3)

        list_21_to_array_sym6x6(1,3) = list(4)
        list_21_to_array_sym6x6(3,1) = list_21_to_array_sym6x6(1,3)
        list_21_to_array_sym6x6(2,3) = list(5)
        list_21_to_array_sym6x6(3,2) = list_21_to_array_sym6x6(2,3)
        list_21_to_array_sym6x6(3,3) = list(6)

        list_21_to_array_sym6x6(1,4) = list(7)
        list_21_to_array_sym6x6(4,1) = list_21_to_array_sym6x6(1,4)
        list_21_to_array_sym6x6(2,4) = list(8)
        list_21_to_array_sym6x6(4,2) = list_21_to_array_sym6x6(2,4)
        list_21_to_array_sym6x6(3,4) = list(9)
        list_21_to_array_sym6x6(4,3) = list_21_to_array_sym6x6(3,4)        
        list_21_to_array_sym6x6(4,4) = list(10)

        list_21_to_array_sym6x6(1,5) = list(11)
        list_21_to_array_sym6x6(5,1) = list_21_to_array_sym6x6(1,5)
        list_21_to_array_sym6x6(2,5) = list(12)
        list_21_to_array_sym6x6(5,2) = list_21_to_array_sym6x6(2,5)
        list_21_to_array_sym6x6(3,5) = list(13)
        list_21_to_array_sym6x6(5,3) = list_21_to_array_sym6x6(3,5)        
        list_21_to_array_sym6x6(4,5) = list(14)
        list_21_to_array_sym6x6(5,4) = list_21_to_array_sym6x6(4,5)     
        list_21_to_array_sym6x6(5,5) = list(15)        

        list_21_to_array_sym6x6(1,6) = list(16)
        list_21_to_array_sym6x6(6,1) = list_21_to_array_sym6x6(1,6)
        list_21_to_array_sym6x6(2,6) = list(17)
        list_21_to_array_sym6x6(6,2) = list_21_to_array_sym6x6(2,6)
        list_21_to_array_sym6x6(3,6) = list(18)
        list_21_to_array_sym6x6(6,3) = list_21_to_array_sym6x6(3,6)        
        list_21_to_array_sym6x6(4,6) = list(19)
        list_21_to_array_sym6x6(6,4) = list_21_to_array_sym6x6(4,6)     
        list_21_to_array_sym6x6(5,6) = list(20)
        list_21_to_array_sym6x6(6,5) = list_21_to_array_sym6x6(5,6)    
        list_21_to_array_sym6x6(6,6) = list(21)    

      end function list_21_to_array_sym6x6

       !function list_36_to_ten_4(list)
       ! implicit none
       ! 
       ! type(Tensor4) :: list_36_to_ten_4
       ! real, dimension(36), intent(in) :: list
       ! real, dimension(6,6) :: es
       ! integer :: i,j
       ! 
       ! forall(i=1:6,j=1:6) es(i,j) = list(j+(i-1)*6)
       !
       ! list_36_to_ten_4 = symstore_4sa(es)
       !
       !end function list_36_to_ten_4
