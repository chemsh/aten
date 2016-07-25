      SUBROUTINE PARSAV(MODE,N,M)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
**********************************************************************
*
*   PARSAV SAVES AND RESTORES DATA USED IN NLLSQ GRADIENT MINIMIZATION.
*
*    IF MODE IS 0 DATA ARE RESTORED, IF 1 THEN SAVED.
*
**********************************************************************
      COMMON /DENSTY/ P(MPACK), PA(MPACK), PB(MPACK)
      COMMON /ALPARM/ ALPARM(3,MAXPAR),X0, X1, X2, ILOOP
      COMMON /KEYWRD/ KEYWRD
      COMMON /ELEMTS/ ELEMNT(107)
      COMMON /ERRFN / ERRFN(MAXPAR), AICORR(MAXPAR)
      COMMON /GEOSYM/ NDEP,LOCPAR(MAXPAR),IDEPFN(MAXPAR),
     1                     LOCDEP(MAXPAR)
      COMMON /GEOKST/ NATOMS,LABELS(NUMATM),
     1                NA(NUMATM),NB(NUMATM),NC(NUMATM)
      COMMON /GEOM  / GEO(3,NUMATM), XCOORD(3,NUMATM)
      COMMON /MOLKST/ NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1                NLAST(NUMATM), NORBS, NELECS,NALPHA,NBETA,
     2                NCLOSE,NOPEN,NDUMY,FRACT
      COMMON /NLLCOM/ Q(MAXPAR,MAXPAR),R(MAXPAR,MAXPAR*2)
      COMMON /NLLCO2/ DDDUM(6),EFSLST(MAXPAR),XLAST(MAXPAR),IIIUM(7)
      COMMON /GEOVAR/ NVAR,LOC(2,MAXPAR), JDUMY, DUMY(MAXPAR)
      COMMON /LOCVAR/ LOCVAR(2,MAXPAR)
      COMMON /VALVAR/ VALVAR(MAXPAR),NUMVAR
      COMMON /OUTFIL/ WU
      INTEGER WU
      DIMENSION COORD(3,NUMATM)
      CHARACTER ELEMNT*2, KEYWRD*241, GETNAM*80
!      OPEN(UNIT=9,FILE=GETNAM('FOR009'),
!     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
      REWIND 9
!      OPEN(UNIT=10,FILE=GETNAM('FOR010'),
!     +     STATUS='UNKNOWN',FORM='UNFORMATTED')
      REWIND 10
      IF(MODE.NE.0) GOTO 10
*
*  MODE=0: RETRIEVE DATA FROM DISK.
*
      READ(9,END=30,ERR=30)IIIUM,DDDUM,EFSLST,N,(XLAST(I),I=1,N),M
      READ(9)((Q(J,I),J=1,M),I=1,M)
      READ(9)((R(J,I),J=1,N),I=1,N)
      READ(9)(VALVAR(I),I=1,N)
      IF(INDEX(KEYWRD,'AIDER').NE.0) READ(9)(AICORR(I),I=1,N)
      RETURN
   10 CONTINUE
      IF(MODE.EQ.1)THEN
        WRITE(WU,'(//10X,'' **** TIME UP ****'')')
        WRITE(WU,'(//10X,'' CURRENT VALUES OF GEOMETRIC VARIABLES'',//)'
     1)
         IF(NA(1) .EQ. 99) THEN
C
C  CONVERT FROM CARTESIAN COORDINATES TO INTERNAL
C
            DO 20 I=1,NATOMS
               DO 20 J=1,3
   20       COORD(J,I)=GEO(J,I)
            CALL XYZINT(COORD,NUMAT,NA,NB,NC,1.D0,GEO)
         ENDIF
         CALL GEOUT(6)
         WRITE(WU,'(//10X,
     1''TO RESTART CALCULATION USE THE KEYWORD "RESTART".'')')
      ENDIF
      WRITE(9)IIIUM,DDDUM,EFSLST,N,(XLAST(I),I=1,N),M
      WRITE(9)((Q(J,I),J=1,M),I=1,M)
      WRITE(9)((R(J,I),J=1,N),I=1,N)
      WRITE(9)(VALVAR(I),I=1,N)
      IF(INDEX(KEYWRD,'AIDER').NE.0) WRITE(9)(AICORR(I),I=1,N)
C*****
C     The density matrix is required by ITER upon restart .
C
      LINEAR=(NORBS*(NORBS+1))/2
      WRITE(10)(PA(I),I=1,LINEAR)
      IF(NALPHA.NE.0)WRITE(10)(PB(I),I=1,LINEAR)
C*****
!      CLOSE(9)
!      CLOSE(10)
      RETURN
   30 WRITE(WU,'(//10X,''NO RESTART FILE EXISTS!'')')
      STOP
      END
