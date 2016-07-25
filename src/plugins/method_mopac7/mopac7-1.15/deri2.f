      SUBROUTINE DERI2(C,E,NORBS, MINEAR, F, FD, FCI, NINEAR,
     1NVAR,WORK,B,NW2,GRAD,AB,NW3,FB,THROLD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      DIMENSION C(NORBS,NORBS),E(NORBS),WORK(NORBS,NORBS)
     1         ,F(MINEAR,MPACK/MINEAR)
     2         ,FD(NINEAR,(5*MAXPAR+MPACK)/NINEAR)
     3         ,FCI(NINEAR,MAXORB/NINEAR)
     4         ,B(MINEAR,(6*MPACK-5*MAXPAR)/MINEAR)
     5         ,AB(MINEAR,6*MPACK/MINEAR),FB(NVAR,6*MPACK/NVAR)
     6         ,GRAD(NVAR)
*********************************************************************
*
*     DERI2 COMPUTE THE RELAXATION PART OF THE DERIVATIVES OF THE
*     NON-VARIATIONALLY OPTIMIZED ENERGY WITH RESPECT TO TWO
*     COORDINATES AT A TIME. THIS IS DONE IN THREE STEPS.
*
*     THE M.O DERIVATIVES ARE SOLUTION {X} OF A LINEAR SYSTEM
*                        (D-A) * X = F
*     WHERE D IS A DIAGONAL SUPER-MATRIX OF FOCK EIGENVALUE DIFFERENCES
*     AND A IS A SUPER-MATRIX OF 2-ELECTRONS INTEGRALS IN M.O BASIS.
*     SUCH A SYSTEM IS TOO LARGE TO BE INVERTED DIRECTLY THUS ONE MUST
*     USES A RELAXATION METHOD TO GET A REASONABLE ESTIMATE OF {X}.
*     THIS REQUIRES A BASIS SET {B} TO BE GENERATED ITERATIVELY, AFTER
*     WHICH WE SOLVE BY DIRECT INVERSION THE LINEAR SYSTEM PROJECTED
*     IN THIS BASIS {B}. IT WORKS QUICKLY BUT DOES REQUIRE A LARGE
*     CORE MEMORY.
*
*     USE A FORMALISM WITH FOCK OPERATOR THUS AVOIDING THE EXPLICIT
*     COMPUTATION (AND STORAGE) OF THE SUPER-MATRIX A.
*     THE SEMIEMPIRICAL METHODS DO NOT INVOLVE LARGE C.I CALCULATIONS.
*     THEREFORE FOR EACH GRADIENT COMPONENT WE BUILD THE C.I MATRIX
*     DERIVATIVE FROM THE M.O. INTEGRALS <IJ|KL> AND FOCK EIGENVALUES
*     DERIVATIVES, THUS PROVIDING THE RELAXATION CONTRIBUTION TO THE
*     GRADIENT WITHOUT COMPUTATION AND STORAGE OF THE 2ND ORDER DENSITY
*     MATRIX.
*
*   STEP 1)
*     USE THE PREVIOUS B AND THE NEW F VECTORS TO BUILD AN INITIAL
*     BASIS SET B.
*   STEP 2)
*     BECAUSE THE ELECTRONIC HESSIAN (D-A) IS THE SAME FOR EACH
*     DERIVATIVE, WE ONLY NEED TO ENLARGE ITERATIVELY THE ORTHONORMAL
*     BASIS SET {B} USED TO INVERT THE PROJECTED HESSIAN.
*     (DERIVED FROM THE LARGEST RESIDUAL VECTOR ).
*     THIS SECTION IS CARRIED OUT IN THE DIAGONAL METRIC 'SCALAR'.
*   STEP 3) ... LOOP ON THE GEOMETRIC VARIABLE :
* 3.1 FOR EACH GEOMETRIC VARIABLE, GET THE M.O DERIVATIVES IN A.O.
* 3.2 COMPUTE THE FOCK EIGENVALUES AND 2-ELECTRON INTEGRAL RELAXATION.
* 3.3 BUILD THE ELECTRONIC RELAXATION CONTRIBUTION TO THE C.I MATRIX
*     AND GET THE ASSOCIATED EIGENSTATE DERIVATIVE WITH RESPECT TO
*     THE GEOMETRIC VARIABLE.
*
*   INPUT
*     C(NORBS,NORBS) : M.O. COEFFICIENTS, IN COLUMN.
*     E(NORBS)       : EIGENVALUES OF THE FOCK MATRIX.
*     MINEAR         : NUMBER OF NON REDUNDANT ROTATION OF THE M.O.
*     F(MINEAR,NVAR) : NON-RELAXED FOCK MATRICES DERIVATIVES
*                    IN M.O BASIS, OFF-DIAGONAL BLOCKS.
*     FD(NINEAR,NVAR): IDEM, DIAGONAL BLOCKS, C.I-ACTIVE ONLY.
*     WORK           : WORK ARRAY OF SIZE N*N.
*     B(MINEAR,NBSIZE) : INITIAL ORTHONORMALIZED BASIS SET {B}.
*     GRAD(NVAR)     : GRADIENT VECTOR BEFORE RELAXATION CORRECTION.
*     AB(MINEAR,*): STORAGE FOR THE (D-A) * B VECTORS.
*     FB(NVAR,*)  : STORAGE FOR THE MATRIX PRODUCT F' * B.
*   OUTPUT
*     GRAD   : DERIVATIVE OF THE HEAT OF FORMATION WITH RESPECT TO
*              THE NVAR OPTIMIZED VARIABLES.
*
************************************************************************
      COMMON /FOKMAT/ FDUMY(MPACK), SCALAR(MPACK)
      COMMON /NVOMAT/ DIAG(MPACK/2)
     1       /WORK3 / DIJKL(MPACK*4)
     2       /XYIJKL/ XY(NMECI,NMECI,NMECI,NMECI)
     3       /CIVECT/ VECTCI(NMECI**2),BABINV(NMECI**3),
     4BCOEF(NMECI**4-NMECI**3+1)
     5       /KEYWRD/ KEYWRD
      COMMON /CIBITS/ NMOS,LAB,NELEC,NBO(3)
      COMMON /WORK2 / BAB(MMCI,MMCI),
     +DUMY(NMECI**4+2*NMECI**3+NMECI**2-MMCI*MMCI)
      COMMON /NUMCAL/ NUMCAL
      COMMON /OUTFIL/ WU
      INTEGER WU
      DIMENSION LCONV(MMCI)
      LOGICAL FAIL, LCONV, DEBUG, LBAB
      CHARACTER KEYWRD*241
      DATA ICALCN/0/
C
C     * * * STEP 1 * * *
C     BUILD UP THE INITIAL ORTHONORMALIZED BASIS.
C
      IF(ICALCN.NE.NUMCAL) THEN
         DEBUG=INDEX(KEYWRD,' DERI2').NE.0
         ICALCN=NUMCAL
         MAXITE=MIN(MMCI,INT(SQRT(NMECI**3.D0)),MPACK*2/NVAR)
         MAXITE=MIN(MAXITE,MIN(NW2,NW3)/MAX(MINEAR,NINEAR))
         NFIRST=MIN(NVAR,1+MAXITE/4)
      ENDIF
      FAIL=.FALSE.
      NBSIZE=0
      TIME1=SECOND()
C
C        NORMAL CASE. USE F ONLY.
C
      CALL DERI21 (F,NVAR,MINEAR,NFIRST,WORK
     1               ,WORK(NVAR*NVAR+1,1),B,NLAST)
      LBAB=.FALSE.
      NFIRST=NBSIZE+1
      NLAST=NBSIZE+NLAST
      DO 10 I=1,NVAR
   10 LCONV(I)=.FALSE.
C
C     * * * STEP 2 * * *
C     RELAXATION METHOD WITH OPTIMUM INCREASE OF THE BASIS SET.
C     ---------------------------------------------------------
C
C     UPDATE AB ,FCI AND BAB. (BAB IS SYMMETRIC)
   20 DO 30 J=NFIRST,NLAST
         CALL DERI22(C,B(1,J),WORK,NORBS,WORK,AB(1,J),MINEAR,
     1            FCI(1,J))
         CALL MXM(AB(1,J),1,B,MINEAR,BAB(1,J),NLAST)
         DO 30 I=1,NFIRST-1
   30 BAB(J,I)=BAB(I,J)
C     INVERT BAB, STORE IN BABINV.
   40 L=0
      DO 50 J=1,NLAST
         DO 50 I=1,NLAST
            L=L+1
   50 BABINV(L)=BAB(I,J)
      CALL OSINV (BABINV,NLAST,DETER)
      IF (DETER.EQ.0) THEN
      IF(NLAST.NE.1)THEN
         WRITE(WU,'('' THE BAB MATRIX OF ORDER'',I3,
     1   '' IS SINGULAR IN DERI2''/
     2   '' THE RELAXATION IS STOPPED AT THIS POINT.'')')NLAST
         ENDIF
         LBAB=.TRUE.
         NLAST=NLAST-1
         GO TO 40
      ENDIF
      IF (.NOT.LBAB) THEN
C        UPDATE F * B'
         CALL MTXM (F,NVAR,B(1,NFIRST),MINEAR,FB(1,NFIRST),NLAST-NFIRST+
     11)
      ENDIF
C     NEW SOLUTIONS IN BASIS B , STORED IN BCOEF(NVAR,*).
C     BCOEF = BABINV * FB'
      IF(NLAST.NE.0)CALL MXMT (BABINV,NLAST,FB,NLAST,BCOEF,NVAR)
      IF(LBAB) GO TO 90
C
C     SELECT THE NEXT BASIS VECTOR AS THE LARGEST RESIDUAL VECTOR.
C     AND TEST FOR CONVERGENCE ON THE LARGEST RESIDUE.
      NRES=0
      TEST2=0.D0
      DO 70 IVAR=1,NVAR
         IF(LCONV(IVAR)) GO TO 70
C     GET ONE NOT-CONVERGED RESIDUAL VECTOR (# IVAR),
C     STORED IN WORK.
         CALL MXM  (AB,MINEAR,BCOEF(NLAST*(IVAR-1)+1),NLAST,WORK,1)
         TEST=0.D0
         DO 60 I=1,MINEAR
            WORK(I,1)=F(I,IVAR)-WORK(I,1)
   60    TEST=MAX(ABS(WORK(I,1)),TEST)
         IF(DEBUG)WRITE(WU,*)' TEST:',TEST
         TEST2=MAX(TEST2,TEST)
         IF (TEST.LE.THROLD) THEN
            LCONV(IVAR)=.TRUE.
            IF(NVAR.EQ.1) GOTO 90
            GO TO 70
         ELSEIF (NLAST+NRES.EQ.MAXITE-1) THEN
C        RUNNING OUT OF STORAGE
            IF (TEST.LE.MAX(0.01D0,THROLD*2)) THEN
               LCONV(IVAR)=.TRUE.
               GO TO 70
            ENDIF
         ELSE IF (NLAST+NRES.EQ.MAXITE) THEN
C
C   COMPLETELY OUT OF STORAGE
C
            FAIL=NRES.EQ.0
            GO TO 80
         ELSE
C        STORE THE FOLLOWING RESIDUE IN AB(CONTINUED).
            NRES=NRES+1
            CALL SCOPY (MINEAR,WORK,1,AB(1,NLAST+NRES),1)
         ENDIF
   70 CONTINUE
   80 IF (NRES.EQ.0) GO TO 90
C     FIND OPTIMUM FOLLOWING SUBSET, ADD TO B AND LOOP.
      NFIRST=NLAST+1
      CALL DERI21(AB(1,NFIRST),NRES,MINEAR,NRES,WORK
     1           ,WORK(NRES*NRES+1,1),B(1,NFIRST),NADD)
      NLAST=NLAST+NADD
      GO TO 20
C
C     CONVERGENCE ACHIEVED OR HALTED.
C     -------------------------------
C
   90 NBSZE=NBSIZE
      IF(DEBUG.OR.LBAB) THEN
         WRITE(WU,'('' RELAXATION ENDED IN DERI2 AFTER'',I3,
     1   '' CYCLES''/'' REQUIRED CONVERGENCE THRESHOLD ON RESIDUALS =''
     2   ,F12.9/'' HIGHEST RESIDUAL ON'',I3,'' GRADIENT COMPONENTS = ''
     3   ,F12.9)')NLAST-NBSZE,THROLD,NVAR,TEST2
      IF(NLAST-NBSZE.EQ.0)THEN
      WRITE(WU,'(A)')
     +' ANALYTIC C.I. DERIVATIVES DO NOT WORK FOR THIS SYSTEM'
      WRITE(WU,'(A)')' ADD KEYWORD ''NOANCI'' AND RESUBMIT'
      STOP
      ENDIF
         TIME2=SECOND()
         WRITE(WU,'('' ELAPSED TIME IN RELAXATION'',F15.3,'' SECOND'')
     1              ')TIME2-TIME1
      ENDIF
      IF(FAIL) THEN
        WRITE(WU,'(A)')' ANALYTICAL DERIVATIVES TOO INACCURATE FOR THIS'
        WRITE(WU,'(A)')' WORK.  JOB STOPPED HERE.  SEE MANUAL FOR IDEAS'
         STOP
      ELSE
         NBSIZE=0
C        UNSCALED SOLUTION SUPERVECTORS, STORED IN F.
         IF(NLAST.NE.0)CALL MXM (B,MINEAR,BCOEF,NLAST,F,NVAR)
         DO 100 J=1,NVAR
            DO 100 I=1,MINEAR
  100    F(I,J)=F(I,J)*SCALAR(I)
C        FOCK MATRIX DIAGONAL BLOCKS OVER C.I-ACTIVE M.O.
C        STORED IN FB.
         IF(NLAST.NE.0)CALL MXM (FCI,NINEAR,BCOEF,NLAST,FB,NVAR)
      ENDIF
C
C     * * * STEP 3 * * *
C     FINAL LOOP (390) ON THE GEOMETRIC VARIABLES.
C     --------------------------------------------
C
      DO 130 IVAR=1,NVAR
C
C     C.I-ACTIVE M.O DERIVATIVES INTO THE M.O BASIS,
C         RETURNED IN AB (N,NELEC+1,...,NELEC+NMOS).
C     C.I-ACTIVE EIGENVALUES DERIVATIVES,
C         RETURNED IN BCOEF(NELEC+1,...,NELEC+NMOS).
         CALL DERI23 (F(1,IVAR),FD(1,IVAR),E
     1            ,FB(NINEAR*(IVAR-1)+1,1),AB,BCOEF,NORBS)
C
C     DERIVATIVES OF THE 2-ELECTRONS INTEGRALS OVER C.I-ACTIVE M.O.
C     STORED IN /XYIJKL/.
         CALL DIJKL2 (AB(NORBS*NELEC+1,1),NORBS,NMOS,DIJKL,XY,NMECI)
         IF(DEBUG) THEN
            WRITE(WU,'('' * * * GRADIENT COMPONENT NUMBER'',I4)')IVAR
            IF(INDEX(KEYWRD,'DEBU').NE.0) THEN
              WRITE(WU,'('' C.I-ACTIVE M.O. DERIVATIVES IN M.O BASIS'',
     1                   '', IN ROW.'')')
               L=NORBS*NELEC+1
               DO 110 I=NELEC+1,NELEC+NMOS
                  WRITE(WU,'(8F10.4)')(AB(K,1),K=L,L+NORBS-1)
  110          L=L+NORBS
            ENDIF
           WRITE(WU,'('' C.I-ACTIVE FOCK EIGENVALUES RELAXATION (E.V.)''
     1               )')
            WRITE(WU,'(8F10.4)')(BCOEF(I),I=NELEC+1,NELEC+NMOS)
            WRITE(WU,'('' 2-ELECTRON INTEGRALS RELAXATION (E.V.)''/
     1''    I    J    K    L       d<I(1)J(1)|K(2)L(2)> RELAXATION ONLY'
     2')
     3')
            DO 120 I=1,NMOS
               DO 120 J=1,I
                  DO 120 K=1,I
                     LL=K
                     IF(K.EQ.I) LL=J
                     DO 120 L=1,LL
  120       WRITE(WU,'(4I5,F20.10)')
     1              NELEC+I,NELEC+J,NELEC+K,NELEC+L,XY(I,J,K,L)
         ENDIF
C
C     BUILD THE C.I MATRIX DERIVATIVE, STORED IN AB.
         CALL MECID (BCOEF,GSE,WORK(LAB+1,1),WORK)
         CALL MECIH (WORK,AB,NMOS,LAB)
C     RELAXATION CORRECTION TO THE C.I ENERGY DERIVATIVE.
         CALL SUPDOT (WORK,AB,VECTCI,LAB,1)
         GRAD(IVAR)=GRAD(IVAR)+DOT(VECTCI,WORK,LAB)*23.061D0
         IF (DEBUG) THEN
            WRITE(WU,'('' RELAXATION OF THE GRADIENT COMPONENT'',F10.4,
     1'' KCAL/MOLE'')')  DOT(VECTCI,WORK,LAB)*23.061D0
         ENDIF
C
C     THE END .
  130 CONTINUE
      IF(DEBUG)
     1WRITE(WU,'('' ELAPSED TIME IN C.I-ENERGY RELAXATION'',F15.3,
     2             '' SECOND'')')SECOND()-TIME2
      RETURN
      END
