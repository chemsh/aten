      FUNCTION MECI(EIGS,COEFF)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      DIMENSION EIGS(NORBS), COEFF(NORBS,NORBS)
      COMMON /OUTFIL/ WU
      INTEGER WU
***********************************************************************
*
*                 PROGRAM MECI
*
*   A MULTI-ELECTRON CONFIGURATION INTERACTION CALCULATION
*
*   WRITTEN BY JAMES J. P. STEWART, AT THE
*              FRANK J. SEILER RESEARCH LABORATORY
*              USAFA, COLORADO SPRINGS, CO 80840
*
*              1985
*
***********************************************************************
C
      DOUBLE PRECISION MECI
C
C   MATRICES FOR PERMUTATION WORK
C
      DIMENSION NFA(2*NMECI), NPERMA(NMECI,6*NMECI),
     1NPERMB(NMECI,6*NMECI), EIGA(NMECI)
C
C   MATRICES FOR ONE AND TWO ELECTRON INTEGRALS
C
      COMMON /RJKS  /RJKAB(NMECI,NMECI), RJKAA(NMECI,NMECI)
C
C   SPIN MATRICES
C
      DIMENSION SPIN(NMECI**2)
      LOGICAL DEBUG,  LARGE, PRNT, LSPIN, LSPIN1,
     1 FIRST1, BIGPRT, SING, DOUB, TRIP, QUAR, QUIN, SEXT,
     2 PRNT2, GEOOK
      CHARACTER KEYWRD*241, TSPIN(7)*8, LINE*80
      COMMON /MOLKST/ NUMAT,NAT(NUMATM),NFIRST(NUMATM),NMIDLE(NUMATM),
     1                NLAST(NUMATM), NORBS, NELECS,
     2                NDUMMY(2), NCLOSE, NOPEN, NDUMY, FRACT
      COMMON /LAST  / LAST
      COMMON /SPQR/ ISPQR(NMECI**2,NMECI),IS,I,K
      COMMON /KEYWRD/ KEYWRD
C
C   MATRICES FOR SEC.DET., VECTORS, AND EIGENVALUES.
C
      COMMON /WORK2 / CIMAT(NMECI**4), EIG(NMECI**2), DIAG(2*NMECI**3)
      COMMON /BASEOC/ OCCA(NMECI)
     1       /WORK3 / DIJKL(MPACK*4)
      COMMON /CIVECT/ VECTCI(NMECI**2),CONF(NMECI**4+1)
      COMMON /NALMAT/ NALPHA(NMECI**2)
      COMMON /MICROS/ MICROA(NMECI,4*NMECI**2), MICROB(NMECI,4*NMECI**2)
      COMMON /CIBITS/ NMOS,LAB,NELEC, NBO(3)
      COMMON /XYIJKL/ XY(NMECI,NMECI,NMECI,NMECI)
      COMMON /NUMCAL/ NUMCAL
      SAVE FIRST1, TSPIN
      SAVE J,L, DEBUG, PRNT2,MDIM, LSPIN1
      SAVE LARGE, LROOT, SING, DOUB, QUAR, QUIN, SEXT, SMULT, NE
      SAVE GEOOK
      DATA ICALCN/0/
      DATA TSPIN/'SINGLET ','DOUBLET ','TRIPLET ','QUARTET ','QUINTET ',
     1'SEXTET  ','SEPTET  '/
      IF (ICALCN.NE.NUMCAL) THEN
         ICALCN=NUMCAL
         FIRST1=.TRUE.
         MDIM=NMECI**2
         GEOOK=(INDEX(KEYWRD,'GEO-OK').NE.0)
         LSPIN1=(INDEX(KEYWRD,'ESR').NE.0)
         DEBUG=(INDEX(KEYWRD,'DEBUG').NE.0)
         PRNT2=(INDEX(KEYWRD,'MECI').NE.0)
         DEBUG=(DEBUG.AND.PRNT2)
         LARGE=(INDEX(KEYWRD,'LARGE').NE.0)
         NDOUBL=99
         IF(INDEX(KEYWRD,'C.I.=(').NE.0)THEN
            NDOUBL=READA(KEYWRD,INDEX(KEYWRD,'C.I.=(')+7)
            NMOS=READA(KEYWRD,INDEX(KEYWRD,'C.I.=(')+5)
         ELSEIF (INDEX(KEYWRD,'C.I.=').NE.0)THEN
            NMOS=READA(KEYWRD,INDEX(KEYWRD,'C.I.=')+5)
         ELSE
            NMOS=NOPEN-NCLOSE
         ENDIF
         LROOT=1
         IF(INDEX(KEYWRD,'EXCI').NE.0)LROOT=2
         I=INDEX(KEYWRD,'ROOT')
         IF(I.NE.0)LROOT=READA(KEYWRD,I)
         IF(NDOUBL.EQ.99)THEN
            J=MAX(MIN((NCLOSE+NOPEN+1)/2-(NMOS-1)/2,NORBS-NMOS+1),1)
         ELSE
            J=NCLOSE-NDOUBL+1
            IF(FRACT.GT.1.99D0)J=J+1
         ENDIF
         L=0
         DO 10 I=J,NCLOSE
            L=L+1
   10    OCCA(L)=1
         DO 20 I=NCLOSE+1,NOPEN
            L=L+1
   20    OCCA(L)=FRACT*0.5D0
         DO 30 I=NOPEN+1,J+NMOS-1
            L=L+1
   30    OCCA(L)=0.D0
C#         WRITE(WU,'('' INITIAL ORBITAL OCCUPANCIES'')')
C#         WRITE(WU,'(6F12.6)')(OCCA(L),L=1,NMOS)
         SING=(INDEX(KEYWRD,'SING')+
     1         INDEX(KEYWRD,'EXCI')+
     2         INDEX(KEYWRD,'BIRAD').NE.0)
         DOUB=(INDEX(KEYWRD,'DOUB').NE.0)
         TRIP=(INDEX(KEYWRD,'TRIP').NE.0)
         QUAR=(INDEX(KEYWRD,'QUAR').NE.0)
         QUIN=(INDEX(KEYWRD,'QUIN').NE.0)
         SEXT=(INDEX(KEYWRD,'SEXT').NE.0)
C
C  DEFINE MAGNETIC COMPONENT OF SPIN
C
         MSDEL=INDEX(KEYWRD,' MS')
         IF(MSDEL.NE.0)THEN
            MSDEL=1.0001D0*READA(KEYWRD,INDEX(KEYWRD,' MS'))
         ELSE
            IF(TRIP.OR.QUAR)MSDEL=1
            IF(QUIN.OR.SEXT)MSDEL=2
         ENDIF
         SMULT=-.5D0
         IF(SING) SMULT=0.00D0
         IF(DOUB) SMULT=0.75D0
         IF(TRIP) SMULT=2.00D0
         IF(QUAR) SMULT=3.75D0
         IF(QUIN) SMULT=6.00D0
         IF(SEXT) SMULT=8.75D0
         X=0.D0
         DO 40 J=1,NMOS
   40    X=X+OCCA(J)
         XX=X+X
         NE=XX+0.5D0
         NELEC=(NELECS-NE+1)/2
      ENDIF
      PRNT=(DEBUG.OR.LAST.EQ.3.AND.PRNT2)
      BIGPRT=(PRNT.AND.LARGE)
C
C    TEST TO SEE IF THE SET OF ENERGY LEVELS USED IN MECI IS COMPLETE,
C    I.E., ALL COMPONENTS OF DEGENERATE IRREDUCIBLE REPRESENTATIONS
C    ARE USED.  IF NOT, THEN RESULTS WILL BE NONSENSE.  GIVE USERS A
C    CHANCE TO REALLY FOUL THINGS UP BY ALLOWING JOB TO CONTINUE IF
C    'GEO-OK' IS SPECIFIED.
C
      DO 50 I=1,NMOS
         IN=I+NELEC
   50 EIGA(I)=EIGS(IN)
      LSPIN=(LSPIN1.AND. LAST.EQ.3)
      IF(BIGPRT)THEN
         WRITE(WU,'(''  INITIAL EIGENVALUES'')')
         WRITE(WU,'(5F12.6)')(EIGA(I),I=1,NMOS)
         WRITE(WU,'(//10X,''NUMBER OF ELECTRONS IN C.I. ='',F5.1)')XX
      ENDIF
      IF(.NOT.GEOOK.AND.NELEC.GT.0)THEN
         IF(ABS(EIGS(NELEC+1)-EIGS(NELEC)).LT.1.D-1.OR.
     1ABS(EIGS(NELEC+1+NMOS)-EIGS(NELEC+NMOS)).LT.1.D-1)THEN
           WRITE(WU,'(///10X,A)')'DEGENERATE ENERGY LEVELS DETECTED IN M
     1ECI'
           WRITE(WU,'(10X,A)')'SOME OF THESE LEVELS WOULD BE TREATED BY'
     1//' MECI,'
           WRITE(WU,'(10X,A)')'WHILE OTHERS WOULD NOT.  THIS WOULD RESUL
     1T IN'
           WRITE(WU,'(10X,A)')'NON-REPRODUCIBLE ELECTRONIC ENERGIES.'
           WRITE(WU,'(10X,A)')'  JOB STOPPED.  TO CONTINUE, SPECIFY "GEO
     1-OK"'
            STOP
         ENDIF
      ENDIF
      IF( BIGPRT ) THEN
         WRITE(WU,'(//10X,''EIGENVECTORS'',/)')
         DO 60 I=1,NORBS
   60    WRITE(WU,'(6F12.6)')(COEFF(I,J+NELEC),J=1,NMOS)
      ENDIF
      NFA(2)=1
      NFA(1)=1
      DO 70 I=3,NMECI+1
   70 NFA(I)=NFA(I-1)*(I-1)
      CALL IJKL(COEFF(1,NELEC+1),COEFF,NELEC,NMOS,DIJKL)
      DO 80 I=1,NMOS
         DO 80 J=1,NMOS
            RJKAA(I,J)=XY(I,I,J,J)-XY(I,J,I,J)
   80 RJKAB(I,J)=XY(I,I,J,J)
      DO 100 I=1,NMOS
         X=0.0D0
         DO 90 J=1,NMOS
            X=X+(RJKAA(I,J)+RJKAB(I,J))*OCCA(J)
   90    CONTINUE
         EIGA(I)=EIGA(I)-X
C#      IF(ABS(OCCA(I)-0.5).LT.1.D-4)EIGA(I)=EIGA(I)+XY(I,I,I,I)*0.25D0
  100 CONTINUE
      IF(BIGPRT) THEN
         WRITE(WU,110)
  110    FORMAT(/,5X,'EIGENVALUES AFTER REMOVAL OF INTER-ELECTRONIC INTE
     1RACTIONS',/)
         WRITE(WU,'(6F12.6)')(EIGA(I),I=1,NMOS)
         WRITE(WU,'(///10X,''TWO-ELECTRON J-INTEGRALS'',/)')
         DO 120 I1=1,NMOS
  120    WRITE(WU,'(10F10.4)')(RJKAB(I1,J1),J1=1,NMOS)
         WRITE(WU,'(///10X,''TWO-ELECTRON K-INTEGRALS'',/)')
         DO 130 I1=1,NMOS
  130    WRITE(WU,'(10F10.4)')(RJKAB(I1,J1)-RJKAA(I1,J1),J1=1,NMOS)
      ENDIF
      NATOMS=NUMAT
      DO 140 I=1,NMOS
         DO 140 J=1,NMOS
            RJKAA(I,J)=RJKAA(I,J)*0.5D0
  140 CONTINUE
      IF(FIRST1) THEN
         I=INDEX(KEYWRD,'MICROS')
         IF(I.NE.0)THEN
            K=READA(KEYWRD,I)
            LAB=K
            IF(PRNT)WRITE(WU,'(''    MICROSTATES READ IN'')')
            NTOT=XX+0.5D0
            REWIND 5
            DO 150 I=1,1000
               READ(5,'(A)')LINE
  150       IF(INDEX(LINE,'MICRO').NE.0)GOTO 160
  160       DO 170 I=1,1000
               READ(5,'(A)')LINE
  170       IF(INDEX(LINE,'MICRO').NE.0)GOTO 180
  180       DO 210 I=1,LAB
               READ(5,'(A)')LINE
               IZERO=MAX(0,MIN(INDEX(LINE,'0'),INDEX(LINE,'1'))-1)
               DO 190 J=1,NMOS
                  IF(LINE(J+IZERO:J+IZERO).NE.'1')
     1            LINE(J+IZERO:J+IZERO)='0'
                  IF(LINE(J+NMOS+IZERO:J+NMOS+IZERO).NE.'1')
     1            LINE(J+NMOS+IZERO:J+NMOS+IZERO)='0'
                  MICROA(J,I)=ICHAR(LINE(J+IZERO:J+IZERO))-
     1          ICHAR('0')
                  MICROB(J,I)=ICHAR(LINE(J+NMOS+IZERO:J+NMOS+IZERO))-
     1          ICHAR('0')
  190          CONTINUE
               IF(PRNT)WRITE(WU,'(20I6)')(MICROA(J,I),J=1,NMOS),
     1        (MICROB(J,I),J=1,NMOS)
               K=0
               DO 200 J=1,NMOS
  200          K=K+MICROA(J,I)+MICROB(J,I)
               IF(K.NE.NTOT)THEN
                  NTOT=K
                  XX=K
                  WRITE(WU,'(/,''NUMBER OF ELECTRONS IN C.I. REDEFINED TO
     1:'',I4,/)')K
               ENDIF
  210       CONTINUE
            FIRST1=.FALSE.
            GOTO 260
         ENDIF
         NUPP=(NE+1)/2 +MSDEL
         NDOWN=NE-NUPP
         AMS=(NUPP-NDOWN)*0.5D0
         IF(PRNT)WRITE(WU,220) AMS
  220    FORMAT(10X,'COMPONENT OF SPIN  = ',F4.1)
         IF(NUPP*NDOWN.LT.0) THEN
            WRITE(WU,'(/10X,''IMPOSSIBLE VALUE OF DELTA S'')')
            STOP
         ENDIF
         LIMA=NFA(NMOS+1)/(NFA(NUPP+1)*NFA(NMOS-NUPP+1))
         LIMB=NFA(NMOS+1)/(NFA(NDOWN+1)*NFA(NMOS-NDOWN+1))
         LAB=LIMA*LIMB
         IF(PRNT)WRITE(WU,230) LAB
  230    FORMAT(//10X,35H NO OF CONFIGURATIONS CONSIDERED = ,I4)
C#      IF(LAB.LT.101) GOTO 240
C#      WRITE(WU,230)
C#  230 FORMAT(10X,24H TOO MANY CONFIGURATIONS/)
C#      GOTO 160
C#  240 CONTINUE
         CALL PERM(NPERMA, NUPP, NMOS, NMECI, LIMA)
         CALL PERM(NPERMB, NDOWN, NMOS, NMECI, LIMB)
         K=0
         DO 240 I=1,LIMA
            DO 240 J=1,LIMB
               K=K+1
               DO 240 L=1,NMOS
                  MICROA(L,K)=NPERMA(L,I)
  240    MICROB(L,K)=NPERMB(L,J)
  250    FORMAT(10I1)
  260    CONTINUE
         LIMA=LAB
         LIMB=LAB
      ENDIF
      GSE=0.0D0
      DO 270 I=1,NMOS
         GSE=GSE+EIGA(I)*OCCA(I)*2.D0
         GSE=GSE+XY(I,I,I,I)*OCCA(I)*OCCA(I)
         DO 270 J=I+1,NMOS
  270 GSE=GSE+2.D0*(2.D0*XY(I,I,J,J) - XY(I,J,I,J))*OCCA(I)*OCCA(J)
      J=0
      DO 280 I=1,LAB
         DIAG(I)=DIAGI(MICROA(1,I),MICROB(1,I),EIGA,XY,NMOS)-GSE
  280 CONTINUE
  290 CONTINUE
      IF(LAB.LE.MDIM) GOTO 330
      X=-100.D0
      DO 300 I=1,LAB
         IF(DIAG(I).GT.X)THEN
            X=DIAG(I)
            J=I
         ENDIF
  300 CONTINUE
      IF(J.NE.LAB) THEN
         DO 320 I=J,LAB
            I1=I+1
            DO 310 K=1,NMOS
               MICROA(K,I)=MICROA(K,I1)
  310       MICROB(K,I)=MICROB(K,I1)
  320    DIAG(I)=DIAG(I1)
      ENDIF
      LAB=LAB-1
      GOTO 290
  330 CONTINUE
C
C     BUILD SPIN AND NUMBER OF ALPHA SPIN TABLES.
C     -------------------------------------------
      DO 350 I=1,LAB
         K=0
         X=0.D0
         DO 340 J=1,NMOS
            X=X+MICROA(J,I)*MICROB(J,I)
  340    K=K+MICROA(J,I)
         NALPHA(I)=K
  350 SPIN(I)=4.D0*X-(XX-2*NALPHA(I))**2
C
C   BEFORE STARTING, CHECK THAT THE ROOT WANTED CAN EXIST
C
      IF(LAB.LT.LROOT)THEN
        WRITE(WU,'(//10X,''C.I. IS OF SIZE LESS THAN ROOT SPECIFIED'')')
        WRITE(WU,'(10X,''MODIFY SIZE OF C.I. OR ROOT NUMBER'')')
        WRITE(WU,'(A,I4,A,I4)')' SIZE OF C.I.:',LAB,' ROOT REQUIRED:',
     +LROOT
         STOP
      ENDIF
      IF(PRNT)THEN
         WRITE(WU,'(/,'' CONFIGURATIONS CONSIDERED IN C.I.      '',/
     1          '' M.O. NUMBER :      '',10I4)')(I,I=NELEC+1,NELEC+NMOS)
         WRITE(WU,'(''          ENERGY'')')
         DO 360 I=1,LAB
            WRITE(WU,'(/10X,I4,6X,10I4)') I,(MICROA(K,I),K=1,NMOS)
  360    WRITE(WU,'(6X,F10.4,4X,10I4)')DIAG(I),(MICROB(K,I),K=1,NMOS)
      ENDIF
      CALL MECIH(DIAG,CIMAT,NMOS,LAB)
      IF(BIGPRT)THEN
         WRITE(WU,'(//,'' C.I. MATRIX'')')
         I=MIN(LAB,MAXORB)
         IF(I.NE.LAB)WRITE(WU,'(''   (OUTPUT HAS BEEN TRUNCATED)'')')
         CALL VECPRT(CIMAT,-I)
      ELSE
         IF(PRNT)WRITE(WU,'(//,'' DIAGONAL OF C.I. MATRIX'')')
         IF(PRNT)WRITE(WU,'(5F13.6)')(CIMAT((I*(I+1))/2),I=1,LAB)
      ENDIF
C#       CALL TIMER('SEC. DET. CONSTRUCTED')
      LABSIZ=MIN(LAB,LROOT+10)
      CALL HQRII(CIMAT,LAB,LABSIZ,EIG,CONF)
C#       CALL TIMER('DIAG. DONE')
C
C   DECIDE WHICH ROOT TO EXTRACT
C
      KROOT=0
      IF(SMULT.LT.-0.1D0)THEN
         MECI=EIG(LROOT)
         DO 370 J=1,LAB
  370    VECTCI(J)=CONF(J+LAB*(LROOT-1))
         KROOT=LROOT
      ENDIF
      IF(BIGPRT)  THEN
         WRITE(WU,'(//20X,''STATE VECTORS'',//)')
         I=MIN(LAB,NORBS)
         J=MIN(LABSIZ,NORBS)
         CALL MATOUT(CONF,EIG,J,-I,LAB)
      ENDIF
      IF(PRNT)THEN
         WRITE(WU,380)
  380    FORMAT(///,' STATE ENERGIES '
     1,' EXPECTATION VALUE OF S**2  S FROM S**2=S(S+1)',//)
      ENDIF
      IROOT=0
      DO 390 I=1,9
  390 CIMAT(I)=0.1D0
      DO 440 I=1,LABSIZ
         X=0.5D0*XX
         II=(I-1)*LAB
         DO 420 J=1,LAB
            JI=J+II
            X=X-CONF(JI)*CONF(JI)*SPIN(J)*0.25D0
            K=ISPQR(J,1)
            IF(K.EQ.1)  GOTO  410
            DO 400 L=2,K
               LI=ISPQR(J,L)+II
  400       X=X+CONF(JI)*CONF(LI)*2.D0
  410       CONTINUE
  420    CONTINUE
         Y=(-1.D0+SQRT(1.D0+4.D0*X))*0.5D0
         IF(ABS(SMULT-X).LT.0.01)THEN
            IROOT=IROOT+1
            IF(IROOT.EQ.LROOT) THEN
               KROOT=I
               MECI=EIG(I)
               DO 430 J=1,LAB
  430          VECTCI(J)=CONF(J+LAB*(I-1))
            ENDIF
         ENDIF
         J=Y*2.D0+1.5D0
         CIMAT(J)=CIMAT(J)+1
  440 IF(PRNT)WRITE(WU,460) I,EIG(I),TSPIN(J),X,Y
      IF(KROOT.EQ.0)THEN
        WRITE(WU,'(//10X,''THE STATE REQUIRED IS NOT PRESENT IN THE'')')
        WRITE(WU,'(10X,  ''    SET OF CONFIGURATIONS AVAILABLE'')')
        WRITE(WU,'(/ 4X,''NUMBER OF STATES ACCESSIBLE USING CURRENT KEY-
     1WORDS'',/)')
         DO 450 I=1,7
  450    IF(CIMAT(I).GT.0.5D0)
     1WRITE(WU,'((24X,A8,I4))')TSPIN(I),NINT(CIMAT(I))
         STOP
      ENDIF
  460 FORMAT(I5,F12.6,3X,A8,F15.5,F10.5)
  470 CONTINUE
      MAXVEC=0
      IF(LSPIN)MAXVEC=MIN(4,LAB)
      IF(LSPIN.AND.(NE/2)*2.EQ.NE) THEN
         WRITE(WU,'(''   ESR SPECIFIED FOR AN EVEN-ELECTRON SYSTEM'')')
      ENDIF
C#      DO 570 I=1,NMOS
C#         DO 570 J=1,NORBS
C#  570 COEFF(J,I+NELEC)=COEFF(J,I+NELEC)**2
      DO 540 IUJ=1,MAXVEC
         IOFSET=(IUJ-1)*LAB
         WRITE(WU,'(//,''      MICROSTATE CONTRIBUTIONS TO '',
     1''STATE EIGENFUNCTION'',I3)')IUJ
         WRITE(WU,'(5F13.6)')(CONF(I+IOFSET),I=1,LAB)
         DO 480 I=1,LAB
  480    CONF(I)=VECTCI(I+IOFSET)**2
C                                             SECOND VECTOR!
         DO 500 I=1,NMOS
            SUM=0.D0
            DO 490 J=1,LAB
  490       SUM=SUM+(MICROA(I,J)-MICROB(I,J))*CONF(J)
  500    EIGA(I)=SUM
         WRITE(WU,'(/,''    SPIN DENSITIES FROM EACH M.O., ENERGY:''
     1,F7.3)')EIG(IUJ)
         WRITE(WU,'(5F12.6)') (EIGA(I),I=1,NMOS)
         WRITE(WU,*)
         WRITE(WU,*)'     SPIN DENSITIES FROM EACH ATOMIC ORBITAL'
        WRITE(WU,*)'                              S        PX        '//
     1'PY        PZ        TOTAL'
         DO 530 I=1,NATOMS
            IL=NFIRST(I)
            IU=NLAST(I)
            L=0
            SUMM=0.D0
            DO 520 K=IL,IU
               L=L+1
               SUM=0.D0
               DO 510 J=1,NMOS
  510          SUM=SUM+COEFF(K,J+NELEC)**2*EIGA(J)
               SUMM=SUMM+SUM
  520       EIGS(L)=SUM
            IF(L.EQ.4)THEN
               WRITE(WU,'(''  ATOM'',I4,''    SPIN DENSITY  '',5F10.7)')
     1I,(EIGS(K),K=1,L),SUMM
            ELSE
               WRITE(WU,'(''  ATOM'',I4,''    SPIN DENSITY  '',F10.7,30X,
     1F10.7)')I,EIGS(1),SUMM
            ENDIF
  530    CONTINUE
  540 CONTINUE
      RETURN
      END
