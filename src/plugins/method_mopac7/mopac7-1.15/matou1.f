      SUBROUTINE MATOU1(A,B,NCX,NR,NDIM,IFLAG)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      PARAMETER (MXDIM=MAXPAR+NUMATM)
C     PARAMETER (MAXDIM=MAX(MAXORB,3*NUMATM))
C ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
C     MAXORB = 4*60+60 = 300		; see the SIZES-file...
C     3*NUMATM = 3*(60+60) = 360	; see the SIZES-file...
      PARAMETER (MAXDIM=600)
C ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      DIMENSION A(NR,NR),B(NDIM)
      COMMON /MOLKST/ NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1                NLAST(NUMATM), NORBS, NELECS,NALPHA,NBETA,
     2                NCLOSE,NOPEN,NDUMY,FRACT
      COMMON /ELEMTS/ ELEMNT(107)
      COMMON/SYMRES/ TRANS,RTR,SIG,NAME,NAMO(MXDIM),JNDEX(MXDIM),ISTA(2)
      COMMON /KEYWRD/ KEYWRD
      COMMON /OUTFIL/ WU
      INTEGER WU
      CHARACTER*241 KEYWRD, NAME*4, NAMO*4, ISTA*4
      LOGICAL ALLPRT
C**********************************************************************
C
C      MATOUT PRINTS A SQUARE MATRIX OF EIGENVECTORS AND EIGENVALUES
C
C    ON INPUT A CONTAINS THE MATRIX TO BE PRINTED.
C             B CONTAINS THE EIGENVALUES.
C             NC NUMBER OF MOLECULAR ORBITALS TO BE PRINTED.
C             NR IS THE SIZE OF THE SQUARE ARRAY TO BE PRINTED.
C             NDIM IS THE ACTUAL SIZE OF THE SQUARE ARRAY "A".
C             NFIRST AND NLAST CONTAIN ATOM ORBITAL COUNTERS.
C             NAT = ARRAY OF ATOMIC NUMBERS OF ATOMS.
C
C
C     OUTPUT TYPE (ROW LABELING)
C       IFLAG=1 : ORBITALS
C       IFLAG=2 : ORBITALS + SYMMETRY-DESIGNATORS
C       IFLAG=3 : ATOMS
C       IFLAG=4 : NUMBERS ONLY
C       IFLAG=5 : VIBRATIONS + SYMMETRY-DESIGNATIONS
C
C
C***********************************************************************
      CHARACTER*2 ELEMNT, ATORBS(9), ITEXT(MAXDIM), JTEXT(MAXDIM),XYZ(3)
      DIMENSION NATOM(MAXDIM)
      DATA XYZ/' x',' y',' z'/
      DATA ATORBS/'S ','Px','Py','Pz','x2','xz','z2','yz','xz'/
C      -------------------------------------------------
      ALLPRT=(INDEX(KEYWRD,'ALLVEC').NE.0)
      IF(IFLAG.GT.2.AND.IFLAG.NE.5) GO TO 30
      NC=NCX
      IF(ALLPRT) GO TO 1988
      NSAVE=NCX
      NFIX=MAX(NALPHA,NCLOSE)
      IF(IFLAG.EQ.2.AND.NC.GT.16) NC=NFIX+7
      IF(NC.GT.NSAVE) NC=NSAVE
 1988 CONTINUE
      IF(NUMAT.EQ.0)  GOTO 30
      IF(NLAST(NUMAT).NE.NR) GOTO 30
      DO 20 I=1,NUMAT
         JLO=NFIRST(I)
         JHI=NLAST(I)
         L=NAT(I)
         K=0
         IF(IFLAG.LE.2) THEN
         DO 10 J=JLO,JHI
            K=K+1
            ITEXT(J)=ATORBS(K)
            JTEXT(J)=ELEMNT(L)
            NATOM(J)=I
   10    CONTINUE
         ELSE
        JHI=3*(I-1)
        DO  15  J=1,3
        K=K+1
        ITEXT(J+JHI)=XYZ(J)
        JTEXT(J+JHI)=ELEMNT(L)
  15    NATOM(J+JHI)=I
      ENDIF
   20 CONTINUE
      GOTO 50
   30 CONTINUE
      NR=ABS(NR)
      DO  40 I=1,NR
      ITEXT(I)='  '
      JTEXT(I)='  '
      IF(IFLAG.EQ.3) JTEXT(I)=ELEMNT(NAT(I))
  40  NATOM(I)=I
   50 CONTINUE
      KA=1
      KC=8
      IF(ALLPRT) GO TO 1989
      IF(IFLAG.EQ.2.AND.NORBS.GT.16) KA=NFIX-8
      IF(KA.LT.1) KA=1
      IF(IFLAG.EQ.2.AND.NORBS.GT.16) KC=KA+7
 1989 CONTINUE
   60 KB=MIN0(KC,NC)
      WRITE(WU,100) (I,I=KA,KB)
      IF  (IFLAG.EQ.2.OR.IFLAG.EQ.5)
     *   WRITE(WU,150) (JNDEX(I),NAMO(I),I=KA,KB)
      IF(B(1).NE.0.D0) THEN
      IF(IFLAG.EQ.5) THEN
      WRITE(WU,111) (B(I),I=KA,KB)
      ELSE
      WRITE(WU,110) (B(I),I=KA,KB)
      ENDIF
      ENDIF
      WRITE(WU,120)
      LA=1
      LC=40
   70 LB=MIN0(LC,NR)
      DO 80 I=LA,LB
         IF(ITEXT(I).EQ.' S')WRITE(WU,120)
         WRITE(WU,130) ITEXT(I),JTEXT(I),NATOM(I),(A(I,J),J=KA,KB)
   80 CONTINUE
      IF (LB.EQ.NR) GO TO 90
      LA=LC+1
      LC=LC+40
      GO TO 70
  90  IF (KB.EQ.NC) RETURN
      KA=KC+1
      KC=KC+8
      GO TO 60
  100 FORMAT (//,2X,9H Root No.,I5,9I8)
  110 FORMAT (/10X,10F8.3)
  111 FORMAT (/10x,10f8.1)
  120 FORMAT (2H  )
  130 FORMAT (1H ,2(1X,A2),I3,F8.4,10F8.4)
 150  FORMAT(/12X,10(I3,1X,A4))
      END
