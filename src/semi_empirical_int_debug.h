!-----------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations         !
!   Copyright (C) 2000 - 2008  CP2K developers group                          !
!-----------------------------------------------------------------------------!

! *****************************************************************************
!> \brief Debug the derivatives of the the rotational matrices
!>
!> \author Teodoro Laino [tlaino] - University of Zurich
!> \date 04.2008 [tlaino]
! *****************************************************************************
INTERFACE check_rotmat_der
   SUBROUTINE check_rotmat_der( sepi, sepj, rjiv, ij_matrix, do_invert, error)
     USE f77_blas
     USE kinds,                           ONLY: dp
     USE semi_empirical_types,            ONLY: rotmat_type,&
                                                semi_empirical_type
#include "cp_common_uses.h"
     IMPLICIT NONE
     TYPE(semi_empirical_type), POINTER       :: sepi, sepj
     REAL(KIND=dp), DIMENSION(3), INTENT(IN)  :: rjiv
     TYPE(rotmat_type), POINTER               :: ij_matrix
     LOGICAL, INTENT(IN)                      :: do_invert
     TYPE(cp_error_type), INTENT(inout)       :: error
   END SUBROUTINE check_rotmat_der
END INTERFACE check_rotmat_der

! *****************************************************************************
!> \brief Check Numerical Vs Analytical NUCINT
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE check_dnucint_ana
  SUBROUTINE check_dnucint_ana (sepi,sepj,r,dssss,dcore,itype,shortrange,taper,error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type  
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(dp), INTENT(IN)                     :: r
    REAL(dp), INTENT(IN), OPTIONAL           :: dssss
    REAL(dp), DIMENSION(10, 2), INTENT(IN),&
         OPTIONAL                            :: dcore
    INTEGER, INTENT(IN)                      :: itype
    LOGICAL, INTENT(IN)                      :: shortrange
    TYPE(taper_type), POINTER                :: taper
    TYPE(cp_error_type), INTENT(inout)       :: error
  END SUBROUTINE check_dnucint_ana
END INTERFACE check_dnucint_ana

! *****************************************************************************
!> \brief Check Numerical Vs Analytical ROTNUC
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE check_drotnuc_ana
   SUBROUTINE check_drotnuc_ana(sepi, sepj, rijv, itype, shortrange, taper, e1b, e2a, de1b, de2a, error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(dp), DIMENSION(3), INTENT(IN)       :: rijv
    INTEGER, INTENT(IN)                      :: itype
    LOGICAL, INTENT(IN)                      :: shortrange
    TYPE(taper_type), POINTER                :: taper
    REAL(dp), DIMENSION(45), INTENT(IN), &
      OPTIONAL                               :: e1b, e2a
    REAL(dp), DIMENSION(45, 3), &
      INTENT(IN), OPTIONAL                  :: de1b, de2a
    TYPE(cp_error_type), INTENT(inout)       :: error
   END SUBROUTINE check_drotnuc_ana
END INTERFACE check_drotnuc_ana

! *****************************************************************************
!> \brief Check Numerical Vs Analytical CORECORE
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE check_dcorecore_ana
  SUBROUTINE check_dcorecore_ana(sepi, sepj, rijv, itype,shortrange, taper, enuc, denuc, error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(dp), DIMENSION(3), INTENT(IN)       :: rijv
    INTEGER, INTENT(IN)                      :: itype
    REAL(dp), INTENT(IN), OPTIONAL           :: enuc
    REAL(dp), DIMENSION(3), INTENT(IN), &
         OPTIONAL                            :: denuc
    LOGICAL, INTENT(IN)                      :: shortrange
    TYPE(taper_type), POINTER                :: taper
    TYPE(cp_error_type), INTENT(inout)       :: error
  END SUBROUTINE check_dcorecore_ana

END INTERFACE check_dcorecore_ana

! *****************************************************************************
!> \brief Check Numerical Vs Analytical rot_2el_2c_first
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE rot_2el_2c_first_debug
  SUBROUTINE rot_2el_2c_first_debug(sepi, sepj, rijv, shortrange, taper, invert, ii, kk, v_d, error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(KIND=dp), DIMENSION(3), INTENT(IN)  :: rijv
    LOGICAL, INTENT(IN)                      :: shortrange, invert
    TYPE(taper_type), POINTER                :: taper
    INTEGER, INTENT(IN)                      :: ii, kk
    REAL(KIND=dp), DIMENSION(45, 45, 3), &
      INTENT(IN)                             :: v_d
    TYPE(cp_error_type), INTENT(inout)       :: error
  END SUBROUTINE rot_2el_2c_first_debug
END INTERFACE rot_2el_2c_first_debug

! *****************************************************************************
!> \brief Check Numerical Vs Analytical check_dterep_ana
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE check_dterep_ana
  SUBROUTINE check_dterep_ana (sepi,sepj,r,ri,dri,shortrange,taper,error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(dp), INTENT(IN)                     :: r
    REAL(dp), DIMENSION(491), INTENT(IN)     :: ri, dri
    LOGICAL, INTENT(IN)                      :: shortrange
    TYPE(taper_type), POINTER                :: taper
    TYPE(cp_error_type), INTENT(inout)       :: error
  END SUBROUTINE check_dterep_ana
END INTERFACE check_dterep_ana

! *****************************************************************************
!> \brief Check Numerical Vs Analytical check_rotint_ana
!> \note
!>      Debug routine
!> \par History
!>      04.2008 created [tlaino]
!> \author Teodoro Laino - Zurich University
! *****************************************************************************
INTERFACE check_rotint_ana
  SUBROUTINE check_rotint_ana(sepi,sepj,rijv,w,dw,shortrange,taper,error)
    USE f77_blas
    USE kinds,                           ONLY: dp
    USE semi_empirical_types,            ONLY: semi_empirical_type,&
                                               taper_type
#include "cp_common_uses.h"
    IMPLICIT NONE
    TYPE(semi_empirical_type), POINTER       :: sepi, sepj
    REAL(dp), DIMENSION(3), INTENT(IN)       :: rijv
    REAL(dp), DIMENSION(2025), INTENT(IN), &
      OPTIONAL                               :: w
    REAL(dp), DIMENSION(2025, 3), &
      INTENT(IN), OPTIONAL                   :: dw
    LOGICAL, INTENT(IN)                      :: shortrange
    TYPE(taper_type), POINTER                :: taper
    TYPE(cp_error_type), INTENT(inout)       :: error
  END SUBROUTINE check_rotint_ana
END INTERFACE check_rotint_ana
