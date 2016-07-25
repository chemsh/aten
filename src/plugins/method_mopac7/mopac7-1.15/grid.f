      SUBROUTINE GRID
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
************************************************************************
*
*  GRID CALCULATES THE ENERGY-SURFACE RESULTING FROM VARIATION OF
*       TWO COORDINATES. THE STEP-SIZE IS STEP1 AND STEP2, AND A 11
*       BY 11 GRID OF POINTS IS GENERATED
*
* 	This subroutine is extensively modified by Manyin Yi, Aug 1989.
*
* 	New features:
*      1. The input geometry definition should always be the upper-left
*	   corner(smallest coordinates) instead of the middle point;
*	2. The starting point for calculation can be one of the four
*	   corners by setting "+/-" STEP1/2;
*	3. The grid size(max 23*23) is controlled by POINT1/2,
*	   if POINT1/2 is omitted, then a size of 11*11 is assumed;
*	   kwd MAX sets the max size;
*	4. The upper-left corner of the plotting grid always corresponds
*	   to the smallest coordinates, the lower-right corner to the
*	   largest, no matter where the calculation starts;
*	5. Restartable.
*       6. Write out UNIMAP irregular data UMP.DAT
*
************************************************************************
      COMMON /GEOM  / GEO(3,NUMATM), XCOORD(3,NUMATM)
      COMMON /GEOVAR/ NVAR,LOC(2,MAXPAR), IDUMY, XPARAM(MAXPAR)
      COMMON /GRADNT/ GRAD(MAXPAR),GNORM
      COMMON /GRAVEC/ COSINE
      COMMON /MESH  / LATOM1, LPARA1, LATOM2, LPARA2
      COMMON /GPARAM/ CURRT1,CURRT2
      COMMON /IJLP  / IJLP, ILP, JLP, JLP1, IONE
      COMMON /SURF  / SURF
      COMMON /KEYWRD/ KEYWRD
      COMMON /TITLES/ KOMENT, TITLE
      COMMON /OUTFIL/ WU
      INTEGER WU
      CHARACTER KEYWRD*241, KOMENT*81, TITLE*81, GETNAM*80
      LOGICAL RESTRT
      DIMENSION GD(MAXPAR),XLAST(MAXPAR),MDFP(20),XDFP(20)
      DIMENSION SURFAC(23,23)
      DIMENSION SURF(23*23)
      DIMENSION UMPX(23),UMPY(23),UMPZ(23*23)
C
      STEP1=READA(KEYWRD,INDEX(KEYWRD,'STEP1')+6)
      STEP2=READA(KEYWRD,INDEX(KEYWRD,'STEP2')+6)
      NPTS1=11
      NPTS2=11
      IF (INDEX(KEYWRD,' MAX').NE.0) THEN
         NPTS1=23
         NPTS2=23
         GOTO 10
      ENDIF
      IF (INDEX(KEYWRD,'POINT1').NE.0)
     1 NPTS1=ABS(READA(KEYWRD,INDEX(KEYWRD,'POINT1')+7))
      IF (INDEX(KEYWRD,'POINT2').NE.0)
     1 NPTS2=ABS(READA(KEYWRD,INDEX(KEYWRD,'POINT2')+7))
   10 RESTRT=(INDEX(KEYWRD,'RESTART').NE.0)
C
C  THE TOP-LEFT VALUE OF THE FIRST AND SECOND DIMENSIONS ARE
C      GEO(LPARA1,LATOM1) AND GEO(LPARA2,LATOM2)
C
      UMPY(1)=GEO(LPARA1,LATOM1)
      UMPX(1)=GEO(LPARA2,LATOM2)
      DEGREE=180.D0/3.14159265359D0
      IF(LPARA1.NE.1)STEP1=STEP1/DEGREE
      IF(LPARA2.NE.1)STEP2=STEP2/DEGREE
C
C  NOW SET THE STARTING POINT TO THE DESIRED CORNER
C
      IF(STEP1.GT.0.0.AND.STEP2.GT.0.0) THEN
         START1=GEO(LPARA1,LATOM1)
         START2=GEO(LPARA2,LATOM2)
      ENDIF
C BOTTOM-LEFT
      IF(STEP1.LT.0.0.AND.STEP2.GT.0.0)THEN
         START1=GEO(LPARA1,LATOM1)+(NPTS1-1)*(ABS(STEP1))
         START2=GEO(LPARA2,LATOM2)
      ENDIF
C TOP-RIGHT
      IF(STEP1.GT.0.0.AND.STEP2.LT.0.0)THEN
         START1=GEO(LPARA1,LATOM1)
         START2=GEO(LPARA2,LATOM2)+ABS((NPTS2-1)*STEP2)
      ENDIF
C BOTTOM-RIGHT
      IF(STEP1.LT.0.0.AND.STEP2.LT.0.0)THEN
         START1=GEO(LPARA1,LATOM1)+ABS((NPTS1-1)*STEP1)
         START2=GEO(LPARA2,LATOM2)+ABS((NPTS2-1)*STEP2)
      ENDIF
C
C  NOW TO SWEEP THROUGH THE GRID OF POINTS LEFT TO RIGHT THEN RIGHT
C  TO LEFT OR VISA VERSA. THIS SHOULD AVOID THE GEOMETRY OR SCF GETTING
C  MESSED UP.
C
      IF(LPARA1.NE.1) THEN
         C1=DEGREE
      ELSE
         C1=1.D0
      ENDIF
      IF(LPARA2.NE.1) THEN
         C2=DEGREE
      ELSE
         C2=1.D0
      ENDIF
C   THESE PARAMETERS NEED TO BE DUMPED IN '.RES'
      CURRT1=START1
      CURRT2=START2
      IONE=-1
      CPUTOT=0.0D0
      IJLP=0
      ILP=1
      JLP=1
      JLP1=1
      SURF(1)=0.D0
C
      IF (RESTRT) THEN
         MDFP(9)=0
         CALL DFPSAV(CPUTOT,XPARAM,GD,XLAST,ESCF,MDFP,XDFP)
      ENDIF
C
      GEO(LPARA1,LATOM1)=CURRT1
      GEO(LPARA2,LATOM2)=CURRT2
      DO 30 ILOOP=ILP,NPTS1
         IONE=-IONE
         DO 20 JLOOP=JLP,NPTS2
            JLOOP1=0
            IF(IONE.LT.0)JLOOP1=NPTS2+1
            IF(RESTRT) THEN
               JLOOP1=JLP1
               IONE=-IONE
               RESTRT=.FALSE.
            ELSE
               JLOOP1=JLOOP1+IONE
               JLP1=JLOOP1
            ENDIF
            CPU1=SECOND()
            CURRT1=GEO(LPARA1,LATOM1)
            CURRT2=GEO(LPARA2,LATOM2)
            CALL FLEPO(XPARAM, NVAR, ESCF)
            CPU2=SECOND()
            CPU3=CPU2-CPU1
            CPUTOT=CPUTOT+CPU3
            JLP=JLP+1
            IJLP=IJLP+1
            SURF(IJLP)=ESCF
            WRITE(WU,'(/''       FIRST VARIABLE   SECOND VARIABLE
     1 FUNCTION'')')
            WRITE(WU,'('' :'',F16.5,F16.5,F16.6)')GEO(LPARA1,LATOM1)*C1,
     1        GEO(LPARA2,LATOM2)*C2,ESCF
            CALL GEOUT(6)
            GEO(LPARA2,LATOM2)=GEO(LPARA2,LATOM2)+STEP2*IONE
   20    CONTINUE
         GEO(LPARA1,LATOM1)=GEO(LPARA1,LATOM1)+STEP1
         GEO(LPARA2,LATOM2)=GEO(LPARA2,LATOM2)-STEP2*IONE
         ILP=ILP+1
         JLP=1
   30 CONTINUE
      WRITE(WU,'(/10X,''HORIZONTAL: VARYING SECOND PARAMETER,'',
     1          /10X,''VERTICAL:   VARYING FIRST PARAMETER'')')
      WRITE(WU,'(/10X,''WHOLE OF GRID, SUITABLE FOR PLOTTING'',//)')
C
C  ARCHIVE
!      OPEN(UNIT=12,FILE=GETNAM('FOR012'),STATUS='UNKNOWN')
      OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='NEW',ERR=31)
      GOTO 32
  31  OPEN(UNIT=20,FILE=GETNAM('FOR020'),STATUS='OLD')
  32  CONTINUE
      WRITE(12,40)
      CALL WRTTXT(12)
   40 FORMAT(' ARCHIVE FILE FOR GRID CALCULATION'/'GRID OF HEATS'/)
      WRITE(12,'(/'' TOTAL CPU TIME IN FLEPO : '',F10.3/)') CPUTOT
C
C  WRITE OUT THE GRIDS
      IONE=1
      ILOOP=1
      JLOOP1=1
      DO 50 IJ=1,NPTS1*NPTS2
         SURFAC(JLOOP1,ILOOP)=SURF(IJ)
         N=IJ-(IJ/NPTS2)*NPTS2
         IF (N.EQ.0) THEN
            ILOOP=ILOOP+1
            JLOOP1=JLOOP1+IONE
            IONE=-IONE
         ENDIF
         JLOOP1=JLOOP1+IONE
   50 CONTINUE
C
      DO 60 I=2,NPTS1
   60 UMPY(I)=UMPY(1)+(I-1)*ABS(STEP1)
      DO 70 I=2,NPTS2
   70 UMPX(I)=UMPX(1)+(I-1)*ABS(STEP2)
      N=0
      IF(STEP1.GT.0.0.AND.STEP2.GT.0.0) THEN
         DO 90 I=1,NPTS1
            DO 80 J=1,NPTS2
               N=N+1
   80       UMPZ(N)=SURFAC(J,I)
            WRITE(WU,'(11F7.2)')(SURFAC(J,I),J=1,NPTS2)
   90    WRITE(12,'(11F7.2)')(SURFAC(J,I),J=1,NPTS2)
      ENDIF
      IF(STEP1.LT.0.0.AND.STEP2.GT.0.0) THEN
         DO 110 I=NPTS1,1,-1
            DO 100 J=1,NPTS2
               N=N+1
  100       UMPZ(N)=SURFAC(J,I)
            WRITE(WU,'(11F7.2)')(SURFAC(J,I),J=1,NPTS2)
  110    WRITE(12,'(11F7.2)')(SURFAC(J,I),J=1,NPTS2)
      ENDIF
      IF(STEP1.GT.0.0.AND.STEP2.LT.0.0) THEN
         DO 130 I=1,NPTS1
            DO 120 J=NPTS2,1,-1
               N=N+1
  120       UMPZ(N)=SURFAC(J,I)
            WRITE(WU,'(11F7.2)')(SURFAC(J,I),J=NPTS2,1,-1)
  130    WRITE(12,'(11F7.2)')(SURFAC(J,I),J=NPTS2,1,-1)
      ENDIF
      IF(STEP1.LT.0.0.AND.STEP2.LT.0.0) THEN
         DO 150 I=NPTS1,1,-1
            DO 140 J=NPTS2,1,-1
               N=N+1
  140       UMPZ(N)=SURFAC(J,I)
            WRITE(WU,'(11F7.2)')(SURFAC(J,I),J=NPTS2,1,-1)
  150    WRITE(12,'(11F7.2)')(SURFAC(J,I),J=NPTS2,1,-1)
      ENDIF
      DO 160 I=0,NPTS1-1
         DO 160 J=1,NPTS2
            N=I*NPTS2+J
  160 WRITE(20,'(3(1X,F8.3))')UMPX(J),UMPY(I+1),UMPZ(N)
      CLOSE(20)
      END
