      MODULE symt_I   
      INTERFACE
!...Generated by Pacific-Sierra Research 77to90  4.4G  11:05:03  03/09/06  
      SUBROUTINE symt (H, DELDIP, HA) 
      USE vast_kind_param,ONLY: DOUBLE 
      REAL(DOUBLE), DIMENSION(*), INTENT(INOUT) :: H 
      REAL(DOUBLE), DIMENSION(3,*), INTENT(INOUT) :: DELDIP 
      REAL(DOUBLE), DIMENSION(*), INTENT(INOUT) :: HA 
      END SUBROUTINE  
      END INTERFACE 
      END MODULE 
