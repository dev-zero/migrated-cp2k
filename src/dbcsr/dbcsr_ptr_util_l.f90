!-----------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations         !
!   Copyright (C) 2000 - 2014  CP2K developers group                          !
!-----------------------------------------------------------------------------!

! *****************************************************************************
!> \brief Returns a pointer with different bounds.
!> \param[in] original   original data pointer
!> \param[in] lb, ub     lower and upper bound for the new pointer view
!> \param[out] view      new pointer
! *****************************************************************************
  FUNCTION pointer_view_l (original, lb, ub) RESULT (view)
    INTEGER(kind=int_8), DIMENSION(:), POINTER :: original, view
    INTEGER, INTENT(IN)                  :: lb, ub
    view => original(lb:ub)
  END FUNCTION pointer_view_l


! *****************************************************************************
!> \brief Ensures that an array is appropriately large.
!> \param[in,out] array       array to verify and possibly resize
!> \param[in] lb    (optional) desired array lower bound
!> \param[in] ub    desired array upper bound
!> \param[in] factor          (optional) factor by which to exagerrate
!>                            enlargements
!> \param[in] nocopy          (optional) copy array on enlargement; default
!>                            is to copy
!> \param[in] memory_type     (optional) use special memory
!> \param[in] zero_pad        (optional) zero new allocations; default is to
!>                            write nothing
! *****************************************************************************
  SUBROUTINE ensure_array_size_l(array, lb, ub, factor,&
       nocopy, memory_type, zero_pad, error)
    INTEGER(kind=int_8), DIMENSION(:), POINTER                 :: array
    INTEGER, INTENT(IN), OPTIONAL                  :: lb
    INTEGER, INTENT(IN)                            :: ub
    REAL(KIND=dp), INTENT(IN), OPTIONAL            :: factor
    LOGICAL, INTENT(IN), OPTIONAL                  :: nocopy, zero_pad
    TYPE(dbcsr_memtype_type), INTENT(IN), OPTIONAL :: memory_type
    TYPE(dbcsr_error_type), INTENT(inout)          :: error

    CHARACTER(len=*), PARAMETER :: routineN = 'ensure_array_size_l', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: lb_new, lb_orig, &
                                                ub_new, ub_orig, old_size,&
                                                size_increase
    TYPE(dbcsr_memtype_type)                 :: mem_type
    LOGICAL                                  :: dbg, docopy, &
                                                pad
    INTEGER(kind=int_8), DIMENSION(:), POINTER           :: newarray

!   ---------------------------------------------------------------------------
    !CALL dbcsr_error_set(routineN, error_handler, error)
    dbg = .FALSE.

    IF (PRESENT (nocopy)) THEN
       docopy = .NOT. nocopy
    ELSE
       docopy = .TRUE.
    ENDIF
    IF (PRESENT (memory_type)) THEN
       mem_type = memory_type
    ELSE
       mem_type = dbcsr_memtype_default
    ENDIF
    lb_new = 1
    IF (PRESENT (lb)) lb_new = lb
    pad = .FALSE.
    IF (PRESENT (zero_pad)) pad = zero_pad
    !> Creates a new array if it doesn't yet exist.
    IF (.NOT.ASSOCIATED(array)) THEN
       CALL dbcsr_assert (lb_new, "EQ", 1, &
            dbcsr_fatal_level, dbcsr_unimplemented_error_nr, routineN,&
            "Arrays must start at 1", __LINE__, error=error)
       CALL mem_alloc_l (array, ub, mem_type=mem_type, error=error)
       IF (pad .AND. ub .GT. 0) CALL mem_zero_l (array, ub)
       !CALL dbcsr_error_stop(error_handler, error)
       RETURN
    ENDIF
    lb_orig = LBOUND(array,1)
    ub_orig = UBOUND(array,1)
    old_size = ub_orig - lb_orig + 1
    ! The existing array is big enough.
    IF (lb_orig.LE.lb_new .AND. ub_orig.GE.ub) THEN
       !CALL dbcsr_error_stop(error_handler, error)
       RETURN
    ENDIF
    ! A reallocation must be performed
    IF(dbg) WRITE(*,*)routineP//' Current bounds are',lb_orig,':',ub_orig,&
         '; special?' !,mem_type
    !CALL timeset(routineN,timing_handle)
    IF (lb_orig.GT.lb_new) THEN
       IF (PRESENT(factor)) THEN
          size_increase = lb_orig - lb_new
          size_increase = MAX (NINT(size_increase*factor),&
                               NINT(old_size*(factor-1)),0)
          lb_new = MIN (lb_orig, lb_new - size_increase)
       ELSE
          lb_new = lb_orig
       ENDIF
    ENDIF
    IF (ub_orig.LT.ub) THEN
       IF (PRESENT(factor)) THEN
          size_increase = ub - ub_orig
          size_increase = MAX (NINT(size_increase*factor),&
                               NINT(old_size*(factor-1)),0)
          ub_new = MAX (ub_orig, ub + size_increase)
       ELSE
          ub_new = ub
       ENDIF
    ELSE
       ub_new = ub
    ENDIF
    IF(dbg) WRITE(*,*)routineP//' Resizing to bounds',lb_new,':',ub_new
    !
    ! Deallocates the old array if it's not needed to copy the old data.
    IF(.NOT.docopy) THEN
       CALL mem_dealloc_l (array, mem_type=mem_type, error=error)
    ENDIF
    !
    ! Allocates the new array
    CALL dbcsr_assert (lb_new, "EQ", 1, &
         dbcsr_fatal_level, dbcsr_unimplemented_error_nr, routineN,&
         "Arrays must start at 1", __LINE__, error=error)
    CALL mem_alloc_l (newarray, ub_new-lb_new+1, mem_type, error=error)
    !
    ! Now copy and/or zero pad.
    IF(docopy) THEN
       IF(dbg) CALL dbcsr_assert(lb_new.LE.lb_orig .AND. ub_new.GE.ub_orig,&
            dbcsr_failure_level, dbcsr_internal_error, routineP,&
            "Old extent exceeds the new one.",__LINE__,error)
       IF (ub_orig-lb_orig+1 .GT. 0) THEN
          !newarray(lb_orig:ub_orig) = array(lb_orig:ub_orig)
          CALL mem_copy_l (newarray(lb_orig:ub_orig),&
               array(lb_orig:ub_orig), ub_orig-lb_orig+1)
       ENDIF
       IF (pad) THEN
          !newarray(lb_new:lb_orig-1) = 0
          CALL mem_zero_l (newarray(lb_new:lb_orig-1), (lb_orig-1)-lb_new+1)
          !newarray(ub_orig+1:ub_new) = 0
          CALL mem_zero_l (newarray(ub_orig+1:ub_new), ub_new-(ub_orig+1)+1)
       ENDIF
       CALL mem_dealloc_l (array, mem_type=mem_type, error=error)
    ELSEIF (pad) THEN
       !newarray(:) = 0
       CALL mem_zero_l (newarray, SIZE(newarray))
    ENDIF
    array => newarray
    IF (dbg) WRITE(*,*)routineP//' New array size', SIZE(array)
    !CALL dbcsr_error_stop(error_handler, error)
  END SUBROUTINE ensure_array_size_l

! *****************************************************************************
!> \brief Copies memory area
!> \param[out] dst   destination memory
!> \param[in] src    source memory
!> \param[in] n      length of copy
! *****************************************************************************
  SUBROUTINE mem_copy_l (dst, src, n)
    INTEGER, INTENT(IN) :: n
    INTEGER(kind=int_8), DIMENSION(1:n), INTENT(OUT) :: dst
    INTEGER(kind=int_8), DIMENSION(1:n), INTENT(IN) :: src
    dst(:) = src(:)
  END SUBROUTINE mem_copy_l

! *****************************************************************************
!> \brief Zeros memory area
!> \param[out] dst   destination memory
!> \param[in] n      length of elements to zero
! *****************************************************************************
  SUBROUTINE mem_zero_l (dst, n)
    INTEGER, INTENT(IN) :: n
    INTEGER(kind=int_8), DIMENSION(1:n), INTENT(OUT) :: dst
    dst(:) = 0
  END SUBROUTINE mem_zero_l


! *****************************************************************************
!> \brief Allocates memory
!> \param[out] mem        memory to allocate
!> \param[in] n           length of elements to allocate
!> \param[in] mem_type    memory type
!> \param[in,out] error   error
! *****************************************************************************
  SUBROUTINE mem_alloc_l (mem, n, mem_type, error)
    INTEGER(kind=int_8), DIMENSION(:), POINTER        :: mem
    INTEGER, INTENT(IN)                   :: n
    TYPE(dbcsr_memtype_type), INTENT(IN)  :: mem_type
    TYPE(dbcsr_error_type), INTENT(INOUT) :: error
    CHARACTER(len=*), PARAMETER :: routineN = 'mem_alloc_l', &
      routineP = moduleN//':'//routineN
    INTEGER                               :: error_handle
!   ---------------------------------------------------------------------------

    IF (careful_mod) &
       CALL dbcsr_error_set (routineN, error_handle, error=error)

    IF(mem_type%acc_hostalloc .AND. n>1) THEN
       CALL acc_hostmem_allocate(mem, n)
    ELSE IF(mem_type%mpi) THEN
       CALL mp_allocate(mem, n)
    ELSE
       ALLOCATE(mem(n))
    ENDIF

    IF (careful_mod) &
       CALL dbcsr_error_stop (error_handle, error=error)
  END SUBROUTINE mem_alloc_l


! *****************************************************************************
!> \brief Allocates memory
!> \param[out] mem        memory to allocate
!> \param[in] n           length of elements to allocate
!> \param[in] mem_type    memory type
!> \param[in,out] error   error
! *****************************************************************************
  SUBROUTINE mem_alloc_l_2d (mem, sizes, mem_type, error)
    INTEGER(kind=int_8), DIMENSION(:,:), POINTER      :: mem
    INTEGER, DIMENSION(2), INTENT(IN)     :: sizes
    TYPE(dbcsr_memtype_type), INTENT(IN)  :: mem_type
    TYPE(dbcsr_error_type), INTENT(INOUT) :: error
    CHARACTER(len=*), PARAMETER :: routineN = 'mem_alloc_l_2d', &
      routineP = moduleN//':'//routineN
    INTEGER                               :: error_handle
!   ---------------------------------------------------------------------------

    IF (careful_mod) &
       CALL dbcsr_error_set (routineN, error_handle, error=error)

    IF(mem_type%acc_hostalloc) THEN
       CALL dbcsr_assert(.FALSE., dbcsr_fatal_level, dbcsr_caller_error,&
               routineN, "Accelerator hostalloc not supported for 2D arrays.",__LINE__,error)
       !CALL acc_hostmem_allocate(mem, n)
    ELSE IF(mem_type%mpi) THEN
       CALL dbcsr_assert(.FALSE., dbcsr_fatal_level, dbcsr_caller_error,&
          routineN, "MPI allocate not supported for 2D arrays.",__LINE__,error)
       !CALL mp_allocate(mem, n)
    ELSE
       ALLOCATE(mem(sizes(1), sizes(2)))
    ENDIF

    IF (careful_mod) &
       CALL dbcsr_error_stop (error_handle, error=error)
  END SUBROUTINE mem_alloc_l_2d


! *****************************************************************************
!> \brief Deallocates memory
!> \param[out] mem        memory to allocate
!> \param[in] n           length of elements to allocate
!> \param[in] mem_type    memory type
!> \param[in,out] error   error
! *****************************************************************************
  SUBROUTINE mem_dealloc_l (mem, mem_type, error)
    INTEGER(kind=int_8), DIMENSION(:), POINTER        :: mem
    TYPE(dbcsr_memtype_type), INTENT(IN)  :: mem_type
    TYPE(dbcsr_error_type), INTENT(INOUT) :: error
    CHARACTER(len=*), PARAMETER :: routineN = 'mem_dealloc_l', &
      routineP = moduleN//':'//routineN
    INTEGER                               :: error_handle
!   ---------------------------------------------------------------------------

    IF (careful_mod) &
       CALL dbcsr_error_set (routineN, error_handle, error=error)

    IF(mem_type%acc_hostalloc .AND. SIZE(mem)>1) THEN
       CALL acc_hostmem_deallocate(mem)
    ELSE IF(mem_type%mpi) THEN
       CALL mp_deallocate(mem)
    ELSE
       DEALLOCATE(mem)
    ENDIF

    IF (careful_mod) &
       CALL dbcsr_error_stop (error_handle, error=error)
  END SUBROUTINE mem_dealloc_l


! *****************************************************************************
!> \brief Deallocates memory
!> \param[out] mem        memory to allocate
!> \param[in] n           length of elements to allocate
!> \param[in] mem_type    memory type
!> \param[in,out] error   error
! *****************************************************************************
  SUBROUTINE mem_dealloc_l_2d (mem, mem_type, error)
    INTEGER(kind=int_8), DIMENSION(:,:), POINTER      :: mem
    TYPE(dbcsr_memtype_type), INTENT(IN)  :: mem_type
    TYPE(dbcsr_error_type), INTENT(INOUT) :: error
    CHARACTER(len=*), PARAMETER :: routineN = 'mem_dealloc_l', &
      routineP = moduleN//':'//routineN
    INTEGER                               :: error_handle
!   ---------------------------------------------------------------------------

    IF (careful_mod) &
       CALL dbcsr_error_set (routineN, error_handle, error=error)

    IF(mem_type%acc_hostalloc) THEN
       CALL dbcsr_assert(.FALSE., dbcsr_fatal_level, dbcsr_caller_error,&
          routineN, "Accelerator host deallocate not supported for 2D arrays.",__LINE__,error)
       !CALL acc_hostmem_deallocate(mem)
    ELSE IF(mem_type%mpi) THEN
       CALL dbcsr_assert(.FALSE., dbcsr_fatal_level, dbcsr_caller_error,&
          routineN, "MPI deallocate not supported for 2D arrays.",__LINE__,error)
       !CALL mp_deallocate(mem)
    ELSE
       DEALLOCATE(mem)
    ENDIF

    IF (careful_mod) &
       CALL dbcsr_error_stop (error_handle, error=error)
  END SUBROUTINE mem_dealloc_l_2d


#if defined(__PTR_RANK_REMAP)
! *****************************************************************************
!> \brief Sets a rank-2 pointer to rank-1 data using Fortran 2003 pointer
!>        rank remapping.
! *****************************************************************************
  SUBROUTINE pointer_l_rank_remap2 (r2p, d1, d2, r1p)
    INTEGER, INTENT(IN)                      :: d1, d2
    INTEGER(kind=int_8), DIMENSION(:, :), &
      POINTER                                :: r2p
    INTEGER(kind=int_8), DIMENSION(:), &
      POINTER                                :: r1p

    r2p(1:d1,1:d2) => r1p(1:d1*d2)
  END SUBROUTINE pointer_l_rank_remap2
#elif !defined(__HAS_NO_ISO_C_BINDING)
! *****************************************************************************
!> \brief Sets a rank-2 pointer to rank-1 data using Fortran 2003 pointer
!>        ISO_C_BINDING.
! *****************************************************************************
  SUBROUTINE pointer_l_rank_remap2 (r2p, d1, d2, r1p)
    INTEGER, INTENT(IN)                      :: d1, d2
    INTEGER(kind=int_8), DIMENSION(:, :), &
      POINTER                                :: r2p
    INTEGER(kind=int_8), DIMENSION(:), &
      POINTER                                :: r1p
    TYPE(C_PTR)                              :: fe_loc

    IF (SIZE(r1p) .EQ. 0) THEN
       fe_loc = C_NULL_PTR
    ELSE
       fe_loc = C_LOC (r1p(1))
    ENDIF
    CALL C_F_POINTER (fe_loc, r2p, (/ d1, d2 /))
  END SUBROUTINE pointer_l_rank_remap2
#elif !defined(__NO_ASSUMED_SIZE_NOCOPY_ASSUMPTION)
! *****************************************************************************
!> \brief Sets a rank-2 pointer to rank-1 data using ugly hacks.
! *****************************************************************************
  SUBROUTINE pointer_l_rank_remap2 (r2p, d1, d2, r1p)
    INTEGER(kind=int_8), DIMENSION(:, :), &
      POINTER                                :: r2p
    INTEGER, INTENT(IN)                      :: d1, d2
    INTEGER(kind=int_8), DIMENSION(d1, *), &
      TARGET                                 :: r1p

    r2p => r1p(1:d1, 1:d2)
  END SUBROUTINE pointer_l_rank_remap2
#else
! *****************************************************************************
!> \brief Not supported
! *****************************************************************************
  SUBROUTINE pointer_l_rank_remap2 (r2p, d1, d2, r1p)
    INTEGER, INTENT(IN)                      :: d1, d2
    INTEGER(kind=int_8), DIMENSION(:, :), &
      POINTER                                :: r2p
    INTEGER(kind=int_8), DIMENSION(d1*d2), &
      TARGET                                 :: r1p

!    r2p(1:d1,1:d2) => r1p(1:d1*d2)
    STOP "Pointer rank remapping needed but not supported directly or with hacks."
    NULLIFY (r2p)
  END SUBROUTINE pointer_l_rank_remap2
#endif
