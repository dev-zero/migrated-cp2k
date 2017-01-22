!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright (C) 2000 - 2017  CP2K developers group                                               !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \brief Sets the diagonal of a square data block
!> \param[out] block_data     sets the diagonal of this data block
!> \param[in] diagonal        set diagonal of block_data to these values
!> \param[in] d               dimension of block
!> \par Off-diagonal values
!>      Other values are untouched.
! **************************************************************************************************
  PURE SUBROUTINE set_block2d_diagonal_d (block_data, diagonal, d)
    INTEGER, INTENT(IN)                    :: d
    REAL(kind=real_8), DIMENSION(d,d), INTENT(INOUT) :: block_data
    REAL(kind=real_8), DIMENSION(d), INTENT(IN)      :: diagonal

    INTEGER                                :: i

!   ---------------------------------------------------------------------------

    DO i = 1 , d
       block_data(i,i) = diagonal(i)
    END DO
  END SUBROUTINE set_block2d_diagonal_d


! **************************************************************************************************
!> \brief Gets the diagonal of a square data block
!> \param[in] block_data      gets the diagonal of this data block
!> \param[out] diagonal       values of the diagonal elements
!> \param[in] d               dimension of block
! **************************************************************************************************
  PURE SUBROUTINE get_block2d_diagonal_d (block_data, diagonal, d)
    INTEGER, INTENT(IN)                 :: d
    REAL(kind=real_8), DIMENSION(d,d), INTENT(IN) :: block_data
    REAL(kind=real_8), DIMENSION(d), INTENT(OUT)  :: diagonal

    INTEGER                             :: i

!   ---------------------------------------------------------------------------

    DO i = 1 , d
       diagonal(i) = block_data(i, i)
    END DO
  END SUBROUTINE get_block2d_diagonal_d


! **************************************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param dst_offset ...
!> \param src_offset ...
!> \note see block_partial_copy_a 
! **************************************************************************************************
  SUBROUTINE block_partial_copy_d(dst, dst_rs, dst_cs, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       dst_offset, src_offset)
    REAL(kind=real_8), DIMENSION(:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    INTEGER, INTENT(IN)                      :: src_offset, dst_offset
    LOGICAL                                  :: dst_tr
    REAL(kind=real_8), DIMENSION(:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_d', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop.
!  rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
                = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
         END DO
       END DO
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs) &
              = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
         END DO
       END DO
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
             = src(src_offset+src_c_lb+col+(src_r_lb+row-1)*src_cs)
         END DO
       END DO
    ELSEIF (dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs)&
             = src(src_offset + src_c_lb+col+(src_r_lb+row-1)*src_cs)
         END DO
       END DO
    ENDIF
  END SUBROUTINE block_partial_copy_d

! **************************************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_rs ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param dst_offset ...
!> \note see block_partial_copy_a 
! **************************************************************************************************
  SUBROUTINE block_partial_copy_1d2d_d(dst, dst_rs, dst_cs, dst_tr,&
       src, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       dst_offset)
    REAL(kind=real_8), DIMENSION(:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: dst_rs, dst_cs
    INTEGER, INTENT(IN)                      :: dst_offset
    LOGICAL                                  :: dst_tr
    REAL(kind=real_8), DIMENSION(:,:), &
      INTENT(IN)                             :: src
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_1d2d_d', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
                = src(src_r_lb+row, src_c_lb+col)
         END DO
       END DO
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs) &
              = src(src_r_lb+row, src_c_lb+col)
         END DO
       END DO
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_r_lb+row + (dst_c_lb+col-1)*dst_rs) &
             = src(src_c_lb+col, src_r_lb+row)
         END DO
       END DO
    ELSEIF (dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_offset+dst_c_lb+col + (dst_r_lb+row-1)*dst_cs)&
             = src(src_c_lb+col, src_r_lb+row)
         END DO
       END DO
    ENDIF
  END SUBROUTINE block_partial_copy_1d2d_d
! **************************************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_cs ...
!> \param dst_tr ...
!> \param src ...
!> \param src_rs ...
!> \param src_cs ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \param src_offset ...
!> \note see block_partial_copy_a
! **************************************************************************************************
  SUBROUTINE block_partial_copy_2d1d_d(dst, dst_tr,&
       src, src_rs, src_cs, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol,&
       src_offset)
    REAL(kind=real_8), DIMENSION(:,:), &
      INTENT(INOUT)                          :: dst
    INTEGER, INTENT(IN)                      :: src_offset
    LOGICAL                                  :: dst_tr
    REAL(kind=real_8), DIMENSION(:), &
      INTENT(IN)                             :: src
    INTEGER, INTENT(IN)                      :: src_rs, src_cs
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_2d1d_d', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_r_lb+row, dst_c_lb+col) &
                = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
         END DO
       END DO
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_c_lb+col, dst_r_lb+row) &
              = src(src_offset+src_r_lb+row+(src_c_lb+col-1)*src_rs)
         END DO
       END DO
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_r_lb+row, dst_c_lb+col) &
             = src(src_offset+src_c_lb+col+(src_r_lb+row-1)*src_cs)
         END DO
       END DO
    ELSEIF (dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_c_lb+col, dst_r_lb+row)&
             = src(src_offset + src_c_lb+col+(src_r_lb+row-1)*src_cs)
         END DO
       END DO
    ENDIF
  END SUBROUTINE block_partial_copy_2d1d_d
! **************************************************************************************************
!> \brief Copies a block subset
!> \param dst ...
!> \param dst_tr ...
!> \param src ...
!> \param src_tr ...
!> \param dst_r_lb ...
!> \param dst_c_lb ...
!> \param src_r_lb ...
!> \param src_c_lb ...
!> \param nrow ...
!> \param ncol ...
!> \note see block_partial_copy_a
! **************************************************************************************************
  SUBROUTINE block_partial_copy_2d2d_d(dst, dst_tr,&
       src, src_tr,&
       dst_r_lb, dst_c_lb, src_r_lb, src_c_lb, nrow, ncol)
    REAL(kind=real_8), DIMENSION(:,:), &
      INTENT(INOUT)                          :: dst
    LOGICAL                                  :: dst_tr
    REAL(kind=real_8), DIMENSION(:,:), &
      INTENT(IN)                             :: src
    LOGICAL                                  :: src_tr
    INTEGER, INTENT(IN)                      :: dst_r_lb, dst_c_lb, src_r_lb, &
                                                src_c_lb, nrow, ncol

    CHARACTER(len=*), PARAMETER :: routineN = 'block_partial_copy_2d2d_d', &
      routineP = moduleN//':'//routineN

    INTEGER                                  :: col, row

!   ---------------------------------------------------------------------------
! Factors out the 4 combinations to remove branches from the inner loop. rs is the logical row size so it always remains the leading dimension.
    IF (.NOT. dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_r_lb+row, dst_c_lb+col) &
                = src(src_r_lb+row, src_c_lb+col)
         END DO
       END DO
    ELSEIF (dst_tr .AND. .NOT. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_c_lb+col, dst_r_lb+row) &
              = src(src_r_lb+row, src_c_lb+col)
         END DO
       END DO
    ELSEIF (.NOT. dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_r_lb+row, dst_c_lb+col) &
             = src(src_c_lb+col, src_r_lb+row)
         END DO
       END DO
    ELSEIF (dst_tr .AND. src_tr) THEN
       DO col = 0,ncol-1
         DO row = 0,nrow-1
          dst(dst_c_lb+col, dst_r_lb+row)&
             = src(src_c_lb+col, src_r_lb+row)
         END DO
       END DO
    ENDIF
  END SUBROUTINE block_partial_copy_2d2d_d


! **************************************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output data
!> \param[in] extent_in       input data
!> \param[in] n               number of elements to copy
!> \param[in] out_fe          first element of output
!> \param[in] in_fe           first element of input
! **************************************************************************************************
  PURE SUBROUTINE block_copy_d(extent_out, extent_in, n, out_fe, in_fe)
    INTEGER, INTENT(IN)                           :: n, out_fe, in_fe
    REAL(kind=real_8), DIMENSION(*), INTENT(OUT)  :: extent_out
    REAL(kind=real_8), DIMENSION(*), INTENT(IN)   :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(out_fe : out_fe+n-1) = extent_in(in_fe : in_fe+n-1)
  END SUBROUTINE block_copy_d


! **************************************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_transpose_copy_d(extent_out, extent_in,&
       rows, columns)
    REAL(kind=real_8), DIMENSION(:), INTENT(OUT) :: extent_out
    REAL(kind=real_8), DIMENSION(:), INTENT(IN)  :: extent_in
    INTEGER, INTENT(IN)                :: rows, columns

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(1:rows*columns) = RESHAPE(TRANSPOSE(&
         RESHAPE(extent_in(1:rows*columns), (/rows, columns/))), (/rows*columns/))
  END SUBROUTINE block_transpose_copy_d

! **************************************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_copy_2d1d_d(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(rows,columns), INTENT(OUT) :: extent_out
    REAL(kind=real_8), DIMENSION(:), INTENT(IN)             :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d1d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(extent_in, (/rows, columns/))
  END SUBROUTINE block_copy_2d1d_d

! **************************************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_copy_1d1d_d(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(rows*columns), INTENT(OUT) :: extent_out
    REAL(kind=real_8), DIMENSION(rows*columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_1d1d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(:) = extent_in(:)
  END SUBROUTINE block_copy_1d1d_d

! **************************************************************************************************
!> \brief Copy a block
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_copy_2d2d_d(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(rows,columns), INTENT(OUT) :: extent_out
    REAL(kind=real_8), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d2d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out(:,:) = extent_in(:,:)
  END SUBROUTINE block_copy_2d2d_d


! **************************************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 2-d array
!> \param[in] extent_in       input matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_transpose_copy_2d1d_d(extent_out, extent_in,&
       rows, columns)
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(columns,rows), INTENT(OUT) :: extent_out
    REAL(kind=real_8), DIMENSION(:), INTENT(IN)             :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_2d1d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = TRANSPOSE(RESHAPE(extent_in, (/rows, columns/)))
  END SUBROUTINE block_transpose_copy_2d1d_d

! **************************************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_copy_1d2d_d(extent_out, extent_in,&
       rows, columns)
    REAL(kind=real_8), DIMENSION(:), INTENT(OUT)            :: extent_out
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_copy_1d2d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(extent_in, (/rows*columns/))
  END SUBROUTINE block_copy_1d2d_d


! **************************************************************************************************
!> \brief Copy and transpose block.
!> \param[out] extent_out     output matrix in the form of a 1-d array
!> \param[in] extent_in       input matrix in the form of a 2-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_transpose_copy_1d2d_d(extent_out, extent_in,&
       rows, columns)
    REAL(kind=real_8), DIMENSION(:), INTENT(OUT)            :: extent_out
    INTEGER, INTENT(IN)                           :: rows, columns
    REAL(kind=real_8), DIMENSION(rows,columns), INTENT(IN)  :: extent_in

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_copy_1d2d_d', &
      routineP = moduleN//':'//routineN

!   ---------------------------------------------------------------------------

    extent_out = RESHAPE(TRANSPOSE(extent_in), (/rows*columns/))
  END SUBROUTINE block_transpose_copy_1d2d_d


! **************************************************************************************************
!> \brief In-place block transpose.
!> \param[in,out] extent      Matrix in the form of a 1-d array
!> \param[in] rows input matrix size
!> \param[in] columns input matrix size
! **************************************************************************************************
  PURE SUBROUTINE block_transpose_inplace_d(extent, rows, columns)
    INTEGER, INTENT(IN)                      :: rows, columns
    REAL(kind=real_8), DIMENSION(rows*columns), &
      INTENT(INOUT)                          :: extent
    REAL(kind=real_8), DIMENSION(rows*columns)         :: extent_tr

    CHARACTER(len=*), PARAMETER :: routineN = 'block_transpose_inplace_d', &
      routineP = moduleN//':'//routineN

    INTEGER :: r, c
!   ---------------------------------------------------------------------------

    DO r = 1 , columns
      DO c = 1 , rows
       extent_tr(r + (c-1)*columns) = extent(c + (r-1)*rows)
      END DO
    END DO
    DO r = 1 , columns
      DO c = 1 , rows
       extent(r + (c-1)*columns) = extent_tr(r + (c-1)*columns)
      END DO
    END DO
  END SUBROUTINE block_transpose_inplace_d


! **************************************************************************************************
!> \brief Copy data from a double real array to a data area
!>
!> There are no checks done for correctness!
!> \param[in] dst        destination data area
!> \param[in] lb         lower bound for destination (and source if
!>                       not given explicity)
!> \param[in] data_size  number of elements to copy
!> \param[in] src        source data array
!> \param[in] source_lb  (optional) lower bound of source
! **************************************************************************************************
  SUBROUTINE dbcsr_data_set_ad (dst, lb, data_size, src, source_lb)
    TYPE(dbcsr_data_obj), INTENT(INOUT)      :: dst
    INTEGER, INTENT(IN)                      :: lb, data_size
    REAL(kind=real_8), DIMENSION(:), INTENT(IN)        :: src
    INTEGER, INTENT(IN), OPTIONAL            :: source_lb
    CHARACTER(len=*), PARAMETER :: routineN = 'dbcsr_data_set_ad', &
         routineP = moduleN//':'//routineN
    INTEGER                                  :: lb_s, ub, ub_s
!   ---------------------------------------------------------------------------
    IF (debug_mod) THEN
       IF(.NOT.ASSOCIATED (dst%d))&
          CPABORT("Target data area must be setup.")
       IF(SIZE(src) .LT. data_size)&
          CPABORT("Not enough source data.")
       IF(dst%d%data_type .NE. dbcsr_type_real_8)&
          CPABORT("Data type mismatch.")
    ENDIF
    ub = lb + data_size - 1
    IF (PRESENT (source_lb)) THEN
       lb_s = source_lb
       ub_s = source_lb + data_size-1
    ELSE
       lb_s = lb
       ub_s = ub
    ENDIF
    CALL memory_copy(dst%d%r_dp(lb:ub),src(lb_s:ub_s),data_size)
  END SUBROUTINE dbcsr_data_set_ad

! **************************************************************************************************
!> \brief ...
!> \param block_a ...
!> \param block_b ...
!> \param len ...
! **************************************************************************************************
  PURE SUBROUTINE block_add_d(block_a, block_b, len)
    INTEGER, INTENT(IN)                    :: len
    REAL(kind=real_8), DIMENSION(len), INTENT(INOUT) :: block_a
    REAL(kind=real_8), DIMENSION(len), INTENT(IN)    :: block_b
    block_a(1:len) = block_a(1:len) + block_b(1:len)
  END SUBROUTINE block_add_d
