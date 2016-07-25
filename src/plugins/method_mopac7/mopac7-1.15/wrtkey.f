      SUBROUTINE WRTKEY(KEYWRD)
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      INCLUDE 'SIZES'
      CHARACTER*241 KEYWRD, ALLKEY
***********************************************************************
*
*  WRTKEY CHECKS ALL KEY-WORDS AND PRINTS THOSE IT RECOGNIZES.  IF IT
*  FINDS A WORD IT DOES NOT RECOGNIZE THE PROGRAM WILL BE STOPPED.
*
***********************************************************************
      COMMON /NUMCAL/ NUMCAL
      COMMON /TIMDMP/ TLEFT, TDUMP
      COMMON /OUTFIL/ WU
      INTEGER WU
      LOGICAL UHF, TRIP, BIRAD, EXCI, CI, MYWORD
      LOGICAL AM1, MNDO, MINDO3, PM3
      CHARACTER CH*1, CHRONO*7
      SAVE AM1, MNDO, MINDO3
      DATA AM1, MNDO, MINDO3, PM3 /4*.FALSE./
      ALLKEY=KEYWRD
C    DUMMY IF STATEMENT TO REMOVE AMPERSAND AND PLUS SIGNS, IF PRESENT
      IF(MYWORD(ALLKEY(160:),' SETUP'))I=1
      IF(MYWORD(ALLKEY,'&'))I=2
      IF(MYWORD(ALLKEY,' +'))I=3
      IF(MYWORD(ALLKEY,'AUTHOR')) THEN
         WRITE(WU,'(10X,'' MOPAC - A GENERAL MOLECULAR ORBITAL PACKAGE'',
     1/         ,10X,''   ORIGINAL VERSION WRITTEN IN 1983'')')
         WRITE(WU,'(10X,''     BY JAMES J. P. STEWART AT THE'',/
     1         ,10X,''     UNIVERSITY OF TEXAS AT AUSTIN'',/
     2         ,10X,''          AUSTIN, TEXAS, 78712'')')
      ENDIF
      IF (MYWORD(ALLKEY,'VECT') ) WRITE(WU,210)
      IF (MYWORD(ALLKEY,' EXTE') ) THEN
         I=INDEX(KEYWRD,' EXTE')
         J=INDEX(KEYWRD(I:),'=')+I
         I=INDEX(KEYWRD(J:),' ')+J-1
         WRITE(WU,220)KEYWRD(J:I)
      ENDIF
      MAXGEO=0
      IF (MYWORD(ALLKEY,' DENS') ) WRITE(WU,230)
      IF (MYWORD(ALLKEY,'SPIN') ) WRITE(WU,240)
      IF (MYWORD(ALLKEY,' DEPVAR') )
     1WRITE(WU,250)READA(KEYWRD,INDEX(KEYWRD,'DEPVAR'))
      IF (MYWORD(ALLKEY,' DEP ') )WRITE(WU,260)
      IF (MYWORD(ALLKEY,'VELO') )WRITE(WU,270)
      IF (MYWORD(ALLKEY,' GREENF') ) WRITE(WU,378)
  378 FORMAT(' *  GREEN    - RUN DANOVICH''S GREEN''S FUNCTION CALCN.') 
      IF (MYWORD(ALLKEY,'TIMES') )WRITE(WU,280)
      IF (MYWORD(ALLKEY,'PARASOK') ) WRITE(WU,290)
      IF (MYWORD(ALLKEY,'NODIIS') ) WRITE(WU,300)
      IF (MYWORD(ALLKEY,'BONDS') ) WRITE(WU,310)
      IF (MYWORD(ALLKEY,'GEO-OK') ) WRITE(WU,320)
      IF (MYWORD(ALLKEY,'FOCK') ) WRITE(WU,330)
      IF (MYWORD(ALLKEY,'LARGE') ) WRITE(WU,340)
      IF (MYWORD(ALLKEY,' K=') ) WRITE(WU,350)
      IF (MYWORD(ALLKEY,'NOLOG') ) WRITE(WU,360)
      IF (MYWORD(ALLKEY,'AIGIN') ) WRITE(WU,370)
      IF (MYWORD(ALLKEY,'AIGOUT') ) WRITE(WU,380)
      IF (MYWORD(ALLKEY,'AIDER') ) WRITE(WU,390)
      IF (MYWORD(ALLKEY,' S1978') ) WRITE(WU,400)
      IF (MYWORD(ALLKEY,' SI1978') ) WRITE(WU,410)
      IF (MYWORD(ALLKEY,' GRAP') ) WRITE(WU,420)
      IF (MYWORD(ALLKEY,'NOANCI') ) WRITE(WU,440)
      IF (MYWORD(ALLKEY,'1ELEC') ) WRITE(WU,430)
      IF (MYWORD(ALLKEY(:162),' SETUP') ) WRITE(WU,470)
      IF (MYWORD(ALLKEY,' NOMM') ) WRITE(WU,460)
      IF (MYWORD(ALLKEY,' MMOK') ) WRITE(WU,480)
      IF (MYWORD(ALLKEY,'INTERP') ) WRITE(WU,490)
      IF (MYWORD(ALLKEY,' ESR') ) WRITE(WU,450)
      IF (MYWORD(ALLKEY,'DFP') ) WRITE(WU,500)
      IF (MYWORD(ALLKEY,'ANALYT') ) WRITE(WU,510)
      IF (MYWORD(ALLKEY,' MECI') ) WRITE(WU,520)
      IF (MYWORD(ALLKEY,'LOCAL') ) WRITE(WU,560)
      IF (MYWORD(ALLKEY,'MULLIK') ) WRITE(WU,570)
      IF (MYWORD(ALLKEY,' XYZ') ) WRITE(WU,580)
      IF (MYWORD(ALLKEY,' PI') ) WRITE(WU,590)
      IF (MYWORD(ALLKEY,'ECHO') ) WRITE(WU,600)
      IF (MYWORD(ALLKEY, 'SING') ) WRITE(WU,910)
      IF (MYWORD(ALLKEY, 'DOUB') ) WRITE(WU,920)
      IF (MYWORD(ALLKEY, 'QUAR') ) WRITE(WU,940)
      IF (MYWORD(ALLKEY, 'QUIN') ) WRITE(WU,950)
      IF (MYWORD(ALLKEY, 'SEXT') ) WRITE(WU,960)
      IF (MYWORD(ALLKEY,'H-PRIO') ) WRITE(WU,610)
      IF (MYWORD(ALLKEY,'X-PRIO') ) WRITE(WU,620)
      IF (MYWORD(ALLKEY,'T-PRIO') ) WRITE(WU,630)
      IF (MYWORD(ALLKEY,'COMPFG') ) WRITE(WU,650)
      IF (MYWORD(ALLKEY,'POLAR') ) WRITE(WU,640)
      IF (MYWORD(ALLKEY,'DEBUG ') ) WRITE(WU,660)
      IF (MYWORD(ALLKEY,'RESTART') ) WRITE(WU,670)
C
C     KEYWORDS ADDED FOR ESP MOPAC
C
      IF (MYWORD(ALLKEY,'ESP ') ) WRITE(WU,680)
      IF (MYWORD(ALLKEY,'NSURF') ) WRITE(WU,690)
      IF (MYWORD(ALLKEY,'SCALE') ) WRITE(WU,700)
      IF (MYWORD(ALLKEY,'SCINCR') ) WRITE(WU,710)
      IF (MYWORD(ALLKEY,'SLOPE') ) WRITE(WU,720)
      IF (MYWORD(ALLKEY,'DIPOLE') ) WRITE(WU,730)
      IF (MYWORD(ALLKEY,'DIPX') ) WRITE(WU,740)
      IF (MYWORD(ALLKEY,'DIPY') ) WRITE(WU,750)
      IF (MYWORD(ALLKEY,'DIPZ') ) WRITE(WU,760)
      IF (MYWORD(ALLKEY,'CONNOLLY') ) WRITE(WU,770)
      IF (MYWORD(ALLKEY,'ESPRST') ) WRITE(WU,780)
      IF (MYWORD(ALLKEY,' POTWRT') ) WRITE(WU,790)
      IF (MYWORD(ALLKEY,'WILLIAMS') ) WRITE(WU,800)
      IF (MYWORD(ALLKEY,'SYMAVG') ) WRITE(WU,810)
      IF (MYWORD(ALLKEY,'STO3G') ) WRITE(WU,820)
      IF (MYWORD(ALLKEY,'IUPD')) THEN
         II=NINT(READA(KEYWRD,INDEX(KEYWRD,'IUPD=')))
         IF (II.EQ.0) WRITE(WU,90)
         IF (II.EQ.1) WRITE(WU,100)
         IF (II.EQ.2) WRITE(WU,110)
      ENDIF
      IF (MYWORD(ALLKEY,'HESS')) THEN
         II=NINT(READA(KEYWRD,INDEX(KEYWRD,'HESS=')))
         IF (II.EQ.0) WRITE(WU,120)
         IF (II.EQ.1) WRITE(WU,130)
         IF (II.EQ.2) WRITE(WU,140)
         IF (II.EQ.3) WRITE(WU,150)
      ENDIF
      IF (MYWORD(ALLKEY,' MODE')) WRITE(WU,160)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,'MODE=')))
      IF (MYWORD(ALLKEY,' RECALC')) WRITE(WU,170)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,'RECALC')))
      IF (MYWORD(ALLKEY,' DMAX')) WRITE(WU,180)
     1 READA(KEYWRD,INDEX(KEYWRD,'DMAX='))
      IF (MYWORD(ALLKEY,' MS=')) WRITE(WU,190)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,' MS=')))
      IF (MYWORD(ALLKEY,' PRNT')) WRITE(WU,200)
      IF (MYWORD(ALLKEY,'IRC=') ) THEN
         MAXGEO=1
         WRITE(WU,830)NINT(READA(KEYWRD,INDEX(KEYWRD,'IRC=')))
      ELSEIF (MYWORD(ALLKEY,'IRC') ) THEN
         MAXGEO=1
         WRITE(WU,840)
      ENDIF
      IF (MYWORD(ALLKEY,'CHARGE') )
     1 WRITE(WU,850)NINT(READA(KEYWRD,INDEX(KEYWRD,'CHARGE')))
      IF (MYWORD(ALLKEY,'GRAD') ) WRITE(WU,860)
      UHF=(MYWORD(ALLKEY,'UHF') )
      IF(UHF)WRITE(WU,870)
      BIRAD=(MYWORD(ALLKEY,'BIRAD') )
      IF(BIRAD)WRITE(WU,890)
      EXCI=(MYWORD(ALLKEY,'EXCITED') )
      IF(EXCI) WRITE(WU,900)
      TRIP=(MYWORD(ALLKEY,'TRIP') )
      IF(TRIP)WRITE(WU,930)
      IF (MYWORD(ALLKEY,'SYM') ) WRITE(WU,970)
      IF (MYWORD(ALLKEY,' GROUP') ) THEN
         WRITE(WU,971)
         IF (MYWORD(ALLKEY,' RMAT') )    WRITE(WU,972)
         IF (MYWORD(ALLKEY,' IPO') )     WRITE(WU,973)
         IF (MYWORD(ALLKEY,' NODEGEN') ) WRITE(WU,974)
      ENDIF
      IF (MYWORD(ALLKEY,' RMAT') ) THEN
         WRITE(WU,'(//,10X,''RMAT MUST BE SPECIFIED WITH '',
     1   ''GROUP'')')
         STOP
      ENDIF
      IF (MYWORD(ALLKEY,' IPO') ) THEN
         WRITE(WU,'(//,10X,''IPO MUST BE SPECIFIED WITH '',
     1   ''GROUP'')')
         STOP
      ENDIF
      IF (MYWORD(ALLKEY,' NODEGEN') ) THEN
         WRITE(WU,'(//,10X,''NODEGEN MUST BE SPECIFIED WITH '',
     1   ''GROUP'')')
         STOP
      ENDIF
      IF(MYWORD(ALLKEY,'OPEN('))THEN
         I=INDEX(KEYWRD,'OPEN(')
         IELEC=READA(KEYWRD,I)
         ILEVEL=READA(KEYWRD,I+7)
         WRITE(WU,990)IELEC,ILEVEL
      ENDIF
      IF(MYWORD(ALLKEY,'MICROS'))
     1WRITE(WU,980)INT(READA(KEYWRD,INDEX(KEYWRD,'MICROS')))
      IF(MYWORD(ALLKEY,'DRC='))THEN
         MAXGEO=1
         WRITE(WU,540)READA(KEYWRD,INDEX(KEYWRD,'DRC='))
      ELSEIF (MYWORD(ALLKEY,' DRC') ) THEN
         MAXGEO=1
         WRITE(WU,530)
      ENDIF
      IF(MYWORD(ALLKEY,'KINE'))
     1WRITE(WU,550)READA(KEYWRD,INDEX(KEYWRD,'KINE'))
      CHRONO='SECONDS'
      TIME=1
      IF(MYWORD(ALLKEY,' T=')) THEN
         I=INDEX(KEYWRD,' T=')
         TLEFT=READA(KEYWRD,I)
         DO 10 J=I+3,241
            IF( J.EQ.241.OR.KEYWRD(J+1:J+1).EQ.' ') THEN
               CH=KEYWRD(J:J)
               IF( CH .EQ. 'M') CHRONO='MINUTES'
               IF( CH .EQ. 'M') TIME=60
               IF( CH .EQ. 'H') CHRONO='HOURS'
               IF( CH .EQ. 'H') TIME=3600
               IF( CH .EQ. 'D') CHRONO='DAYS'
               IF( CH .EQ. 'D') TIME=86400
               GOTO 20
            ENDIF
   10    CONTINUE
   20    CONTINUE
         IF(TLEFT.LT.99999.9D0)THEN
            WRITE(WU,1000)TLEFT,CHRONO
         ELSE
            WRITE(WU,1010)TLEFT,CHRONO
         ENDIF
         TLEFT=TLEFT*TIME
!	     write(6,'(a,2(1x,e13.6),3(1x,i10))') "aks> wrtkey> "
!     +,tleft,time,maxtim,numcal,1 
      ELSEIF(NUMCAL.EQ.1)THEN
         TLEFT=REAL(MAXTIM)
         WRITE(WU,1000) TLEFT,'SECONDS'
!	     write(6,'(a,2(1x,e13.6),3(1x,i10))') "aks> wrtkey> "
!     +,tleft,time,maxtim,numcal,2 
      ELSE
         WRITE(WU,1000)TLEFT,'SECONDS'
!	  	 write(6,'(a,2(1x,e13.6),3(1x,i10))') "aks> wrtkey> "
!     +,tleft,time,maxtim,numcal,3 
      ENDIF
      TIME=1
      CHRONO='SECONDS'
      IF(MYWORD(ALLKEY,' DUMP')) THEN
         I=INDEX(KEYWRD,' DUMP')
         TDUMP=READA(KEYWRD,I)
         DO 30 J=I+6,241
            IF( J.EQ.241.OR.KEYWRD(J+1:J+1).EQ.' ') THEN
               CH=KEYWRD(J:J)
               IF( CH .EQ. 'M') CHRONO='MINUTES'
               IF( CH .EQ. 'M') TIME=60.D0
               IF( CH .EQ. 'H') CHRONO='HOURS'
               IF( CH .EQ. 'H') TIME=3600.D0
               IF( CH .EQ. 'D') CHRONO='DAYS'
               IF( CH .EQ. 'D') TIME=86400.D0
               GOTO 40
            ENDIF
   30    CONTINUE
   40    CONTINUE
         IF(TDUMP.LT.99999.9D0)THEN
            WRITE(WU,1020)TDUMP,CHRONO
         ELSE
            WRITE(WU,1030)TDUMP,CHRONO
         ENDIF
         TDUMP=TDUMP*TIME
      ELSEIF(NUMCAL.EQ.1)THEN
         TDUMP=MAXDMP
         WRITE(WU,1020)TDUMP,'SECONDS'
      ELSE
         WRITE(WU,1020)TDUMP,'SECONDS'
      ENDIF
      IF (MYWORD(ALLKEY,'1SCF') ) THEN
         WRITE(WU,1040)
         IF(INDEX(KEYWRD,'RESTART').EQ.0)MAXGEO=MAXGEO+1
      ENDIF
      CI=MYWORD(ALLKEY,'C.I.')
      IF (CI) THEN
         J=INDEX(KEYWRD,'C.I.=(')
         IF(J.NE.0)THEN
            WRITE(WU,1060)INT(READA(KEYWRD,INDEX(KEYWRD,'C.I.=(')+7)),
     1      INT(READA(KEYWRD,INDEX(KEYWRD,'C.I.=(')+5))
         ELSE
            WRITE(WU,1050)INT(READA(KEYWRD,INDEX(KEYWRD,'C.I.')+5))
         ENDIF
      ENDIF
      IF (MYWORD(ALLKEY,' FORCE') ) THEN
         WRITE(WU,1070)
         MAXGEO=MAXGEO+1
      ENDIF
      IF (MYWORD(ALLKEY,' EF')) THEN
         WRITE(WU,70)
         MAXGEO=MAXGEO+1
      ENDIF
      IF (MYWORD(ALLKEY,' TS')) THEN
         WRITE(WU,80)
         MAXGEO=MAXGEO+1
      ENDIF
      METHOD=0
      IF (MYWORD(ALLKEY,'MINDO') ) THEN
         WRITE(WU,1080)
         MINDO3=.TRUE.
         METHOD=1
      ENDIF
      IF (MYWORD(ALLKEY,'AM1') ) THEN
         WRITE(WU,1090)
         AM1=.TRUE.
         METHOD=METHOD+1
      ENDIF
      IF (MYWORD(ALLKEY,'PM3') ) THEN
         WRITE(WU,1100)
         PM3=.TRUE.
         METHOD=METHOD+1
      ENDIF
      IF (MYWORD(ALLKEY,'MNDO') ) THEN
         MNDO=.TRUE.
         METHOD=METHOD+1
      ENDIF
      IF (MYWORD(ALLKEY,'OLDGEO') ) WRITE(WU,1120)
      IF (MYWORD(ALLKEY,'PREC') ) WRITE(WU,1110)
      IF (MYWORD(ALLKEY,'NOINTER') ) WRITE(WU,1130)
      IF (MYWORD(ALLKEY,'ISOTOPE') ) WRITE(WU,1140)
      IF (MYWORD(ALLKEY,'DENOUT') ) WRITE(WU,1150)
      IF (MYWORD(ALLKEY,'SHIFT') ) WRITE(WU,1160)
     1 READA(KEYWRD,INDEX(KEYWRD,'SHIFT'))
      IF (MYWORD(ALLKEY,'OLDENS') ) WRITE(WU,1170)
      IF (MYWORD(ALLKEY,'SCFCRT') ) WRITE(WU,1180)
     1 READA(KEYWRD,INDEX(KEYWRD,'SCFCRT'))
      IF (MYWORD(ALLKEY,'ENPART') ) WRITE(WU,1190)
      IF (MYWORD(ALLKEY,'NOXYZ') ) WRITE(WU,1200)
      IF (MYWORD(ALLKEY,'SIGMA') ) THEN
         WRITE(WU,1210)
         MAXGEO=MAXGEO+1
      ENDIF
      IF (MYWORD(ALLKEY,'NLLSQ') ) THEN
         WRITE(WU,1220)
         MAXGEO=MAXGEO+1
      ENDIF
      IF (MYWORD(ALLKEY,'ROOT') ) WRITE(WU,1230)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,'ROOT')))
      IF (MYWORD(ALLKEY,'TRANS=') ) THEN
         WRITE(WU,1250)NINT(READA(KEYWRD,INDEX(KEYWRD,'TRANS=')))
      ELSEIF (MYWORD(ALLKEY,'TRANS') ) THEN
         WRITE(WU,1240)
      ENDIF
      IF (MYWORD(ALLKEY,'SADDLE') ) THEN
         WRITE(WU,1260)
         MAXGEO=MAXGEO+1
      ENDIF
      IF (MYWORD(ALLKEY,' LET') ) WRITE(WU,1270)
      IF (MYWORD(ALLKEY,'COMPFG') ) WRITE(WU,1280)
      IF (MYWORD(ALLKEY,'GNORM') ) WRITE(WU,1290)
     1 READA(KEYWRD,INDEX(KEYWRD,'GNORM'))
      IF (MYWORD(ALLKEY,'PULAY') ) WRITE(WU,1300)
      IF (MYWORD(ALLKEY,' STEP1')  )WRITE(WU,1310)
     1 READA(KEYWRD,INDEX(KEYWRD,'STEP1')+6)
      IF (MYWORD(ALLKEY,' STEP2')  )WRITE(WU,1320)
     1 READA(KEYWRD,INDEX(KEYWRD,'STEP2')+6)
      IF (MYWORD(ALLKEY,' STEP')  )WRITE(WU,1500)
     1 READA(KEYWRD,INDEX(KEYWRD,'STEP')+5)
      IF (MYWORD(ALLKEY,' POINT1')  )THEN
         IP1=READA(KEYWRD,INDEX(KEYWRD,'POINT1')+7)
         WRITE(WU,1330) IP1
      ENDIF
      IF (MYWORD(ALLKEY,' POINT2')  )THEN
         IP2=READA(KEYWRD,INDEX(KEYWRD,'POINT2')+7)
         WRITE(WU,1340) IP2
      ENDIF
      IF (MYWORD(ALLKEY,' MAX') ) WRITE(WU,1350)
      IF (MYWORD(ALLKEY,' POINT')  )THEN
         IP=READA(KEYWRD,INDEX(KEYWRD,'POINT')+6)
         WRITE(WU,1510) IP
      ENDIF
      IF (MYWORD(ALLKEY,'BAR') ) WRITE(WU,1360)
     1 READA(KEYWRD,INDEX(KEYWRD,'BAR'))
      IF (MYWORD(ALLKEY,'CAMP') ) WRITE(WU,1370)
      IF (MYWORD(ALLKEY,'KING') ) WRITE(WU,1370)
      IF (MYWORD(ALLKEY,'EIGS') ) WRITE(WU,1380)
      IF (MYWORD(ALLKEY,'EIGINV') ) WRITE(WU,1390)
      IF (MYWORD(ALLKEY,'NONR') ) WRITE(WU,1400)
      IF (MYWORD(ALLKEY,'ORIDE') ) WRITE(WU,1410)
      IF (MYWORD(ALLKEY,'HYPERF') ) WRITE(WU,1420)
      IF (MYWORD(ALLKEY,' PL') ) WRITE(WU,1430)
      IF (MYWORD(ALLKEY,'FILL') ) WRITE(WU,1440)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,'FILL')))
      IF (MYWORD(ALLKEY,'ITRY') ) WRITE(WU,1470)
     1 NINT(READA(KEYWRD,INDEX(KEYWRD,'ITRY')))
      IF (MYWORD(ALLKEY,'0SCF') ) WRITE(WU,1490)
      IF(UHF)THEN
         IF(BIRAD.OR.EXCI.OR.CI)THEN
            WRITE(WU,'(//10X,
     1'' UHF USED WITH EITHER BIRAD, EXCITED OR C.I. '')')
            WRITE(WU,1480)
            GOTO 60
         ENDIF
      ELSE
         IF(EXCI.AND. TRIP) THEN
            WRITE(WU,'(//10X,'' EXCITED USED WITH TRIPLET'')')
            WRITE(WU,1480)
            GOTO 60
         ENDIF
      ENDIF
      IF (INDEX(KEYWRD,'T-PRIO').NE.0.AND.
     1INDEX(KEYWRD,'DRC').EQ.0) THEN
         WRITE(WU,'(//10X,''T-PRIO AND NO DRC'')')
         WRITE(WU,1480)
         GOTO 60
      ENDIF
      IF ( METHOD .GT. 1) THEN
         WRITE(WU,'(//10X,
     1'' ONLY ONE OF MINDO, MNDO, AM1 AND PM3 ALLOWED'')')
         WRITE(WU,1480)
         GOTO 60
      ENDIF
      IF (MYWORD(ALLKEY,' FIELD') )THEN
         WRITE(WU,1445)
      ENDIF
      IF (MYWORD(ALLKEY,'THERMO') )THEN
         WRITE(WU,1450)
         IF(MYWORD(ALLKEY,' ROT')) THEN
            WRITE(WU,1460)NINT(READA(KEYWRD,INDEX(KEYWRD,' ROT')))
         ELSE
            WRITE(WU,'
     1    (//10X,'' YOU MUST SUPPLY THE SYMMETRY NUMBER "ROT"'')')
            STOP
         ENDIF
      ENDIF
      IF(MAXGEO.GT.1)THEN
         WRITE(WU,'(//10X,''MORE THAN ONE GEOMETRY OPTION HAS BEEN '',
     1''SPECIFIED'',/10X,
     2''CONFLICT MUST BE RESOLVED BEFORE JOB WILL RUN'')')
         STOP
      ENDIF
      IF(INDEX(KEYWRD,'MULLIK').NE.0.AND.UHF)THEN
         WRITE(WU,'(A)')' MULLIKEN POPULATION NOT AVAILABLE WITH UHF'
         STOP
      ENDIF
      IF(ALLKEY.NE.' ')THEN
         J=0
         DO 50 I=1,240
            IF(ALLKEY(I:I).NE.' '.OR.ALLKEY(I:I+1).NE.'  ')THEN
               J=J+1
               CH=ALLKEY(I:I)
               ALLKEY(J:J)=CH
            ENDIF
   50    CONTINUE
         IF(ALLKEY(241:241).NE.' ')THEN
            J=J+1
            CH=ALLKEY(241:241)
            ALLKEY(J:J)=CH
         ENDIF
         J=MAX(1,J)
         L=INDEX(KEYWRD,'DEBUG')
         IF(L.NE.0)THEN
            WRITE(WU,'('' *  DEBUG KEYWORDS USED:  '',A)')ALLKEY(:J)
         ELSE
            WRITE(WU,'(///10X,''UNRECOGNIZED KEY-WORDS: ('',A,'')'')')
     1ALLKEY(:J)
            WRITE(WU,'(///10X,''CALCULATION STOPPED TO AVOID WASTING TIME
     1.'')')
            WRITE(WU,'(///10X,''IF THESE ARE DEBUG KEYWORDS, ADD THE KEYW
     1ORD "DEBUG"'')')
            STOP
         ENDIF
      ENDIF
      RETURN
   60 WRITE(WU,'(//10X,'' CALCULATION ABANDONED, SORRY!'')')
      STOP
C ***********************************************************
C ***********************************************************
   70 FORMAT(' *  EF       - USE EF ROUTINE FOR MINIMUM SEARCH')
   80 FORMAT(' *  TS       - USE EF ROUTINE FOR TS SEARCH')
   90 FORMAT(' *  IUPD=    - HESSIAN WILL NOT BE UPDATED')
  100 FORMAT(' *  IUPD=    - HESSIAN WILL BE UPDATED USING POWELL')
  110 FORMAT(' *  IUPD=    - HESSIAN WILL BE UPDATED USING BFGS')
  120 FORMAT(' *  HESS=    - DIAGONAL HESSIAN USED AS INITIAL GUESS')
  130 FORMAT(' *  HESS=    - INITIAL HESSIAN WILL BE CALCULATED')
  140 FORMAT(' *  HESS=    - INITIAL HESSIAN READ FROM DISK')
  150 FORMAT(' *  HESS=    - INITIAL HESSIAN READ FROM INPUT')
  160 FORMAT(' *  MODE=    - FOLLOW HESSIAN MODE',I3,' TOWARD TS')
  170 FORMAT(' *  RECALC=  - DO',I4,' CYCLES BETWEEN HESSIAN RECALC')
  180 FORMAT(' *  DMAX=    - TAKE MAXIMUM STEPSIZE OF',F5.3,' ANG/RAD')
  190 FORMAT(' *  MS=      - IN MECI, MAGNETIC COMPONENT OF SPIN =',I3)
  200 FORMAT(' *  PRNT     - EXTRA PRINTING IN EF ROUTINE')
C ***********************************************************
  210 FORMAT(' *  VECTORS  - FINAL EIGENVECTORS TO BE PRINTED')
  220 FORMAT(' *  EXTERNAL - USE ATOMIC PARAMETERS FROM THE FOLLOWING '
     1,'FILE',/15X,A)
  230 FORMAT(' *  DENSITY  - FINAL DENSITY MATRIX TO BE PRINTED')
  240 FORMAT(' *  SPIN     - FINAL UHF SPIN MATRIX TO BE PRINTED')
  250 FORMAT(' *  DEPVAR=N - SPECIFIED DISTANCE IS',F7.4,
     1' TIMES BOND LENGTH')
  260 FORMAT(' *  DEP      - OUTPUT FORTRAN CODE FOR BLOCK-DATA')
  270 FORMAT(' *  VELOCITY - INPUT STARTING VELOCITIES FOR DRC')
  280 FORMAT(' *  TIMES    - TIMES OF VARIOUS STAGES TO BE PRINTED')
  290 FORMAT(' *  PARASOK  - USE SOME MNDO PARAMETERS IN AN AM1 CALCULA'
     1,'TION')
  300 FORMAT(' *  NODIIS   - DO NOT USE GDIIS GEOMETRY OPTIMIZER')
  310 FORMAT(' *  BONDS    - FINAL BOND-ORDER MATRIX TO BE PRINTED')
  320 FORMAT(' *  GEO-OK   - OVERRIDE INTERATOMIC DISTANCE CHECK')
  330 FORMAT(' *  FOCK     - LAST FOCK MATRIX TO BE PRINTED')
  340 FORMAT(' *  LARGE    - EXPANDED OUTPUT TO BE PRINTED')
  350 FORMAT(' *   K=      - BRILLOUIN ZONE STRUCTURE TO BE CALCULATED')
  360 FORMAT(' *  NOLOG    - SUPPRESS LOG FILE TRAIL, WHERE POSSIBLE')
  370 FORMAT(' *  AIGIN    - GEOMETRY MUST BE IN GAUSSIAN FORMAT')
  380 FORMAT(' *  AIGOUT   - IN ARC FILE, INCLUDE AB-INITIO GEOMETRY')
  390 FORMAT(' *  AIDER    - READ IN AB INITIO DERIVATIVES')
  400 FORMAT(' *  S1978    - 1978 SULFUR PARAMETERS TO BE USED')
  410 FORMAT(' *  SI1978   - 1978 SILICON PARAMETERS TO BE USED')
  420 FORMAT(' *  GRAPH    - GENERATE FILE FOR GRAPHICS')
  430 FORMAT(' *  1ELECTRON- FINAL ONE-ELECTRON MATRIX TO BE PRINTED')
  440 FORMAT(' *  NOANCI   - DO NOT USE ANALYTICAL C.I. DERIVATIVES')
  450 FORMAT(' *  ESR      - RHF SPIN DENSITY CALCULATION REQUESTED')
  460 FORMAT(' *  NOMM     - DO NOT MAKE MM CORRECTION TO CONH BARRIER')
  470 FORMAT(' *  SETUP    - EXTRA KEYWORDS TO BE READ FROM FILE SETUP')
  480 FORMAT(' *  MMOK     - APPLY MM CORRECTION TO CONH BARRIER')
  490 FORMAT(' *  INTERP   - PRINT DETAILS OF CAMP-KING CONVERGER')
  500 FORMAT(' *  DFP      - USE DAVIDON FLETCHER POWELL OPTIMIZER')
  510 FORMAT(' *  ANALYT   - USE ANALYTIC DERIVATIVES ')
  520 FORMAT(' *  MECI     - M.E.C.I. WORKING TO BE PRINTED')
  530 FORMAT(' *  DRC      - DYNAMIC REACTION COORDINATE CALCULATION')
  540 FORMAT(' *  DRC=     - HALF-LIFE FOR KINETIC ENERGY LOSS =',F9.2,
     1' * 10**(-15) SECONDS')
  550 FORMAT(' *  KINETIC= - ',F9.3,' KCAL KINETIC ENERGY ADDED TO DRC')
  560 FORMAT(' *  LOCALIZE - LOCALIZED ORBITALS TO BE PRINTED')
  570 FORMAT(' *  MULLIK   - THE MULLIKEN ANALYSIS TO BE PERFORMED')
  580 FORMAT(' *  XYZ      - CARTESIAN COORDINATE SYSTEM TO BE USED')
  590 FORMAT(' *  PI       - BONDS MATRIX, SPLIT INTO SIGMA-PI-DELL',
     1' COMPONENTS, TO BE PRINTED')
  600 FORMAT(' *  ECHO     - ALL INPUT DATA TO BE ECHOED BEFORE RUN')
  610 FORMAT(' *  H-PRIOR  - HEAT OF FORMATION TAKES PRIORITY IN DRC')
  620 FORMAT(' *  X-PRIOR  - GEOMETRY CHANGES TAKE PRIORITY IN DRC')
  630 FORMAT(' *  T-PRIOR  - TIME TAKES PRIORITY IN DRC')
  640 FORMAT(' *  POLAR    - CALCULATE FIRST, SECOND AND THIRD-ORDER'
     1,' POLARIZABILITIES')
  650 FORMAT(' *  COMPFG   - PRINT HEAT OF FORMATION CALC''D IN COMPFG')
  660 FORMAT(' *  DEBUG    - DEBUG OPTION TURNED ON')
  670 FORMAT(' *  RESTART  - CALCULATION RESTARTED')
C
C     KEYWORDS ADDED FOR ESP MOPAC
C
  680 FORMAT(' *  ESP      - ELECTROSTATIC POTENTIAL CALCULATION')
  690 FORMAT(' *  NSURF    - NUMBER OF LAYERS')
  700 FORMAT(' *  SCALE    - SCALING FACTOR FOR VAN DER WAALS DISTANCE')
  710 FORMAT(' *  SCINCR   - INCREMENT BETWEEN LAYERS')
  720 FORMAT(' *  SLOPE    - SLOPE - USED TO SCALE MNDO ESP CHARGES')
  730 FORMAT(' *  DIPOLE   - FIT THE ESP TO THE CALCULATED DIPOLE')
  740 FORMAT(' *  DIPX     - X COMPONENT OF DIPOLE TO BE FIT')
  750 FORMAT(' *  DIPY     - Y COMPONENT OF DIPOLE TO BE FIT')
  760 FORMAT(' *  DIPZ     - Z COMPONENT OF DIPOLE TO BE FIT')
  770 FORMAT(' *  CONNOLLY - USE CONNOLLY SURFACE')
  780 FORMAT(' *  ESPRST   - RESTART OF ELECTRIC POTENTIAL CALCULATION')
  790 FORMAT(' *  POTWRT   - WRITE OUT ELECTRIC POT. DATA TO FILE 21')
  800 FORMAT(' *  WILLIAMS - USE WILLIAMS SURFACE')
  810 FORMAT(' *  SYMAVG   - AVERAGE SYMMETRY EQUIVALENT ESP CHARGES')
  820 FORMAT(' *  STO3G    - DEORTHOGONALIZE ORBITALS IN STO-3G BASIS')
  830 FORMAT(' *  IRC=N    - INTRINSIC REACTION COORDINATE',I3,
     1' DEFINED')
  840 FORMAT(' *  IRC      - INTRINSIC REACTION COORDINATE CALCULATION')
  850 FORMAT(3(' *',/),' *',15X,'  CHARGE ON SYSTEM =',I3,3(/,' *'))
  860 FORMAT(' *  GRADIENTS- ALL GRADIENTS TO BE PRINTED')
  870 FORMAT(' *  UHF      - UNRESTRICTED HARTREE-FOCK CALCULATION')
  880 FORMAT(' *  SINGLET  - STATE REQUIRED MUST BE A SINGLET')
  890 FORMAT(' *  BIRADICAL- SYSTEM HAS TWO UNPAIRED ELECTRONS')
  900 FORMAT(' *  EXCITED  - FIRST EXCITED STATE IS TO BE OPTIMIZED')
  910 FORMAT(' *  SINGLET  - SPIN STATE DEFINED AS A SINGLET')
  920 FORMAT(' *  DOUBLET  - SPIN STATE DEFINED AS A DOUBLET')
  930 FORMAT(' *  TRIPLET  - SPIN STATE DEFINED AS A TRIPLET')
  940 FORMAT(' *  QUARTET  - SPIN STATE DEFINED AS A QUARTET')
  950 FORMAT(' *  QUINTET  - SPIN STATE DEFINED AS A QUINTET')
  960 FORMAT(' *  SEXTET   - SPIN STATE DEFINED AS A SEXTET')
  970 FORMAT(' *  SYMMETRY - SYMMETRY CONDITIONS TO BE IMPOSED')
  971 FORMAT(' *  GROUP    - FREQUENCIES TO BE SYMMETRIZED')
  972 FORMAT(' *  RMAT     - PRINT R MATRICES')
  973 FORMAT(' *  IPO      - PRINT PERMUTATION OPERATOR')
  974 FORMAT(' *  NODEGEN  - DO NOT COLLAPSE DEGENERATE FREQUENCIES')
  980 FORMAT(' *  MICROS=N -',I4,' MICROSTATES TO BE SUPPLIED FOR C.I.')
  990 FORMAT(' *  OPEN(N,N)- THERE ARE',I2,' ELECTRONS IN',I2,' LEVELS')
 1000 FORMAT(' *  T=       - A TIME OF',F8.1,' ',A7,' REQUESTED')
 1010 FORMAT(' *  T=       - A TIME OF',G11.3,' ',A7,' REQUESTED')
 1020 FORMAT(' *  DUMP=N   - RESTART FILE WRITTEN EVERY',F8.1,
     1' ',A7)
 1030 FORMAT(' *  DUMP=N   - RESTART FILE WRITTEN EVERY',G11.3,
     1' ',A7)
 1040 FORMAT(' *  1SCF     - DO 1 SCF AND THEN STOP ')
 1050 FORMAT(' *  C.I.=N   -',I2,' M.O.S TO BE USED IN C.I.')
 1060 FORMAT(' *  C.I.=(N,M)-',I2,' DOUBLY FILLED LEVELS USED IN A ',/
     1,      ' *             C.I. INVOLVING ',I2,' M.O.''S')
 1070 FORMAT(' *  FORCE    - FORCE CALCULATION SPECIFIED')
 1080 FORMAT(' *  MINDO/3  - THE MINDO/3 HAMILTONIAN TO BE USED')
 1090 FORMAT(' *  AM1      - THE AM1 HAMILTONIAN TO BE USED')
 1100 FORMAT(' *  PM3      - THE PM3 HAMILTONIAN TO BE USED')
 1110 FORMAT(' *  PRECISE  - CRITERIA TO BE INCREASED BY 100 TIMES')
 1120 FORMAT(' *  OLDGEO   - PREVIOUS GEOMETRY TO BE USED')
 1130 FORMAT(' *  NOINTER  - INTERATOMIC DISTANCES NOT TO BE PRINTED')
 1140 FORMAT(' *  ISOTOPE  - FORCE MATRIX WRITTEN TO DISK (CHAN. 9 )')
 1150 FORMAT(' *  DENOUT   - DENSITY MATRIX OUTPUT ON CHANNEL 10')
 1160 FORMAT(' *  SHIFT    - A DAMPING FACTOR OF',F8.2,' DEFINED')
 1170 FORMAT(' *  OLDENS   - INITIAL DENSITY MATRIX READ OF DISK')
 1180 FORMAT(' *  SCFCRT   - DEFAULT SCF CRITERION REPLACED BY',G12.3)
 1190 FORMAT(' *  ENPART   - ENERGY TO BE PARTITIONED INTO COMPONENTS')
 1200 FORMAT(' *  NOXYZ    - CARTESIAN COORDINATES NOT TO BE PRINTED')
 1210 FORMAT(' *  SIGMA    - GEOMETRY TO BE OPTIMIZED USING SIGMA.')
 1220 FORMAT(' *  NLLSQ    - GRADIENTS TO BE MINIMIZED USING NLLSQ.')
 1230 FORMAT(' *  ROOT     - IN A C.I. CALCULATION, ROOT',I2,
     1                       ' TO BE OPTIMIZED.')
 1240 FORMAT(' *  TRANS    - THE REACTION VIBRATION TO BE DELETED FROM',
     1' THE THERMO CALCULATION')
 1250 FORMAT(' *  TRANS=   - ',I4,' VIBRATIONS ARE TO BE DELETED FROM',
     1' THE THERMO CALCULATION')
 1260 FORMAT(' *  SADDLE   - TRANSITION STATE TO BE OPTIMIZED')
 1270 FORMAT(' *  LET     - OVERRIDE SOME SAFETY CHECKS')
 1280 FORMAT(' *  COMPFG   - PRINT HEAT OF FORMATION CALC''D IN COMPFG')
 1290 FORMAT(' *  GNORM=   - EXIT WHEN GRADIENT NORM DROPS BELOW ',G8.3)
 1300 FORMAT(' *  PULAY    - PULAY''S METHOD TO BE USED IN SCF')
 1310 FORMAT(' *  STEP1    - FIRST  STEP-SIZE IN GRID =',F7.2)
 1320 FORMAT(' *  STEP2    - SECOND STEP-SIZE IN GRID =',F7.2)
 1330 FORMAT(' *  POINT1   - NUMBER OF ROWS IN GRID =',I3)
 1340 FORMAT(' *  POINT2   - NUMBER OF COLUMNS IN GRID =',I3)
 1350 FORMAT(' *  MAX      - GRID SIZE 23*23 ')
 1360 FORMAT(' *  BAR=     - REDUCE BAR LENGTH BY A MAX. OF',F7.2)
 1370 FORMAT(' *  CAMP,KING- THE CAMP-KING CONVERGER TO BE USED')
 1380 FORMAT(' *  EIGS     - PRINT ALL EIGENVALUES IN ITER')
 1390 FORMAT(' *  EIGINV   - USE HESSIAN EIGENVALUE REVERSION IN EF')
 1400 FORMAT(' *  NONR     - DO NOT USE NEWTON-RAPHSON STEP IN EF')
 1410 FORMAT(' *  ORIDE    - UNCONDITIONALLY, USE CALCULATED LAMDAS IN'
     1//' EF')
 1420 FORMAT(' *  HYPERFINE- HYPERFINE COUPLING CONSTANTS TO BE'
     1,' PRINTED')
 1430 FORMAT(' *  PL      - MONITOR CONVERGANCE IN DENSITY MATRIX')
 1440 FORMAT(' *  FILL=    - IN RHF CLOSED SHELL, FORCE M.O.',I3,' TO BE
     1 FILLED')
 1445 FORMAT(' *  FIELD    - APPLY A STATIC ELECTRIC FIELD')
 1450 FORMAT(' *  THERMO   - THERMODYNAMIC QUANTITIES TO BE CALCULATED')
 1460 FORMAT(' *  ROT      - SYMMETRY NUMBER OF',I3,' SPECIFIED')
 1470 FORMAT(' *  ITRY=    - DO A MAXIMUM OF',I6,' ITERATIONS FOR SCF')
 1480 FORMAT( //10X,' IMPOSSIBLE OPTION REQUESTED,')
 1490 FORMAT(' *  0SCF     - AFTER READING AND PRINTING DATA, STOP')
 1500 FORMAT(' *  STEP     - STEP-SIZE IN PATH=',F7.3)
 1510 FORMAT(' *  POINT    - NUMBER OF POINTS IN PATH=',I3)
      END
      LOGICAL FUNCTION MYWORD(KEYWRD,TESTWD)
      CHARACTER KEYWRD*(*), TESTWD*(*)
      MYWORD=.FALSE.
   10 J=INDEX(KEYWRD,TESTWD)
      IF(J.NE.0)THEN
   20    IF(KEYWRD(J:J).NE.' ')GOTO 30
         J=J+1
         GOTO 20
   30    MYWORD=.TRUE.
         DO 60 K=J,241
            IF(KEYWRD(K:K).EQ.'='.OR.KEYWRD(K:K).EQ.' ') THEN
C
C     CHECK FOR ATTACHED '=' SIGN
C
               J=K
               IF(KEYWRD(J:J).EQ.'=')GOTO 50
C
C     CHECK FOR SEPARATED '=' SIGN
C
               DO 40 J=K+1,241
                  IF(KEYWRD(J:J).EQ.'=') GOTO 50
   40          IF(KEYWRD(J:J).NE.' ')GOTO 10
C
C    THERE IS NO '=' SIGN ASSOCIATED WITH THIS KEYWORD
C
               GOTO 10
   50          KEYWRD(J:J)=' '
C
C   THERE MUST BE A NUMBER AFTER THE '=' SIGN, SOMEWHERE
C
               GOTO 20
            ENDIF
   60    KEYWRD(K:K)=' '
      ENDIF
      RETURN
      END
