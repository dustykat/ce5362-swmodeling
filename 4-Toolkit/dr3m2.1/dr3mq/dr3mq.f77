C     **********************************************************          A  10
C     *                                                        *          A  20
C     *     Q347--DISTRIBUTED ROUTING RUNOFF QUALITY MODEL     *          A  30
C     *                                                        *          A  40
C     **********************************************************          A  50
      REAL ISEG                                                           A  60
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    A  70
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        A  80
      COMMON /C3/ SSEFF(4),SSMIN(4),SSAREA(51),AKA(4),AKB(4)              A  90
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        A 100
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             A 110
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     A 120
      COMMON /F5/ HEAD1,HEAD2,HEAD3                                       A 130
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  A 140
     142)                                                                 A 150
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    A 160
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        A 170
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   A 180
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            A 190
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    A 200
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  A 210
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     A 220
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  A 230
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       A 240
      REAL                  I2CFSP                                      II062383
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             A 250
      INTEGER RODYS,TESTNO(180),HEAD1(120),HEAD2(60,2),HEAD3(60)          A 260
      WRITE (6,14)                                                        A 270
      NSEG=0                                                              A 280
C             SET SEQUENTIAL FILE NUMBER                                  A 290
      IFILED=16                                                         MM062783
      OPEN (UNIT=16,STATUS='SCRATCH',ACCESS='SEQUENTIAL',               II090183
     +      FORM='UNFORMATTED')                                         II090183
C             SET ARRAY LIMITS                                            A 310
      NDYS=7310                                                           A 320
      NDTS=1442                                                           A 330
      IUD=2881                                                            A 340
C             CALL PROGRAM SUBROUTINES                                    A 350
      CALL INPUT1                                                         A 360
      IF (IFILED.GT.0) REWIND IFILED                                      A 370
      IF (JRECDS.GT.0) CALL FILES                                         A 380
      IF (JRECDS.GT.0) CALL HEADR                                         A 390
      CALL INPUT2                                                         A 400
      IF (JRECQW.GT.0) CALL FILE27                                        A 410
      CALL CTCHMT                                                         A 420
      DELPLG=PTIME/60.                                                    A 430
      DELTAT=DT/60.                                                       A 440
      IF (NRES.GT.0) CALL RESVR(2,1)                                      A 450
      CALL INPUT3                                                         A 460
      CALL SIMQ                                                           A 470
C             PLOT MEAS. AND SIM. LOADS                                   A 480
      DO 12 J=1,NWQ                                                       A 490
      YMAX=0.0                                                            A 500
      N=0                                                                 A 510
      DO 11 I=1,NOFE                                                      A 520
      IF (SFLD(I,J).LE.0.0.OR.FLD(I,J).LE.0.0) GO TO 11                   A 530
      N=N+1                                                               A 540
      Q(N)=FLD(I,J)                                                       A 550
      R(N)=SFLD(I,J)                                                      A 560
      IF (Q(N).GT.YMAX) YMAX=Q(N)                                         A 570
      IF (R(N).GT.YMAX) YMAX=R(N)                                         A 580
   11 CONTINUE                                                            A 590
      IF (N.EQ.0) GO TO 12                                                A 600
      CALL PLT(Q,R,N,1,YMAX,I1,J,4)                                       A 610
      CALL PLT(Q,R,N,3,YMAX,I1,J,4)                                       A 620
      WRITE (6,13)                                                        A 630
   12 CONTINUE                                                            A 640
      STOP                                                                A 650
C                                                                         A 660
   13 FORMAT (16X,11HMEAS. LOADS)                                         A 670
   14 FORMAT (1H1,37X,51(1H*)/38X,1H*,14X,22HU.S. GEOLOGICAL SURVEY,13X,  A 680
     11H*/38X,51H*DISTRIBUTED ROUTING RAINFALL-RUNOFF-QUALITY MODEL*,/,3  A 690
     28X,1H*,13X,22HPRIME VERSION  5/30/84,14X,1H*,/,38X,51(1H*))         AML0584
      END                                                                 A 710-
      SUBROUTINE SIMQ                                                     B  10
      REAL ISEG                                                           B  20
      INTEGER RODYS,TESTNO(180),W,FLAG                                    B  30
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    B  40
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        B  50
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        B  60
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             B  70
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     B  80
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  B  90
     142)                                                                 B 100
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    B 110
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        B 120
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   B 130
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            B 140
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    B 150
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  B 160
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     B 170
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  B 180
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       B 190
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             B 200
      DATA FLAG/1/                                                        B 210
C             INITIALIZE VARIABLES                                        B 220
      NSTRMS=0                                                            B 230
      ISWEEP=0                                                            B 240
      NPAGE=1                                                             B 250
      NSS=1                                                               B 260
      IF (JRECDS.GT.0) IDEL=(PTIME+0.001)/DT                              B 270
      IF (IMODE.EQ.1) IDEL=1                                              B 280
      N1=1                                                                B 290
      N2=NWQ                                                              B 300
      DO 1 J=1,NWQ                                                        B 310
      DO 1 NC=1,NCAT                                                      B 320
      ATO(J,NC)=0.0                                                       B 330
      XO(J,NC)=0.0                                                        B 340
    1 CONTINUE                                                            B 350
      DO 2 I=1,NOFE                                                       B 360
      DO 2 J=1,NWQ                                                        B 370
      SFLD(I,J)=0.0                                                       B 380
    2 CONTINUE                                                            B 390
      AT=0.5                                                              B 400
      I1=1                                                                B 410
      KP=1                                                                B 420
      NSD=0                                                               B 430
      NFD=0                                                               B 440
      NFD1=0                                                              B 450
      W=0                                                                 B 460
C             BEGIN SIMULATION                                            B 470
      DO 21 IW=1,RODYS                                                    B 480
      W=W+1                                                               B 490
      IF (W.GT.RODYS) GO TO 21                                            B 500
C             FOR GAP IN RECORD, INITIALIZE ACCUMULATION  TO ZERO         B 510
      IF (W.NE.INDP(KP)) GO TO 5                                          B 520
      JW=W                                                                B 530
      LJ=KP+1                                                             B 540
      W=INDP(LJ)+1                                                        B 550
      LV=W-INDP(KP)                                                       B 560
      KP=KP+2                                                             B 570
      DO 3 I=1,NWQ                                                        B 580
      DO 3 NC=1,NCAT                                                      B 590
      XO(I,NC)=0.0                                                        B 600
      ATO(I,NC)=0.0                                                       B 610
    3 CONTINUE                                                            B 620
      DO 4 I=1,LV                                                         B 630
      CALL DATE                                                           B 640
      IF (ISS.LT.2) GO TO 4                                               B 650
      IF (NSS.GT.ISS) GO TO 4                                             B 660
      IF (JW.EQ.NSSDAY(1,NSS)) NSS=NSS+1                                  B 670
      JW=JW+1                                                             B 680
    4 CONTINUE                                                            B 690
    5 IF (W.GT.1) CALL DATE                                               B 700
      IF (DP(W).LT.0.0) GO TO 17                                          B 710
C             IF FLAG=0, DO STORM COMPUTATIONS                            B 720
C             IF FLAG=1, DO DAILY ACCOUNTING                              B 730
      IF (FLAG.NE.0) GO TO 16                                             B 740
      NFD1=0                                                              B 750
      NFD=NFD+1                                                           B 760
      AIK=K1(I1)                                                          B 770
      AT=AT-0.5+AIK/NDELS                                                 B 780
C             START OF STORM LOOP FOR SEQUENCE OF DAYS                    B 790
    6 IF (I1.GT.NOFE) GO TO 14                                            B 800
C             DETERMINE OUTPUT MODE                                       B 810
      JOUTPT=2                                                            B 820
      IF (KOUT(I1).EQ.0) JOUTPT=1                                         B 830
      IF (JOUTPT.EQ.1.AND.IPL(I1).EQ.0) JOUTPT=0                          B 840
      IF (JOUTPT.EQ.1.AND.IPL(I1).EQ.3) JOUTPT=0                          B 850
      LJ=K1(I1)                                                           B 860
      LK=K2(I1)                                                           B 870
      IF (JOUTPT.EQ.2) WRITE (6,22)                                       B 880
C             COMPUTE LAND-SURFACE LOADS AT START OF STORM                B 890
      DO 7 J=N1,N2                                                        B 900
      DO 7 NC=1,NCAT                                                      B 910
      LU=LAND(NC)                                                         B 920
      CAT=AT+ATO(J,NC)                                                    B 930
      XO(J,NC)=BK(1,J,LU)*(1.0-EXP(-BK(2,J,LU)*CAT))                      B 940
      EAT(I1,J)=CAT                                                       B 950
      XOS(I1,J)=XO(J,1)                                                   B 960
    7 CONTINUE                                                            B 970
      NWET=NDATE(I1,1)                                                    B 980
      IF (NWF.EQ.2) NWET=I1                                               B 990
C          ** COMPUTE CONCENTRATIONS FOR STORM I1 **                      B1000
      IF (JRECDS.GT.0) GO TO 9                                            B1010
C          ** WASHOFF BASED ON UD'S                                       B1020
      LV=LK-LJ+1                                                          B1030
      JJJ=0                                                               B1040
      DO 8 I=LJ,LK                                                        B1050
      JJJ=JJJ+1                                                           B1060
    8 FLW(JJJ)=UD(I)                                                      B1070
      CALL WASH(LV,N1,N2,1,1,QWINT,DAE,0)                                 B1080
      CALL CONC(LV,N1,N2,NWET)                                            B1090
      GO TO 11                                                            B1100
C          ** WASHOFF BASED ON DISCHARGE FROM                             B1110
C          DISTRIBUTED ROUTING RAINFALL-RUNOFF MODEL                      B1120
    9 CALL TRNSPT(N1,N2,NWET)                                             B1130
C             OUTPUT HYDROGRAPH FROM RAINFALL-RUNOFF MODEL                B1140
C             IS TO BE USED IN LOAD COMPUTATIONS                          B1150
      IF (IDEL.EQ.1) GO TO 11                                             B1160
      JJ=0                                                                B1170
      JJJ=0                                                               B1180
      DO 10 I=LJ,LK                                                       B1190
      JJJ=JJJ+1                                                           B1200
      JJ=JJ+IDEL                                                          B1210
   10 FLW(JJJ)=FLW(JJ)                                                    B1220
   11 CONTINUE                                                            B1230
      AT=0.0                                                              B1240
      DO 13 J=N1,N2                                                       B1250
      IF (J.GT.N1.AND.KOUT(I1).NE.0) WRITE (6,22)                         B1260
      DO 12 NC=1,NCAT                                                     B1270
      LU=LAND(NC)                                                         B1280
      ATO(J,NC)=(-1.0/BK(2,J,LU))*ALOG(1.0-XO(J,NC)/BK(1,J,LU))           B1290
   12 CONTINUE                                                            B1300
C             OUTPUT DETAILED SIMULATED DATA                              B1310
      CALL OUTPT(ICNT,IDEL,J,JOUTPT)                                      B1320
C             COMPUTE LOADS AND PERFORM DESIRED PLOTTING                  B1330
      CALL QWLOAD(J)                                                      B1340
   13 CONTINUE                                                            B1350
      I1=I1+1                                                             B1360
      NFD1=NFD1+1                                                         B1370
C             IF HAVE ANALYZED ALL EVENTS OF SET OF EVENTS, GO TO 1680    B1380
      IF (NF(NFD).EQ.NFD1) GO TO 14                                       B1390
      AIK=LK+1                                                            B1400
      BIK=K1(I1)                                                          B1410
      IF (AIK.EQ.BIK) KINIT=1                                             B1420
      AT=AT+(BIK-AIK)/NDELS                                               B1430
      GO TO 6                                                             B1440
   14 NFD=NFD+NFD1-1                                                      B1450
      IF (MOD(LK,NDELS).EQ.0) GO TO 15                                    B1460
      ALK=LK                                                              B1470
      LKT=LK/NDELS                                                        B1480
      AKT=(LKT+1.0)*NDELS                                                 B1490
      AT=AT+0.5+(AKT-ALK)/NDELS                                           B1500
   15 IF (W.GT.RODYS) GO TO 21                                            B1510
      FLAG=1                                                              B1520
      NFD1=0                                                              B1530
C             ** DAILY ACCOUNTING **                                      B1540
   16 CONTINUE                                                            B1550
      DPP=DP(W)                                                           B1560
      CALL DACC(DPP,N1,N2,W,NSS)                                          B1570
C             FINISHED WITH DAY                                           B1580
      GO TO 21                                                            B1590
C             BEGIN UNIT-TIME SIMULATION                                  B1600
   17 FLAG=0                                                              B1610
C             CHECK FOR STREET SWEEPING                                   B1620
      NPAGE=1                                                             B1630
      IF (ISS.NE.1) GO TO 18                                              B1640
      NSS=NSS+1                                                           B1650
      IF (NSS.GE.ISSFRQ) NSS=0                                            B1660
      GO TO 19                                                            B1670
   18 IF (ISS.LT.2) GO TO 19                                              B1680
      IF (NSS.GT.ISS) GO TO 19                                            B1690
      IF (W.NE.NSSDAY(1,NSS)) GO TO 19                                    B1700
      NSS=NSS+1                                                           B1710
   19 CONTINUE                                                            B1720
      NFD1=NFD1+1                                                         B1730
      IF (IFILED.EQ.0) GO TO 21                                           B1740
C          IF 1ST DAY OF SEQUENCE OF STORM DAYS THEN, READ DISCHARGE      B1750
C          DATA FROM IFILED                                               B1760
      IF (NFD1.GT.1) GO TO 21                                             B1770
      NSD=NSD+1                                                           B1780
      READ (IFILED) K4D,(UD(I),I=1,K4D)                                   B1790
      K4DP=K4D+1                                                          B1800
      DO 20 I=K4DP,IUD                                                    B1810
   20 UD(I)=0.0                                                           B1820
      CALL STORM(I1)                                                      B1830
   21 CONTINUE                                                            B1840
C          END OF SIMULATION PERIOD                                       B1850
      IF (IFILED.GT.0) REWIND IFILED                                      B1860
C          SUMMARIZE ALL STORM DATA                                       B1870
      IF (IFILED.GT.0) CALL RITE1                                         B1880
      CALL RITE2(N1,N2)                                                   B1890
      RETURN                                                              B1900
C                                                                         B1910
   22 FORMAT (1H1)                                                        B1920
      END                                                                 B1930-
      SUBROUTINE DACC(DPP,N1,N2,W,NSS)                                    C  10
C             THIS SUBROUTINE IS FOR DAILY ACCOUNTING                     C  20
      DIMENSION DLYWSH(4)                                                 C  30
      INTEGER RODYS,W                                                     C  40
      REAL I2CFSP,ISEG                                                    C  50
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    C  60
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        C  70
      COMMON /C3/ SSEFF(4),SSMIN(4),SSAREA(51),AKA(4),AKB(4)              C  80
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             C  90
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    C 100
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    C 110
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     C 120
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  C 130
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             C 140
      DPP=DPP-AIMP                                                        C 150
C            CHECK FOR STREET SWEEPING                                    C 160
      IF (ISS.LT.1) GO TO 2                                               C 170
      IF (ISS.NE.1) GO TO 1                                               C 180
      NSS=NSS+1                                                           C 190
      IF (NSS.LT.ISSFRQ) GO TO 2                                          C 200
      ISWEEP=1                                                            C 210
      NSS=0                                                               C 220
      GO TO 2                                                             C 230
    1 IF (NSS.GT.ISS) GO TO 2                                             C 240
      IF (W.NE.NSSDAY(1,NSS)) GO TO 2                                     C 250
      NSS=NSS+1                                                           C 260
      ISWEEP=1                                                            C 270
    2 CONTINUE                                                            C 280
      IF (DPP.LE.0.0) GO TO 6                                             C 290
C             ADJ. LOADS FOR DAILY PPT.                                   C 300
      ISWEEP=0                                                            C 310
      DO 3 J=N1,N2                                                        C 320
      DLYWSH(J)=0.0                                                       C 330
      DO 3 NC=1,NCAT                                                      C 340
      LU=LAND(NC)                                                         C 350
      AKD=BK(5,J,LU)                                                      C 360
      CAT=AT+ATO(J,NC)                                                    C 370
      XOTMP=BK(1,J,LU)*(1.0-EXP(-BK(2,J,LU)*CAT))                         C 380
      DELTAP=XOTMP*(1.0-EXP(-AKD*DPP))                                    C 390
      XO(J,NC)=XOTMP-DELTAP                                               C 400
      DLYWSH(J)=DLYWSH(J)+DELTAP*EFF(NC)                                  C 410
    3 CONTINUE                                                            C 420
      IF (ILOAD.NE.1) GO TO 8                                             C 430
C             OUTPUT DAILY LOADS, IF DESIRED                              C 440
      IF (NPAGE.EQ.0) GO TO 4                                             C 450
      WRITE (6,12)                                                        C 460
      NPAGE=0                                                             C 470
    4 CONTINUE                                                            C 480
      DO 5 NW=N1,N2                                                       C 490
      IF (NW.EQ.N1) WRITE (6,11) IMO,IDY,IYR,IPA(NW),IPB(NW),DLYWSH(NW)   C 500
      IF (NW.GT.N1) WRITE (6,13) IPA(NW),IPB(NW),DLYWSH(NW)               C 510
    5 CONTINUE                                                            C 520
      GO TO 8                                                             C 530
    6 AT=AT+1.0                                                           C 540
      IF (ISWEEP.EQ.0) RETURN                                             C 550
C             ADJUST LAND-SURFACE LOADS FOR STREET SWEEPING               C 560
      AT=AT-1.0                                                           C 570
      ISWEEP=0                                                            C 580
      IF (ILOAD.EQ.1) WRITE (6,10) IMO,IDY,IYR                            C 590
      DO 7 J=N1,N2                                                        C 600
      DO 7 NC=1,NCAT                                                      C 610
      LU=LAND(NC)                                                         C 620
      CAT=AT+ATO(J,NC)                                                    C 630
      XO(J,NC)=BK(1,J,LU)*(1.0-EXP(-BK(2,J,LU)*CAT))                      C 640
      IF (XO(J,NC).LE.SSMIN(J)) GO TO 7                                   C 650
      XOTMP=XO(J,NC)                                                      C 660
      XOTMP=XOTMP-(XOTMP-SSMIN(J))*SSEFF(J)                               C 670
      XO(J,NC)=(1.-SSAREA(NC))*XO(J,NC)+XOTMP*SSAREA(NC)                  C 680
    7 CONTINUE                                                            C 690
    8 DO 9 J=N1,N2                                                        C 700
      DO 9 NC=1,NCAT                                                      C 710
      LU=LAND(NC)                                                         C 720
      ATO(J,NC)=(-1.0/BK(2,J,LU))*ALOG(1.0-XO(J,NC)/BK(1,J,LU))           C 730
    9 CONTINUE                                                            C 740
      AT=1.0                                                              C 750
      RETURN                                                              C 760
C                                                                         C 770
   10 FORMAT (1H0,2HON,I3,1H/,I2,1H/,I2,19H STREETS WERE SWEPT)           C 780
   11 FORMAT (1H0,2HON,I3,1H/,I2,1H/,I2,41H SIMULATED IMPERVIOUS AREA WA  C 790
     1SHOFF OF :  ,2A3,4H WAS,F8.2,7H POUNDS)                             C 800
   12 FORMAT (1H1)                                                        C 810
   13 FORMAT (1H ,52X,2A3,4H WAS,F8.2,7H POUNDS)                          C 820
      END                                                                 C 830-
      SUBROUTINE DATE                                                     D  10
      DIMENSION IDAYS(12)                                                 D  20
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             D  30
      DATA IDAYS/31,28,31,30,31,30,31,31,30,31,30,31/                     D  40
      IDY=IDY+1                                                           D  50
      IF (IDAYS(IMO).GE.IDY) RETURN                                       D  60
      IF (IMO.NE.2) GO TO 1                                               D  70
      IF (MOD(IYR,4).NE.0) GO TO 1                                        D  80
      IF (IDY.LE.29) RETURN                                               D  90
    1 IMO=IMO+1                                                           D 100
      IDY=1                                                               D 110
      IF (IMO.LE.12) RETURN                                               D 120
      IMO=1                                                               D 130
      IYR=IYR+1                                                           D 140
      RETURN                                                              D 150
      END                                                                 D 160-
      SUBROUTINE WASH(LV,N1,N2,NC,LU,DTIME,DAET,LBS)                      E  10
C             IMPERVIOUS AREA WASHOFF ROUTINE                             E  20
      INTEGER TESTNO(180)                                                 E  30
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  E  40
     142)                                                                 E  50
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    E  60
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   E  70
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            E  80
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  E  90
C             CONVF CONVERTS CUBIC FT TO INCHES OVER CONTRIB. AREA        E 100
C             12*640/5280**2=2.754821E-4                                  E 110
      CONVF=2.754821E-4/DAET                                              E 120
      CONVF2=3600./DTIME                                                  E 130
      DO 4 JJ=1,LV                                                        E 140
      IF (JJ.EQ.1) UDI=FLW(1)                                             E 150
      IF (JJ.GT.1) UDI=FLW(JJ-1)                                          E 160
      RVCF=0.5*(FLW(JJ)+UDI)*DTIME                                        E 170
      RVIN=RVCF*CONVF                                                     E 180
      RRATE=RVIN*CONVF2                                                   E 190
      DO 3 J=N1,N2                                                        E 200
      IF (RVCF.GT.0.00001) GO TO 1                                        E 210
      CON(J,JJ)=0.0                                                       E 220
      GO TO 3                                                             E 230
    1 CONTINUE                                                            E 240
      IF (BK(3,J,LU).GT.0.0) WSHOFF=XO(J,NC)*(1.0-EXP(-BK(3,J,LU)*RVIN))  E 250
      IF (BK(3,J,LU).LT.0.0) WSHOFF=XO(J,NC)*(1.0-EXP(BK(3,J,LU)*RVIN*RR  E 260
     1ATE))                                                               E 270
      IF (BK(4,J,LU).LE.0.001) GO TO 2                                    E 280
      AVAIL=BK(4,J,LU)*RRATE                                              E 290
      IF (AVAIL.LT.1.0) WSHOFF=WSHOFF*AVAIL                               E 300
    2 XO(J,NC)=XO(J,NC)-WSHOFF                                            E 310
      CON(J,JJ)=WSHOFF*DAET                                               E 320
      IF (LBS.GT.0) GO TO 3                                               E 330
C             LBS/CUBIC FT * 16018.9 = MG/L                               E 340
      CON(J,JJ)=CON(J,JJ)/RVCF*16018.9                                    E 350
      IF (CF1(J).LT.1.0E-6) CON(J,JJ)=CON(J,JJ)*1000.                     E 360
    3 CONTINUE                                                            E 370
    4 CONTINUE                                                            E 380
      RETURN                                                              E 390
      END                                                                 E 400-
      SUBROUTINE CONC(LV,N1,N2,NWET)                                      F  10
C             THIS SUBROUTINE CONVERTS AVERAGE CONCS.                     F  20
C             OVER TIME INTERVALS TO POINT CONCS.                         F  30
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  F  40
     142)                                                                 F  50
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   F  60
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  F  70
      DO 3 J=N1,N2                                                        F  80
      WET=WFALL(J,NWET)                                                   F  90
      DO 2 JJ=1,LV                                                        F 100
      IF (JJ.EQ.LV) GO TO 2                                               F 110
      IF (FLW(JJ).GT.0.0) GO TO 1                                         F 120
      CON(J,JJ)=0.0                                                       F 130
      GO TO 2                                                             F 140
    1 CONCEN=0.5*(CON(J,JJ)+CON(J,JJ+1))                                  F 150
C             ADD WETFALL CONTRIBUTION                                    F 160
      CON(J,JJ)=CONCEN+WET                                                F 170
    2 CONTINUE                                                            F 180
      CON(J,LV)=0.0                                                       F 190
      IF (FLW(LV).LE.0.0) GO TO 3                                         F 200
C            SET LAST POINT CONC. = LAST INTERVAL CONC. + WETFALL         F 210
      CON(J,LV)=CON(J,LV)+WET                                             F 220
    3 CONTINUE                                                            F 230
      RETURN                                                              F 240
      END                                                                 F 250-
      SUBROUTINE PERV(I,LK,N1,N2,DTIME,NWET)                              G  10
C             PERVIOUS AREA WASHOFF ROUTINE                               G  20
      INTEGER TESTNO(180)                                                 G  30
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        G  40
      COMMON /C3/ SSEFF(4),SSMIN(4),SSAREA(51),AKA(4),AKB(4)              G  50
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        G  60
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  G  70
     142)                                                                 G  80
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   G  90
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            G 100
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  G 110
      CONV=DTIME/43560./2.0                                               G 120
      Q(1)=FLW(1)*CONV                                                    G 130
      SUMVOL=Q(1)*Q(1)                                                    G 140
      TOTVOL=Q(1)                                                         G 150
      QPK=FLW(1)                                                          G 160
      DO 1 IV=2,LK                                                        G 170
      Q(IV)=(FLW(IV)+FLW(IV-1))*CONV                                      G 180
      IF (Q(IV).LE.0.0) GO TO 1                                           G 190
      SUMVOL=SUMVOL+Q(IV)*Q(IV)                                           G 200
      TOTVOL=TOTVOL+Q(IV)                                                 G 210
      IF (FLW(IV).GT.QPK) QPK=FLW(IV)                                     G 220
    1 CONTINUE                                                            G 230
      TMASS=PARAM(I,3)*(TOTVOL*QPK)**PARAM(I,4)                           G 240
      TERM=TMASS*735.48/SUMVOL                                            G 250
      DO 3 IV=1,LK                                                        G 260
      SED=Q(IV)*TERM                                                      G 270
      DO 3 JJJ=N1,N2                                                      G 280
      IF (SED.GT.0.0) GO TO 2                                             G 290
      CON(JJJ,IV)=0.0                                                     G 300
      GO TO 3                                                             G 310
    2 CONC=AKA(JJJ)+AKB(JJJ)*SED                                          G 320
      IF (CF1(JJJ).LT.1.0E-6) CONC=CONC*1000.                             G 330
      CON(JJJ,IV)=CONC+WFALL(JJJ,NWET)                                    G 340
    3 CONTINUE                                                            G 350
      RETURN                                                              G 360
      END                                                                 G 370-
      SUBROUTINE TRNSPT(N1,N2,NWET)                                       H  10
C             SET UP FLOW AND CONC. ARRAYS FOR CONSTITUENT ROUTING        H  20
      INTEGER RODYS,HEAD1(120),HEAD2(60,2),HEAD3(60)                      H  30
      REAL ISEG,I2CFSP                                                    H  40
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    H  50
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        H  60
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        H  70
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     H  80
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  H  90
     142)                                                                 H 100
      COMMON /F5/ HEAD1,HEAD2,HEAD3                                       H 110
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    H 120
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  H 130
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     H 140
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  H 150
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             H 160
      INTVAL=(PTIME+0.001)/DT                                             H 170
      LJ=1                                                                H 180
      LV=(K2(I1)-K1(I1)+1)                                                H 190
      LK=LV*INTVAL                                                        H 200
      ICT=LK                                                              H 210
      NSTRMS=NSTRMS+1                                                     H 220
      IF (LK.NE.HEAD2(NSTRMS,2)) GO TO 34                                 H 230
      NSTRCD=HEAD2(NSTRMS,1)                                              H 240
      NRPSEG=LK/120+1-(1-MIN0(1,MOD(LK,120)))                             H 250
      NC=0                                                                H 260
      IRS=0                                                               H 270
      DO 33 I=1,NSEG                                                      H 280
      IF (ITYPE(I).EQ.2) GO TO 33                                         H 290
C          INITIALIZE ARRAYS TO ZERO                                      H 300
      JPERV=0                                                             H 310
      DO 3 L=1,LK                                                         H 320
      FLAT(L)=0.0                                                         H 330
      FLW(L)=0.0                                                          H 340
      IF (NC.GT.0.AND.IMODE.EQ.2) GO TO 1                                 H 350
      FUP(L)=0.0                                                          H 360
    1 DO 2 J=N1,N2                                                        H 370
      QWLAT(J,L)=0.0                                                      H 380
      CON(J,L)=0.0                                                        H 390
      IF (NC.GT.0.AND.IMODE.EQ.2) GO TO 2                                 H 400
      QWUP(J,L)=0.0                                                       H 410
    2 CONTINUE                                                            H 420
    3 CONTINUE                                                            H 430
      IF (ITYPE(I).GT.2) GO TO 15                                         H 440
      NC=NC+1                                                             H 450
      LU=LAND(NC)                                                         H 460
      DAET=EFF(NC)                                                        H 470
C          COMPUTE IMPERVIOUS AREA LATERAL INFLOW                         H 480
      DO 6 J=1,4                                                          H 490
      IF (JLAT(I,J)) 6,6,4                                                H 500
    4 JJ=JLAT(I,J)                                                        H 510
      IF (PARAM(JJ,2).LE.0.001) JPERV=1                                   H 520
      IF (PARAM(JJ,2).LE.0.001) GO TO 6                                   H 530
      IRECD=NSTRCD+NRPSEG*(JJ-1)                                          H 540
      III =  LK/120                                                     II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 5125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KK2.GT.1442) KKK2 = 1442                                    II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        READ (IFILE,REC=IRECDJ) (Q(IV),IV=KKK1,KKK2)                    II062383
 5125 CONTINUE                                                          II062383
C     READ (IFILE'IRECD) (Q(IV),IV=1,LK)                                MM062383
C            CONVERT CFS/FT TO CFS                                        H 560
      DO 5 IV=1,LK                                                        H 570
    5 FLW(IV)=FLW(IV)+Q(IV)*FLGTH(I)                                      H 580
    6 CONTINUE                                                            H 590
      IF (DAET.LE.0.0) GO TO 7                                            H 600
C          COMPUTE AVERAGE INTERVAL CONCS. OF CONSTITUENTS                H 610
C          IN IMPERVIOUS AREA LATERAL INFLOW                              H 620
      CALL WASH(LK,N1,N2,NC,LU,DTS,DAET,0)                                H 630
C             CONVERT TO POINT CONCS.                                     H 640
      CALL CONC(LK,N1,N2,NWET)                                            H 650
    7 DO 8 IV=1,LK                                                        H 660
      FLAT(IV)=FLW(IV)                                                    H 670
      DO 8 JJJ=N1,N2                                                      H 680
      QWLAT(JJJ,IV)=CON(JJJ,IV)                                           H 690
    8 CONTINUE                                                            H 700
C             COMPUTE PERVIOUS LATERAL INFLOW                             H 710
      IF (JPERV.EQ.0) GO TO 15                                            H 720
      DO 9 L=1,LK                                                         H 730
    9 FLW(L)=0.0                                                          H 740
      DO 12 J=1,4                                                         H 750
      IF (JLAT(I,J)) 12,12,10                                             H 760
   10 JJ=JLAT(I,J)                                                        H 770
      IF (PARAM(JJ,2).GT.0.001) GO TO 12                                  H 780
      IRECD=NSTRCD+NRPSEG*(JJ-1)                                          H 790
      III = LK/120                                                      II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 6125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KKK2.GT.1442) KKK2 = 1442                                   II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        READ (IFILE,REC=IRECDJ) (Q(IV),IV=KKK1,KKK2)                    II062383
 6125 CONTINUE                                                          II062383
C     READ (IFILE'IRECD) (Q(IV),IV=1,LK)                                MM062383
      DO 11 IV=1,LK                                                       H 810
   11 FLW(IV)=FLW(IV)+Q(IV)*FLGTH(I)                                      H 820
   12 CONTINUE                                                            H 830
C             COMPUTE CONCS. IN PERVIOUS AREA LATERAL INFLOW              H 840
      CALL PERV(I,LK,N1,N2,DTS,NWET)                                      H 850
C             ADD PERV. + IMP. FLOW AND CONCS.                            H 860
      DO 14 IV=1,LK                                                       H 870
      QSUM=FLAT(IV)+FLW(IV)                                               H 880
      DO 13 JJJ=N1,N2                                                     H 890
   13 QWLAT(JJJ,IV)=(QWLAT(JJJ,IV)*FLAT(IV)+CON(JJJ,IV)*FLW(IV))/QSUM     H 900
      FLAT(IV)=QSUM                                                       H 910
   14 CONTINUE                                                            H 920
   15 CONTINUE                                                            H 930
      IF (IMODE.NE.2) GO TO 16                                            H 940
C             DISTRIBUTED (NO ROUTING RUN)                                H 950
      IF (ITYPE(I).GT.1) GO TO 33                                         H 960
      CALL NOROUT(I,LK,N1,N2)                                             H 970
      GO TO 33                                                            H 980
C             COUNT NUMBER OF UPSTREAM SEGMENTS                           H 990
   16 NUP=0                                                               H1000
      DO 17 J=1,3                                                         H1010
   17 IF (JUP(I,J).GT.0) NUP=NUP+1                                        H1020
      IF (NUP.EQ.0) GO TO 26                                              H1030
C             COMPUTE UPSTREAM FLOW AND CONCENTRATIONS                    H1040
      DO 24 J=1,3                                                         H1050
      IF (JUP(I,J)) 24,24,18                                              H1060
   18 JJ=JUP(I,J)                                                         H1070
      IRECD=NSTRCD+NRPSEG*(JJ-1)                                          H1080
      III = LK/120                                                      II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 7125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KKK2.GT.1442) KKK2 = 1442                                   II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        READ (IFILE,REC=IRECDJ) (FLW(IV),IV=KKK1,KKK2)                  II062383
 7125 CONTINUE                                                          II062383
C     READ (IFILE'IRECD) (FLW(IV),IV=1,LK)                              MM062383
      DO 19 IV=1,LK                                                       H1100
   19 FUP(IV)=FUP(IV)+FLW(IV)                                             H1110
      DO 23 JJJ=N1,N2                                                     H1120
      IRECQ=1+(JJJ-1)*NRPSEG*NSEG+(JJ-1)*NRPSEG                           H1130
      III = LK/120                                                      II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 4125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KKK2.GT.1442) KKK2 = 1442                                   II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        READ (IFILE,REC=IRECDJ) (Q(IV),IV=KKK1,KKK2)                    II062383
 4125 CONTINUE                                                          II062383
C     READ (IFILEQ'IRECQ) (Q(IV),IV=1,LK)                               MM062383
      IF (NUP.LT.2) GO TO 21                                              H1150
      DO 20 L=1,LK                                                        H1160
   20 QWUP(JJJ,L)=QWUP(JJJ,L)+Q(L)*FLW(L)                                 H1170
      GO TO 23                                                            H1180
   21 CONTINUE                                                            H1190
      DO 22 L=1,LK                                                        H1200
   22 QWUP(JJJ,L)=Q(L)                                                    H1210
   23 CONTINUE                                                            H1220
   24 CONTINUE                                                            H1230
      IF (NUP.LT.2) GO TO 26                                              H1240
      DO 25 IV=1,LK                                                       H1250
      DO 25 JJJ=N1,N2                                                     H1260
      IF (FUP(IV).LE.0.0) GO TO 25                                        H1270
      QWUP(JJJ,IV)=QWUP(JJJ,IV)/FUP(IV)                                   H1280
   25 CONTINUE                                                            H1290
   26 CONTINUE                                                            H1300
      IF (ITYPE(I).NE.4) GO TO 28                                         H1310
C             MASS BALANCE AT NODAL SEGMENT                               H1320
      DO 27 IV=1,LK                                                       H1330
      DO 27 JJJ=N1,N2                                                     H1340
      CON(JJJ,IV)=QWUP(JJJ,IV)+PARAM(I,JJJ)                               H1350
   27 CONTINUE                                                            H1360
      GO TO 31                                                            H1370
C             READ DOWNSTREAM FLOW                                        H1380
   28 IRECD=NSTRCD+NRPSEG*(I-1)                                           H1390
      III = LK/120                                                      II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 8125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KKK2.GT.1442) KKK2 = 1442                                   II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        READ (IFILE,REC=IRECDJ) (FLW(IV),IV=KKK1,KKK2)                  II062383
 8125 CONTINUE                                                          II062383
C     READ (IFILE'IRECD) (FLW(IV),IV=1,LK)                              MM062383
C             DO RESERVOIR ROUTING                                        H1410
      IF (ITYPE(I).NE.3) GO TO 30                                         H1420
      IRS=IRS+1                                                           H1430
      IF (NUP.GT.0) GO TO 29                                              H1440
      WRITE (6,37)                                                        H1450
      STOP                                                                H1460
   29 CALL RESVR(4,IRS)                                                   H1470
      GO TO 31                                                            H1480
C             PERFORM LAGRANGIAN TRANSPORT                                H1490
   30 CALL LNGRN(I,LK,N1,N2)                                              H1500
C             SAVE OUTFLOW CONC. ARRAY                                    H1510
   31 DO 32 JJJ=N1,N2                                                     H1520
      IRECQ=1+(JJJ-1)*NRPSEG*NSEG+(I-1)*NRPSEG                            H1530
      III = LK/120                                                      II062383
      IF (MOD(LK,120).NE.0) III = III + 1                               II062383
      DO 3125 KKK = 1,III                                               II062383
        KKK2 =KKK*120                                                   II062383
        KKK1 = KKK2 - 119                                               II062383
        IF (KKK2.GT.1442) KKK2 = 1442                                   II062383
        IRECDJ = IRECD + KKK - 1                                        II062383
        WRITE(IFILEQ,REC=IRECDJ) (CON(JJJ,IV),IV=KKK1,KKK2)             II062383
 3125 CONTINUE                                                          II062383
C     WRITE (IFILEQ'IRECQ) (CON(JJJ,IV),IV=1,LK)                        MM062383
C             LIST SEGMENT CONCENTRATIONS IF DESIRED                      H1550
      IF (KOUT(I1).EQ.0) GO TO 32                                         H1560
      IF (IPR(I).EQ.0) GO TO 32                                           H1570
      JSEG=I                                                              H1580
      CALL OUTPT(JSEG,INTVAL,JJJ,3)                                       H1590
      IF (JJJ.EQ.N2) WRITE (6,36)                                         H1600
   32 CONTINUE                                                            H1610
   33 CONTINUE                                                            H1620
      RETURN                                                              H1630
   34 WRITE (6,35) I1                                                     H1640
      STOP                                                                H1650
C                                                                         H1660
   35 FORMAT (1H1,35HNUMBER OF TIME INCREMENTS FOR STORM,I3,42H DOES NOT  H1670
     1 MATCH BETWEEN DR3M AND DR3M-QUAL)                                  H1680
   36 FORMAT (1H1)                                                        H1690
   37 FORMAT (1H1,39HRESERVOIR MUST HAVE AN UPSTREAM SEGMENT)             H1700
      END                                                                 H1710-
      SUBROUTINE NOROUT(I,LK,N1,N2)                                       I  10
C             DETERMINE CONCS. FOR DIST. (NO ROUTING) RUN                 I  20
C             FUP=SUM OF FLOWS                                            I  30
C             QWUP=SUM OF FLOW*CONC.                                      I  40
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    I  50
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  I  60
     142)                                                                 I  70
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  I  80
      REAL ISEG                                                           I  90
      DO 2 L=1,LK                                                         I 100
      FUP(L)=FUP(L)+FLAT(L)                                               I 110
      DO 1 JJJ=N1,N2                                                      I 120
      QWUP(JJJ,L)=QWUP(JJJ,L)+FLAT(L)*QWLAT(JJJ,L)                        I 130
      IF (I.LT.NSEG) GO TO 1                                              I 140
      IF (FUP(L).LE.0.0) GO TO 1                                          I 150
      CON(JJJ,L)=QWUP(JJJ,L)/FUP(L)                                       I 160
    1 CONTINUE                                                            I 170
      FLW(L)=FUP(L)                                                       I 180
    2 CONTINUE                                                            I 190
      RETURN                                                              I 200
      END                                                                 I 210-
      SUBROUTINE LNGRN(I,LK,N1,N2)                                        J  10
C                                                                         J  20
C     SUBROUTINE LNGRN IS THE DRIVE SUBROUTINE FOR THE LAGRANGIAN         J  30
C     CHANNEL TRANSPORT. A CALL TO LNGRN ROUTES UP TO FOUR CONSTITUENTS   J  40
C     THROUGH A SEGMENT.                                                  J  50
C                                                                         J  60
      REAL ISEG,M,CLAT(4),CA(4),CB(4),CC(4),CD(4)                         J  70
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    J  80
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        J  90
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  J 100
     142)                                                                 J 110
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  J 120
      REAL                  I2CFSP                                      II062383
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             J 130
      COMMON /LGN1/ XL,DTS1,JSEG,ALPHA,M,QLAT,CLAT,CC,J,N1T,N2T           J 140
      DATA CA,CB/0.,0.,0.,0.,0.,0.,0.,0./                                 J 150
C                                                                         J 160
C     ..... SET UP COMMON VARIABLES IN LGN1 .....                         J 170
      XL=FLGTH(I)                                                         J 180
      DTS1=DTS                                                            J 190
      ALPHA=PARAM(I,1)                                                    J 200
      M=PARAM(I,2)                                                        J 210
      JSEG=I                                                              J 220
      N1T=N1                                                              J 230
      N2T=N2                                                              J 240
C                                                                         J 250
C     ..... DEFINE INITIAL CONDITIONS FOR SEGMENT .....                   J 260
      CALL LAGRN1(0.0,0.0,CA,CB)                                          J 270
C                                                                         J 280
C     ..... START TIME LOOP .....                                         J 290
      DO 3 J=1,LK                                                         J 300
      QLAT=FLAT(J)/XL                                                     J 310
      DO 1 II=N1,N2                                                       J 320
      CLAT(II)=QWLAT(II,J)                                                J 330
    1 CC(II)=QWUP(II,J)                                                   J 340
C                                                                         J 350
C     ..... PERFORM TRANSPORT COMPUTATIONS FOR ONE TIME STEP ,,,,,        J 360
      CALL LAGRN(FUP(J),FLW(J),CD)                                        J 370
      DO 2 II=N1,N2                                                       J 380
    2 CON(II,J)=CD(II)                                                    J 390
    3 CONTINUE                                                            J 400
C                                                                         J 410
      RETURN                                                              J 420
      END                                                                 J 430-
      SUBROUTINE LAGRN1(QA,QB,CA,CB)                                      K  10
C                                                                         K  20
C     SUBROUTINE LAGRN1 MUST BE CALLED ONCE PRECEDING TRANSPORT           K  30
C     COMPUTATIONS TO DEFINE INITIAL CONDITIONS FOR A SEGMENT             K  40
C     (THIS SUBROUTINE ACCEPTS A SEGMENT HAVING AN INITIAL FLOW EVEN      K  50
C     THOUGH WITH THE MODELS PRESENT STRUCTURE THIS COULD NOT OCCUR)      K  60
C                                                                         K  70
      DIMENSION PV(999), PC(4,999), CLAT(4), CA(4), CB(4), CC(4)         AML0584
      REAL M                                                              K  90
      COMMON /LGN/ PV,PC,NPRCLS                                           K 100
      COMMON /LGN1/ XL,DTS,ISEG,ALPHA,M,QLAT,CLAT,CC,J,N1,N2              K 110
      COMMON /LGN2/ Q1,Q2,Q3,Q4                                           K 120
C                                                                         K 130
C     ..... DEFINE INITIAL CONDITIONS FOR TRANSPORT .....                 K 140
      NPRCLS=2                                                            K 150
      IF (QA.EQ.0.) GO TO 1                                               K 160
      AA=(QA/ALPHA)**(1./M)                                               K 170
      GO TO 2                                                             K 180
    1 AA=0.0                                                              K 190
    2 IF (QB.EQ.0.0) GO TO 3                                              K 200
      AB=(QB/ALPHA)**(1./M)                                               K 210
      GO TO 4                                                             K 220
    3 AB=0.0                                                              K 230
    4 PV(1)=.25*(AA+AB)*XL                                                K 240
      PV(2)=PV(1)                                                         K 250
      DO 5 I=1,N2                                                         K 260
      PC(I,1)=CA(I)                                                       K 270
      PC(I,2)=CB(I)                                                       K 280
    5 CONTINUE                                                            K 290
      Q1=QA                                                               K 300
      Q2=QB                                                               K 310
      RETURN                                                              K 320
      END                                                                 K 330-
      SUBROUTINE LAGRN(QC,QD,CD)                                          L  10
C                                                                         L  20
C     SUB LAGRN - PLUG FLOW LAGRANGIAN TRANSPORT WITH LATERAL INFLOW      L  30
C                                                                         L  40
C     ..... DEFINITION OF VARIABLES .....                                 L  50
C     PV(K)  - VOLUME OF PARCEL K (CUBIC FEET)                            L  60
C     PC(I,K)- CONCENTRATION OF CONSTITUENT I IN PARCEL K (MG/L)          L  70
C     XL     - LENGTH OF SEGMENT (FEET)                                   L  80
C     DTS    - TIME STEP SIZE (SECONDS)                                   L  90
C     CA     - CONC AT U/S END OF SEGMENT AT OLD TIME STEP (MG/L)         L 100
C     CC     - CONC AT U/S END OF SEGMENT AT NEW TIME STEP (MG/L)         L 110
C     CD     - CONC AT D/S END OF SEGMENT AT NEW TIME STEP (MG/L)         L 120
C     Q1,Q2  - FLOW AT U/S AND D/S ENDS OF SEGMENT AT OLD TIME STEP(CFS)  L 130
C     Q3,Q4  - FLOW AT U/S AND D/S ENDS OF SEGMENT AT NEW TIME STEP(CFS)  L 140
C     U2,U4  - VEL'S AT D/S END OF SEGMENT AT OLD AND NEW TIME STEP(FPS)  L 150
C     NPRCLS - NUMBER OF PARCELS IN THE SEGMENT DURING A GIVEN TIME STEP  L 160
C     UAVG   - AVERAGE VELOCITY IN SEGMENT (USING ALL 4 CORNERS) (FPS)    L 170
C     DX     - DISTANCE IMAGINARY PARCEL BOUNDARY MOVES (FT)              L 180
C                                                                         L 190
      DIMENSION PV(999), PC(4,999), CLAT(4), CA(4), CC(4), CD(4), PCN(4) AML0584
      REAL M                                                              L 210
      COMMON /LGN/ PV,PC,NPRCLS                                           L 220
      COMMON /LGN1/ XL,DTS,ISEG,ALPHA,M,QLAT,CLAT,CC,J,N1,N2              L 230
      COMMON /LGN2/ Q1,Q2,Q3,Q4                                           L 240
      Q3=QC                                                               L 250
      Q4=QD                                                               L 260
      IF (J.NE.1) GO TO 4                                                 L 270
      IF (Q1.NE.0.) GO TO 2                                               L 280
      DO 1 I=1,N2                                                         L 290
    1 CA(I)=CC(I)                                                         L 300
      GO TO 4                                                             L 310
    2 CONTINUE                                                            L 320
      DO 3 I=1,N2                                                         L 330
    3 CA(I)=PC(I,1)                                                       L 340
    4 IF (Q1.EQ.0.) CALL ZEROS(CD,*6,*17,*23)                           MM062383
C                                                                         L 360
C     ..... ADD A NEW PARCEL TO THE SEGMENT AND ASSIGN IT THE VOLUME AND  L 370
C           CONCENTRATION OF FLOW ENTERING FROM U/S END .....             L 380
      PVN=.5*(Q1+Q3)*DTS                                                  L 390
      DO 5 I=N1,N2                                                        L 400
    5 PCN(I)=.5*(CA(I)+CC(I))                                             L 410
      VOLX=0.0                                                            L 420
      GO TO 10                                                            L 430
C     SPECIAL CASE OF ZERO U/S BOUNDARY CONDITION (Q1=Q3=0)               L 440
    6 IF (QLAT.EQ.0.) GO TO 17                                            L 450
      UAVG=.25*(UX(Q2)+UX(Q4))                                            L 460
      DX=UAVG*DTS                                                         L 470
      IF (DX.GT.XL) GO TO 7                                               L 480
      PVN=.5*DX*QLAT*DTS                                                  L 490
      GO TO 8                                                             L 500
    7 PVN=.5*XL*QLAT*(XL/UAVG)+XL*QLAT*(DTS-(XL/UAVG))                    L 510
    8 VOLX=PVN                                                            L 520
      DO 9 I=N1,N2                                                        L 530
    9 PCN(I)=CLAT(I)                                                      L 540
   10 NPRCLS=NPRCLS+1                                                     L 550
      IF (NPRCLS .GT. 9999) WRITE(6,25)                                 AML0584
      NP=NPRCLS-1                                                         L 560
      DO 12 L=1,NP                                                        L 570
      K=(NPRCLS+1)-L                                                      L 580
      PV(K)=PV(K-1)                                                       L 590
      DO 11 I=N1,N2                                                       L 600
   11 PC(I,K)=PC(I,K-1)                                                   L 610
   12 CONTINUE                                                            L 620
      PV(1)=PVN                                                           L 630
      DO 13 I=N1,N2                                                       L 640
   13 PC(I,1)=PCN(I)                                                      L 650
C                                                                         L 660
C     ..... COMPUTE SUMMATION OF PARCEL VOLUMES .....                     L 670
      SUMV=0.0                                                            L 680
      L=1                                                                 L 690
      IF (VOLX.GT.0.0) L=2                                                L 700
      DO 14 K=L,NPRCLS                                                    L 710
   14 SUMV=SUMV+PV(K)                                                     L 720
C                                                                         L 730
C     ..... COMPUTE VOLUME OF LATERAL INFLOW .....                        L 740
      VLAT=QLAT*XL*DTS-(VOLX)                                             L 750
C                                                                         L 760
C     ..... DISTRIBUTE LATERAL INFLOW AMONG PARCELS IN PROPORTION TO      L 770
C           PARCEL VOLUMES AND ADJUST CONCENTRATIONS .....                L 780
      L=1                                                                 L 790
      IF (VOLX.GT.0.0) L=2                                                L 800
      DO 16 K=L,NPRCLS                                                    L 810
      ZVOL=VLAT*(PV(K)/SUMV)                                              L 820
      PVN=PV(K)+ZVOL                                                      L 830
      DO 15 I=N1,N2                                                       L 840
   15 PC(I,K)=(PC(I,K)*PV(K)+ZVOL*CLAT(I))/PVN                            L 850
      PV(K)=PVN                                                           L 860
   16 CONTINUE                                                            L 870
C                                                                         L 880
C     ..... COMPUTE VOLUME LEAVING SEGMENT .....                          L 890
   17 CONTINUE                                                            L 900
      VOUT=.5*(Q2+Q4)*DTS                                                 L 910
C                                                                         L 920
C     ..... DETERMINE WHICH PARCELS LEAVE SEGMENT .....                   L 930
      DO 20 I=1,NPRCLS                                                    L 940
      K=(NPRCLS+1)-I                                                      L 950
      VOUT=VOUT-PV(K)                                                     L 960
      IF (VOUT) 18,19,20                                                  L 970
   18 PV(K)=ABS(VOUT)                                                     L 980
      GO TO 21                                                            L 990
   19 K=K-1                                                               L1000
      GO TO 21                                                            L1010
   20 CONTINUE                                                            L1020
C                                                                         L1030
C     .....UPDATE NUMBER OF PARCELS AND ASSIGN CONC AT D/S END .....      L1040
   21 NPRCLS=K                                                            L1050
      DO 22 I=N1,N2                                                       L1060
   22 CD(I)=PC(I,NPRCLS)                                                  L1070
C                                                                         L1080
C     ..... SET NEW TIME STEP TO OLD TIME STEP .....                      L1090
   23 Q1=Q3                                                               L1100
      Q2=Q4                                                               L1110
      DO 24 I=N1,N2                                                       L1120
   24 CA(I)=CC(I)                                                         L1130
      RETURN                                                              L1140
 25   FORMAT (' ARRAY DIMENSIONS IN SUBROUTINE LAGRN ARE EXCEEDED')     AML0584
      END                                                                 L1150-
      SUBROUTINE ZEROS(CD,*,*,*)                                          M  10
C                                                                         M  20
C     SUB ZEROS TAKES CARE OF SITUATIONS IN THE CHANNEL TRANSPORT         M  30
C     COMPUTATIONS WHERE THERE ARE ZERO FLOWS                             M  40
C                                                                         M  50
      DIMENSION PV(999), PC(4,999), CLAT(4), CC(4), CD(4)               AML0584
      REAL M                                                              M  70
      COMMON /LGN/ PV,PC,NPRCLS                                           M  80
      COMMON /LGN1/ XL,DTS,ISEG,ALPHA,M,QLAT,CLAT,CC,J,N1,N2              M  90
      COMMON /LGN2/ Q1,Q2,Q3,Q4                                           M 100
C                                                                         M 110
      IF ((Q4.EQ.0.).AND.(Q3.EQ.0.).AND.(Q2.EQ.0.)) GO TO 1               M 120
      IF ((Q3.EQ.0.).AND.(Q2.EQ.0.)) GO TO 3                              M 130
      IF (Q3.EQ.0.) GO TO 5                                               M 140
      IF (Q2.EQ.0.) GO TO 6                                               M 150
C                                                                         M 160
    1 CONTINUE                                                            M 170
      DO 2 I=N1,N2                                                        M 180
    2 CD(I)=0.0                                                           M 190
      RETURN 3                                                            M 200
    3 CONTINUE                                                            M 210
      PV(1)=.5*QLAT*XL*DTS                                                M 220
      PV(2)=PV(1)                                                         M 230
      DO 4 I=N1,N2                                                        M 240
      PC(I,1)=CLAT(I)                                                     M 250
      PC(I,2)=PC(I,1)                                                     M 260
    4 CD(I)=CLAT(I)                                                       M 270
      RETURN 2                                                            M 280
    5 RETURN 1                                                            M 290
    6 VLAT=QLAT*XL*DTS                                                    M 300
      UAVG=.25*(UX(Q3)+UX(Q4))                                            M 310
      DX=UAVG*DTS                                                         M 320
      IF (DX.GT.XL) GO TO 7                                               M 330
      ZVOL=.5*DX*QLAT*DTS                                                 M 340
      GO TO 8                                                             M 350
    7 ZVOL=.5*XL*QLAT*(XL/UAVG)+XL*QLAT*(DTS-(XL/UAVG))                   M 360
    8 PVN=0.5*Q3*DTS                                                      M 370
      PV(1)=PVN+ZVOL                                                      M 380
      PV(2)=VLAT-ZVOL                                                     M 390
      IF (PV(2).LE.0.0) PV(2)=1.E-10                                      M 400
      DO 9 I=N1,N2                                                        M 410
      PC(I,1)=(CC(I)*PVN+ZVOL*CLAT(I))/PV(1)                              M 420
    9 PC(I,2)=CLAT(I)                                                     M 430
      RETURN 2                                                            M 440
      END                                                                 M 450-
      FUNCTION UX(Q)                                                      N  10
C                                                                         N  20
C     FUNCTION UX COMPUTES VEL FOR CHANNEL TRANSPORT GIVEN Q, ALPHA, & M  N  30
C                                                                         N  40
      REAL M,CLAT(4),CC(4)                                                N  50
      COMMON /LGN1/ XL,DTS,ISEG,ALPHA,M,QLAT,CLAT,CC,J,N1,N2              N  60
C                                                                         N  70
      IF (Q.EQ.0.) GO TO 1                                                N  80
      YM=1./M                                                             N  90
      UX=(Q**(1.-YM))*(ALPHA**YM)                                         N 100
      GO TO 2                                                             N 110
    1 UX=0.                                                               N 120
    2 RETURN                                                              N 130
      END                                                                 N 140-
      SUBROUTINE RESVR(ISTEP,IRS)                                         O  10
      COMMON /R1/ AREA(5,10),DISCH(5,10),CAPAC(5,10),STAGE(5,10)          O  20
      COMMON /R2/ AVDPTH(5,10),PERCNT(5,4,10),SIZE(10),DCUBE(10)          O  30
      COMMON /R3/ FALL(8),SG,STOKES,VISCOS,VELOC(8),DIAMT(8),PERCT(8)     O  40
      COMMON /R4/ TMEIN(2),OUTFL(5,8),M,LR,MR,DETK1,DETK2                 O  50
      COMMON /R5/ VTSUM(5,4,10),REMN(8),REM(8),FIX(5),RISER(5)            O  60
      COMMON /R6/ NLAYER(5),JFLOW(5),DEAD(5),NDX(5),NNS(5),CAPOOL(5)      O  70
      COMMON /R7/ TMASS(4),QWT1(4),QWT2(4),QWND1(4),QWND2(4),QWOUT(4)     O  80
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    O  90
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        O 100
      COMMON /F1/ ICT,STGAR(1442),STP(1442),QMX,I1,DELTAT,DELPLG,NRV(10)  O 110
      COMMON /F4/ FUP(1442),T1(1442),QWUP(4,1442),QWTOT(4,1442),FLW(1442  O 120
     1)                                                                   O 130
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            O 140
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    O 150
      INTEGER                                  RODYS                    II062383
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     O 160
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  O 170
      REAL ISEG                                                           O 180
      INTEGER TESTNO(180)                                                 O 190
      GO TO (1,3,22,22), ISTEP                                            O 200
    1 CONTINUE                                                            O 210
C             START HERE IF SEPARATE PROGRAM                              O 220
      NRES=1                                                              O 230
      IPR(1)=1                                                            O 240
      NRV(1)=1                                                            O 250
      I1=1                                                                O 260
      KOUT(I1)=1                                                          O 270
      NWQ=1                                                               O 280
      READ (5,76) ICT,DELTAT,DELPLG                                       O 290
      M=ICT                                                               O 300
      READ (5,73) ISEG(1),(IPA(JQW),IPB(JQW),JQW=1,NWQ)                   O 310
      IF (ICT.GT.1442) STOP                                               O 320
      DO 2 JQW=1,NWQ                                                      O 330
    2 CF1(JQW)=10.                                                        O 340
    3 CONTINUE                                                            O 350
C             START HERE FOR DR3M-QUAL                                    O 360
      READ (5,76) NS,SG,VISCOS                                            O 370
      IF (SG.LE.1.0) SG=2.65                                              O 380
      IF (VISCOS.LE.0.005) VISCOS=0.0114                                  O 390
      STOKES=5.15E-5*(SG-1.)/VISCOS                                       O 400
      DETK1=DELTAT*.08264/2.0                                             O 410
      DETK2=2000.*SG                                                      O 420
      READ (5,74) (SIZE(NL),NL=1,NS)                                      O 430
      SIZE(1)=0.0                                                         O 440
      DO 4 I=2,NS                                                         O 450
      IF (SIZE(I).LE.SIZE(I-1)) GO TO 72                                  O 460
    4 CONTINUE                                                            O 470
C             LOOP THROUGH RESERVOIRS AND READ INPUT DATA                 O 480
      DO 21 IRES=1,NRES                                                   O 490
      READ (5,75) NLAY,JFL,N,DEAD(IRES),RISER(IRES)                       O 500
      IF (JFL.EQ.1) NLAY=1                                                O 510
      NLAYER(IRES)=NLAY                                                   O 520
      JFLOW(IRES)=JFL                                                     O 530
      NDX(IRES)=N                                                         O 540
      NNS(IRES)=NS                                                        O 550
      FIX(IRES)=1.0                                                       O 560
      ANLAY=NLAY                                                          O 570
      NV=NRV(IRES)                                                        O 580
      WRITE (6,90) ISEG(NV),NLAYER(IRES),JFLOW(IRES),DEAD(IRES),N,NS      O 590
      WRITE (6,91) SG,VISCOS                                              O 600
      IF (JFL.EQ.4) WRITE (6,92) RISER(IRES)                              O 610
      DO 6 JQW=1,NWQ                                                      O 620
      READ (5,74) (PERCNT(IRES,JQW,NL),NL=1,NS)                           O 630
      IF (PERCNT(IRES,JQW,1).NE.0.0) PERCNT(IRES,JQW,1)=0.0               O 640
      IF (PERCNT(IRES,JQW,NS).NE.100.) PERCNT(IRES,JQW,NS)=100.           O 650
      DO 5 I=2,NS                                                         O 660
      IF (PERCNT(IRES,JQW,I).GE.PERCNT(IRES,JQW,I-1)) GO TO 5             O 670
      WRITE (6,79)                                                        O 680
      STOP                                                                O 690
    5 CONTINUE                                                            O 700
    6 CONTINUE                                                            O 710
      READ (5,74) (STAGE(IRES,I),I=1,N)                                   O 720
      READ (5,74) (AREA(IRES,I),I=1,N)                                    O 730
      READ (5,74) (DISCH(IRES,I),I=1,N)                                   O 740
      DO 7 I=2,N                                                          O 750
      IF (STAGE(IRES,I).LE.STAGE(IRES,I-1)) GO TO 72                      O 760
      IF (AREA(IRES,I).LE.AREA(IRES,I-1)) GO TO 72                        O 770
      IF (DISCH(IRES,I).LE.DISCH(IRES,I-1)) GO TO 72                      O 780
    7 CONTINUE                                                            O 790
C             COMPUTE RES. CAPACITY AT EACH PT. ON S-O CURVE              O 800
      AVDPTH(IRES,1)=0.0                                                  O 810
      CAPAC(IRES,1)=0.0                                                   O 820
      DO 8 J=2,N                                                          O 830
      CAPAC(IRES,J)=(AREA(IRES,J)+AREA(IRES,J-1))*(STAGE(IRES,J)-STAGE(I  O 840
     1RES,J-1))/2.0+CAPAC(IRES,J-1)                                       O 850
    8 CONTINUE                                                            O 860
      DO 9 J=1,N                                                          O 870
      IF (DISCH(IRES,J).LE..005) CAPOOL(IRES)=CAPAC(IRES,J)               O 880
    9 CONTINUE                                                            O 890
      WRITE (6,95) CAPOOL(IRES)                                           O 900
      IF (DEAD(IRES).LE.CAPOOL(IRES)) GO TO 10                            O 910
      WRITE (6,77)                                                        O 920
      STOP                                                                O 930
C             COMPUTE AVERAGE DEPTHS FOR EACH STAGE                       O 940
   10 DO 12 I=2,N                                                         O 950
      SUM1=0.0                                                            O 960
      SUM2=0.0                                                            O 970
      DO 11 J=2,I                                                         O 980
      DEPO=STAGE(IRES,I)-(STAGE(IRES,J)+STAGE(IRES,J-1))/2.0              O 990
      SUM1=DEPO*DEPO*(AREA(IRES,J)-AREA(IRES,J-1))+SUM1                   O1000
      SUM2=DEPO*(AREA(IRES,J)-AREA(IRES,J-1))+SUM2                        O1010
   11 CONTINUE                                                            O1020
      AVDPTH(IRES,I)=SUM1/SUM2                                            O1030
   12 CONTINUE                                                            O1040
      WRITE (6,89)                                                        O1050
      WRITE (6,80)                                                        O1060
      WRITE (6,81)                                                        O1070
      DO 13 IL=1,N                                                        O1080
      WRITE (6,82) STAGE(IRES,IL),AREA(IRES,IL),AVDPTH(IRES,IL),DISCH(IR  O1090
     1ES,IL),CAPAC(IRES,IL)                                               O1100
   13 CONTINUE                                                            O1110
      WRITE (6,83)                                                        O1120
      WRITE (6,84) (SIZE(I),I=1,NS)                                       O1130
      DO 14 JQW=1,NWQ                                                     O1140
      WRITE (6,85) IPA(JQW),IPB(JQW),(PERCNT(IRES,JQW,I),I=1,NS)          O1150
   14 CONTINUE                                                            O1160
C             COMPUTE INTEGRATED SETTLING VELOCITIES                      O1170
      DO 15 JQW=1,NWQ                                                     O1180
      DO 15 I=1,NS                                                        O1190
      VTSUM(IRES,JQW,I)=0.0                                               O1200
      IF (I.EQ.1) GO TO 15                                                O1210
      SLOPE=(PERCNT(IRES,JQW,I)-PERCNT(IRES,JQW,I-1))/(SIZE(I)-SIZE(I-1)  O1220
     1)                                                                   O1230
      D2CUBE=SIZE(I)*SIZE(I)*SIZE(I)                                      O1240
      DCUBE(I-1)=SIZE(I-1)*SIZE(I-1)*SIZE(I-1)                            O1250
      VTINC=(SLOPE*STOKES/3.)*(D2CUBE-DCUBE(I-1))                         O1260
      VTSUM(IRES,JQW,I)=VTSUM(IRES,JQW,I-1)+VTINC                         O1270
   15 CONTINUE                                                            O1280
C             SET UP OUTFLOW DISTRIBUTION                                 O1290
      DO 16 NL=1,NLAY                                                     O1300
   16 OUTFL(IRES,NL)=0.0                                                  O1310
      GO TO (17,19,20,21), JFL                                            O1320
   17 DO 18 NL=1,NLAY                                                     O1330
   18 OUTFL(IRES,NL)=100./ANLAY                                           O1340
      GO TO 21                                                            O1350
   19 OUTFL(IRES,1)=100.                                                  O1360
      GO TO 21                                                            O1370
   20 OUTFL(IRES,NLAY)=100.                                               O1380
   21 CONTINUE                                                            O1390
      IF (ISTEP.EQ.2) RETURN                                              O1400
C             READ IN ADDITIONAL DATA IF SEPARATE PROGRAM                 O1410
      READ (5,74) (FUP(I),I=1,M)                                          O1420
      READ (5,74) (FLW(I),I=1,M)                                          O1430
      READ (5,74) (QWUP(1,I),I=1,M)                                       O1440
      RETURN                                                              O1450
   22 CONTINUE                                                            O1460
C             ** MAIN BODY OF SUBROUTINE **                               O1470
      IRES=IRS                                                            O1480
      M=ICT                                                               O1490
      LR=(DELPLG+.01)/DELTAT                                              O1500
      MR=M/LR+.01                                                         O1510
      N=NDX(IRES)                                                         O1520
      NS=NNS(IRES)                                                        O1530
      NLAY=NLAYER(IRES)                                                   O1540
      ANLAY=NLAY                                                          O1550
C             DETERMINE CHAR. OF INFLOW QW AND FLOW AT EACH TIME STEP     O1560
      DO 27 JQW=1,NWQ                                                     O1570
      IF (CF1(JQW).GT.1.0E-6) GO TO 24                                    O1580
C             CORRECT FOR UG/L                                            O1590
      DO 23 I=1,M                                                         O1600
      QWUP(JQW,I)=QWUP(JQW,I)/1000.                                       O1610
   23 CONTINUE                                                            O1620
   24 VOLUME=FUP(1)*DETK1                                                 O1630
      STP(1)=VOLUME+CAPOOL(IRES)                                          O1640
      TMASS(JQW)=.001359*QWUP(JQW,1)*VOLUME/2.0                           O1650
      QWTOT(JQW,1)=QWUP(JQW,1)*VOLUME/DETK2                               O1660
      DO 26 I=2,M                                                         O1670
      VOLUME=(FUP(I-1)+FUP(I))*DETK1                                      O1680
      IF (JQW.GT.1) GO TO 25                                              O1690
      STP(I)=STP(I-1)+VOLUME                                              O1700
   25 AMULT=(QWUP(JQW,I)+QWUP(JQW,I-1))*VOLUME                            O1710
      TMASS(JQW)=TMASS(JQW)+0.001359*AMULT/2.0                            O1720
      QWTOT(JQW,I)=QWTOT(JQW,I-1)+AMULT/DETK2                             O1730
   26 CONTINUE                                                            O1740
   27 CONTINUE                                                            O1750
      AVSTG1=0.0                                                          O1760
C             COMPUTE CUMULATIVE STAGE AFTER EACH INCREMENT OF INFLOW     O1770
      DO 30 J=1,M                                                         O1780
      T1(J)=J*DELTAT                                                      O1790
      DO 28 K=2,N                                                         O1800
      IF (FLW(J).LT.DISCH(IRES,K)) GO TO 29                               O1810
   28 CONTINUE                                                            O1820
   29 AMULT=(FLW(J)-DISCH(IRES,K-1))/(DISCH(IRES,K)-DISCH(IRES,K-1))      O1830
      AVSTG2=AVDPTH(IRES,K-1)+AMULT*(AVDPTH(IRES,K)-AVDPTH(IRES,K-1))     O1840
      IF (J.EQ.1) STGAR1=0.0                                              O1850
      IF (J.GT.1) STGAR1=STGAR(J-1)                                       O1860
      STGAR(J)=ABS((AVSTG2+AVSTG1)*(DELTAT/2.0))+STGAR1                   O1870
      AVSTG1=AVSTG2                                                       O1880
   30 CONTINUE                                                            O1890
C             INITIALIZE FOR ROUTING PLUGS                                O1900
      PLGVOL=0.0                                                          O1910
      PLGTME=0.0                                                          O1920
      STRMOT=0.0                                                          O1930
      DO 31 JQW=1,NWQ                                                     O1940
      QWT1(JQW)=0.0                                                       O1950
      QWND1(JQW)=0.0                                                      O1960
   31 CONTINUE                                                            O1970
      VOLIN=DEAD(IRES)                                                    O1980
      TMEIN(1)=0.0                                                        O1990
      IF (ISTEP.EQ.4) GO TO 32                                            O2000
      WRITE (6,86)                                                        O2010
      WRITE (6,87)                                                        O2020
C             ** LOOP FOR ROUTING PLUGS **                                O2030
   32 JCT=0                                                               O2040
      NN=0                                                                O2050
      DO 66 NNN=1,M                                                       O2060
      JCT=JCT+1                                                           O2070
      IF (NNN.EQ.1) PLGVOL=FLW(1)*DETK1                                   O2080
      IF (NNN.GT.1) PLGVOL=PLGVOL+(FLW(NNN-1)+FLW(NNN))*DETK1             O2090
      IF (JCT.LT.LR) GO TO 66                                             O2100
      JCT=0                                                               O2110
      NN=NN+1                                                             O2120
      DETTME=0.0                                                          O2130
      DEPTH=0.0                                                           O2140
      PLGTME=PLGTME+DELPLG                                                O2150
      PLGCEN=PLGTME-DELPLG/2.0                                            O2160
      INCR=LR*NN                                                          O2170
      INCRM=INCR-LR                                                       O2180
      VOLIN1=VOLIN                                                        O2190
      VOLIN=VOLIN1+PLGVOL                                                 O2200
      IF (VOLIN.EQ.0.0) GO TO 53                                          O2210
C            FIND TMEIN FROM VOLIN                                        O2220
      DO 33 NP=1,M                                                        O2230
      IF (VOLIN.LT.STP(NP)) GO TO 34                                      O2240
   33 CONTINUE                                                            O2250
      VOLIN=STP(M)                                                        O2260
   34 DIFF=STP(NP)                                                        O2270
      IF (NP.GT.1) DIFF=DIFF-STP(NP-1)                                    O2280
      IF (DIFF.GT.0.0001) GO TO 35                                        O2290
      AMULT=1.0                                                           O2300
      GO TO 36                                                            O2310
   35 IF (NP.GT.1) AMULT=(VOLIN-STP(NP-1))/DIFF                           O2320
      IF (NP.EQ.1) AMULT=VOLIN/DIFF                                       O2330
   36 TMEIN(2)=AMULT*DELTAT                                               O2340
      IF (NP.GT.1) TMEIN(2)=TMEIN(2)+T1(NP-1)                             O2350
C             FIND DETENTION TIME FOR PLUG                                O2360
      VOLTME=(TMEIN(2)+TMEIN(1))/2.0                                      O2370
      TMEIN(1)=TMEIN(2)                                                   O2380
      DETTME=PLGCEN-VOLTME                                                O2390
      IF (DETTME.LT.0.0) DETTME=0.0                                       O2400
C             FIND INITIAL QW CONTENT OF PLUG                             O2410
      DO 37 JQW=1,NWQ                                                     O2420
      IF (NP.EQ.1) QWT2(JQW)=AMULT*QWTOT(JQW,1)                           O2430
      IF (NP.GT.1) QWT2(JQW)=QWTOT(JQW,NP-1)+AMULT*(QWTOT(JQW,NP)-QWTOT(  O2440
     1JQW,NP-1))                                                          O2450
      QWOUT(JQW)=(QWT2(JQW)-QWT1(JQW))/QWTOT(JQW,M)                       O2460
      IF (QWOUT(JQW).LT.0.0) QWOUT(JQW)=0.0                               O2470
      QWT1(JQW)=QWT2(JQW)                                                 O2480
   37 CONTINUE                                                            O2490
C             FIND AVERAGE DEPTH OF PLUG                                  O2500
      DO 38 II=1,M                                                        O2510
      IF (VOLTME.LT.T1(II)) GO TO 39                                      O2520
   38 CONTINUE                                                            O2530
   39 IF (II.GT.1) GO TO 40                                               O2540
      STGIN=STGAR(1)*(VOLTME/DELTAT)                                      O2550
      GO TO 41                                                            O2560
   40 AMULT=(VOLTME-T1(II-1))/DELTAT                                      O2570
      STGIN=STGAR(II-1)+AMULT*(STGAR(II)-STGAR(II-1))                     O2580
   41 IF (NN.GT.1) GO TO 42                                               O2590
      STGOUT=STGAR(INCR)/2.0                                              O2600
      GO TO 43                                                            O2610
   42 STGOUT=(STGAR(INCR)+STGAR(INCRM))/2.0                               O2620
   43 IF (DETTME.EQ.0.0) GO TO 53                                         O2630
      DEPTH=(STGOUT-STGIN)/DETTME                                         O2640
      IF (DEPTH.LE.0.0) DEPTH=0.0                                         O2650
C             IF(JFLOW=4; FIND OUTFLOW DIST.                              O2660
      IF (JFLOW(IRES).NE.4) GO TO 53                                      O2670
      DO 44 KP=2,N                                                        O2680
      IF (FLW(INCR).LT.DISCH(IRES,KP)) GO TO 45                           O2690
   44 CONTINUE                                                            O2700
   45 AMULT=(FLW(INCR)-DISCH(IRES,KP-1))/(DISCH(IRES,KP)-DISCH(IRES,KP-1  O2710
     1))                                                                  O2720
      STG=STAGE(IRES,KP-1)+AMULT*(STAGE(IRES,KP)-STAGE(IRES,KP-1))        O2730
      STGR=STG/ANLAY                                                      O2740
      JF=1                                                                O2750
      IF (RISER(IRES).GT.STGR) GO TO 46                                   O2760
      JF=3                                                                O2770
      GO TO 47                                                            O2780
   46 STGR=STG-STGR                                                       O2790
      IF (RISER(IRES).GE.STGR) JF=2                                       O2800
   47 DO 48 NL=1,NLAY                                                     O2810
   48 OUTFL(IRES,NL)=0.0                                                  O2820
      GO TO (49,51,52), JF                                                O2830
   49 DO 50 NL=1,NLAY                                                     O2840
   50 OUTFL(IRES,NL)=100./ANLAY                                           O2850
      GO TO 53                                                            O2860
   51 OUTFL(IRES,1)=100.                                                  O2870
      GO TO 53                                                            O2880
   52 OUTFL(IRES,NLAY)=100.                                               O2890
C             CONSTITUENT SETTLING COMPONENT                              O2900
   53 DO 65 JQW=1,NWQ                                                     O2910
      IF (PLGVOL.LT.1.0E-12) GO TO 63                                     O2920
      IF (DETTME.EQ.0.0) GO TO 61                                         O2930
      IF (DEPTH.LE.0.0) GO TO 63                                          O2940
C             ** LOOP THRU LAYERS **                                      O2950
      DO 59 NL=1,NLAY                                                     O2960
      ANL=NL                                                              O2970
      FALL(NL)=(ANL/ANLAY)*DEPTH*FIX(IRES)                                O2980
      VELOC(NL)=FALL(NL)/DETTME                                           O2990
      DIAMT(NL)=SQRT(VELOC(NL)/STOKES)                                    O3000
C             DETERMINE PERCENT OF PARTICLES HAVING DIAMETERS             O3010
C             LESS THAN FALL DIAMETERS FROM EACH LAYER                    O3020
      IF (DIAMT(NL).LT.SIZE(NS)) GO TO 54                                 O3030
      PERCT(NL)=100.                                                      O3040
      VTDF=VTSUM(IRES,JQW,NS)                                             O3050
      GO TO 58                                                            O3060
   54 DO 55 LP=2,NS                                                       O3070
      IF (DIAMT(NL).LT.SIZE(LP)) GO TO 56                                 O3080
   55 CONTINUE                                                            O3090
   56 PERCT(NL)=PERCNT(IRES,JQW,LP-1)+((DIAMT(NL)-SIZE(LP-1))/(SIZE(LP)-  O3100
     1SIZE(LP-1)))*(PERCNT(IRES,JQW,LP)-PERCNT(IRES,JQW,LP-1))            O3110
      IF (PERCT(NL).LT.0.0) PERCT(NL)=0.0                                 O3120
      IF (PERCT(NL).GT.100.) PERCT(NL)=100.                               O3130
      DIV=DIAMT(NL)-SIZE(LP-1)                                            O3140
      IF (DIV.GT.0.0001) GO TO 57                                         O3150
      VTDF=VTSUM(IRES,JQW,LP-1)                                           O3160
      GO TO 58                                                            O3170
   57 D2CUBE=DIAMT(NL)*DIAMT(NL)*DIAMT(NL)                                O3180
      SLOPE=(PERCT(NL)-PERCNT(IRES,JQW,LP-1))/DIV                         O3190
      VTDF=VTSUM(IRES,JQW,LP-1)+(SLOPE*STOKES/3.)*(D2CUBE-DCUBE(LP-1))    O3200
   58 REMN(NL)=PERCT(NL)-VTDF/VELOC(NL)                                   O3210
      IF (NL.EQ.1) REM(NL)=REMN(NL)                                       O3220
      IF (NL.GT.1) REM(NL)=NL*REMN(NL)-(NL-1)*REMN(NL-1)                  O3230
   59 CONTINUE                                                            O3240
C             SUM FOR ALL LAYERS                                          O3250
      QWPLG=0.0                                                           O3260
      DO 60 NL=1,NLAY                                                     O3270
      QWPLG=QWPLG+REM(NL)*QWOUT(JQW)*OUTFL(IRES,NL)                       O3280
   60 CONTINUE                                                            O3290
      QWPLG=QWPLG/100.                                                    O3300
      IF (QWPLG.GT.QWOUT(JQW)*100.) QWPLG=100.*QWOUT(JQW)                 O3310
      IF (QWPLG.LE.0.0) QWPLG=0.0                                         O3320
      GO TO 62                                                            O3330
   61 QWPLG=100.0*QWOUT(JQW)                                              O3340
   62 CONTINUE                                                            O3350
      QWND2(JQW)=QWND1(JQW)+QWPLG                                         O3360
      QWND1(JQW)=QWND2(JQW)                                               O3370
      CON(JQW,INCR)=(QWPLG/PLGVOL)*TMASS(JQW)*7.3548                      O3380
      IF (CF1(JQW).LT.1.0E-6) CON(JQW,INCR)=CON(JQW,INCR)*1000.           O3390
      GO TO 64                                                            O3400
   63 CON(JQW,INCR)=0.0                                                   O3410
   64 CONTINUE                                                            O3420
      IF (ISTEP.EQ.4) GO TO 65                                            O3430
      WRITE (6,88) PLGTME,FUP(INCR),FLW(INCR),DETTME,DEPTH,QWUP(JQW,INCR  O3440
     1),CON(JQW,INCR)                                                     O3450
   65 CONTINUE                                                            O3460
      STRMOT=STRMOT+PLGVOL                                                O3470
      PLGVOL=0.0                                                          O3480
   66 CONTINUE                                                            O3490
C             ** END OF LOOP FOR ROUTING PLUGS **                         O3500
      IRES=IRS                                                            O3510
      NV=NRV(IRES)                                                        O3520
      IF (IPR(NV).LT.1.OR.KOUT(I1).LT.1) GO TO 68                         O3530
      PCT=STRMOT/(STP(M)-CAPOOL(IRES))*100.                               O3540
      IF (PCT.GT.100.) PCT=100.                                           O3550
      WRITE (6,93) PCT,ISEG(NV)                                           O3560
      DO 67 JQW=1,NWQ                                                     O3570
      TRAP=(100.0-QWND2(JQW))                                             O3580
      WRITE (6,94) IPA(JQW),IPB(JQW),TRAP                                 O3590
   67 CONTINUE                                                            O3600
   68 IF (LR.EQ.1) RETURN                                                 O3610
      LRR=LR                                                              O3620
      LRM=LR-1                                                            O3630
      ALR=LR                                                              O3640
C             INTERPOLATE FOR CONCS. AT DT INTERVALS                      O3650
      DO 71 JQW=1,NWQ                                                     O3660
      OLDCON=0.0                                                          O3670
      DO 70 I=LRR,M,LR                                                    O3680
      DO 69 II=1,LRM                                                      O3690
      IV=I-LR+II                                                          O3700
      AII=II                                                              O3710
      CON(JQW,IV)=OLDCON+AII/ALR*(CON(JQW,I)-OLDCON)                      O3720
   69 CONTINUE                                                            O3730
      OLDCON=CON(JQW,I)                                                   O3740
   70 CONTINUE                                                            O3750
   71 CONTINUE                                                            O3760
      RETURN                                                              O3770
   72 WRITE (6,78)                                                        O3780
      STOP                                                                O3790
C                                                                         O3800
   73 FORMAT (A4,8A3)                                                     O3810
   74 FORMAT (10F8.0)                                                     O3820
   75 FORMAT (3I5,3F5.0)                                                  O3830
   76 FORMAT (I5,2F5.0)                                                   O3840
   77 FORMAT (1H0,46HDEAD SHOULD NOT EXCEED PERMANENT POOL CAPACITY)      O3850
   78 FORMAT (1H0,61HSIZE,STAGE,AREA,AND DISCH SHOULD BE INPUT IN INCREA  O3860
     1SING ORDER)                                                         O3870
   79 FORMAT (1H0,46HPERCNT DATA SHOULD BE INPUT IN ASCENDING ORDER)      O3880
   80 FORMAT (//,15X,5HSTAGE,10X,4HAREA,7X,13HAVERAGE DEPTH,5X,9HDISCHAR  O3890
     1GE,7X,8HCAPACITY)                                                   O3900
   81 FORMAT (/,16X,4H(FT),9X,7H(ACRES),10X,4H(FT),10X,5H(CFS),9X,9H(ACR  O3910
     1E-FT))                                                              O3920
   82 FORMAT (/,10X,F10.4,5X,F10.5,5X,F10.2,5X,F10.2,5X,F11.5,5X)         O3930
   83 FORMAT (///,5X,48H***** PARTICLE SIZE DISTRIBUTION OF INFLOW *****  O3940
     1)                                                                   O3950
   84 FORMAT (//,15X,15HSIZE (MICRONS) ,10F8.1)                           O3960
   85 FORMAT (/,15X,8H% FINER(,2A3,1H),10F8.1)                            O3970
   86 FORMAT (1H1,3X,4HTIME,8X,6HINFLOW,7X,9HDISCHARGE,5X,14HDETENTION T  O3980
     1IME,8X,5HDEPTH,8X,8HINFLUENT,7X,8HEFFLUENT)                         O3990
   87 FORMAT (1H ,3X,5H(HRS),8X,5H(CFS),9X,5H(CFS),11X,5H(HRS),14X,4H(FT  O4000
     1),9X,6H(MG/L),9X,6H(MG/L))                                          O4010
   88 FORMAT (F8.2,6X,F7.2,8X,F7.2,8X,F7.2,13X,F7.2,6X,F8.1,8X,F7.1)      O4020
   89 FORMAT (//,42X,26H***** BASIN GEOMETRY *****)                       O4030
   90 FORMAT (1H1,10HRESERVOIR ,A4/1H0,9X,8HNLAYER =,I2/10X,7HJFLOW =,I2  O4040
     1/10X,6HDEAD =,F7.2,9H  ACRE-FT/10X,3HN =,I3/10X,4HNS =,I3)          O4050
   91 FORMAT (1H ,9X,4HSG =,F5.2/10X,8HVISCOS =,F7.4)                     O4060
   92 FORMAT (10X,7HRISER =,F6.2,5H FEET)                                 O4070
   93 FORMAT (///1HO,F6.2,38H PERCENT OF INFLOW TO DETENTION BASIN ,A4,2  O4080
     10H HAS BEEN DISCHARGED)                                             O4090
   94 FORMAT (1H ,26HBASIN TRAP EFFICIENCY FOR ,2A3,2H =,F6.2,2H %)       O4100
   95 FORMAT (10X,25HPERMANENT POOL CAPACITY =,F7.2,8H ACRE-FT)           O4110
      END                                                                 O4120-
      SUBROUTINE QWLOAD(J)                                                P  10
C             THIS SUBROUTINE COMPUTES SIM. LOADS                         P  20
C             BOTH INSTANTANEOUS AND CUMULATIVE                           P  30
C             AND LOAD CHARACTERISTIC CURVES                              P  40
      INTEGER TESTNO(180),RODYS                                           P  50
      REAL I2CFSP                                                         P  60
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        P  70
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             P  80
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     P  90
      COMMON /F4/ FUP(1442),FLAT(1442),QWUP(4,1442),QWLAT(4,1442),FLW(14  P 100
     142)                                                                 P 110
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        P 120
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   P 130
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            P 140
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    P 150
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  P 160
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     P 170
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       P 180
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             P 190
      IV=NWQM(I1,J)                                                       P 200
      YMAX=CMX(I1,J)                                                      P 210
      LK=K1(I1)                                                           P 220
      LJ=K2(I1)                                                           P 230
      LV=LJ-LK+1                                                          P 240
      IF (IPL(I1).LT.1) GO TO 4                                           P 250
      IF (IPL(I1).GT.2) GO TO 4                                           P 260
C          PLOT SIMULATED CONCENTRATION DATA                              P 270
      DO 1 JJJ=1,LV                                                       P 280
    1 IF (R(JJJ).GT.YMAX) YMAX=R(JJJ)                                     P 290
      CALL PLT(Q,R,LV,1,YMAX,I1,J,2)                                      P 300
      IF (IV.EQ.0) GO TO 3                                                P 310
C          PLOT MEASURED CONCENTRATION DATA                               P 320
      DO 2 K=1,IV                                                         P 330
      AJ=TIME(I1,J,K)                                                     P 340
      JJ=AJ                                                               P 350
      JAJ=JJ-LK+1                                                         P 360
      TME=Q(JAJ)                                                          P 370
      F2=CO(I1,J,K)                                                       P 380
      CALL PLT(TME,F2,1,2,YMAX,I1,J,2)                                    P 390
    2 CONTINUE                                                            P 400
    3 CONTINUE                                                            P 410
      CALL PLT(Q,R,JJJ,3,YMAX,I1,J,2)                                     P 420
    4 CONTINUE                                                            P 430
C             ** INSTANTANEOUS LOADS **                                   P 440
C             COMPUTE SIMULATED INSTANTANEOUS LOADS                       P 450
      DO 5 JJJ=1,LV                                                       P 460
      R(JJJ)=R(JJJ)*FLW(JJJ)*CF1(J)                                       P 470
    5 CONTINUE                                                            P 480
C             ** CUMULATIVE LOADS **                                      P 490
      YMAX=FLD(I1,J)                                                      P 500
      LB=K1(I1)                                                           P 510
      LC=K2(I1)                                                           P 520
      IF (JLOAD.EQ.1) GO TO 6                                             P 530
      IF (IV.EQ.0) GO TO 6                                                P 540
      LB=TIME(I1,J,1)                                                     P 550
      LC=TIME(I1,J,IV)                                                    P 560
    6 JJJ=0                                                               P 570
C             COMPUTE SIM. CUMULATIVE LOAD                                P 580
      JJ=LB-LK                                                            P 590
      DO 9 K=LB,LC                                                        P 600
      JJ=JJ+1                                                             P 610
      JJJ=JJJ+1                                                           P 620
      R2=R(JJ)                                                            P 630
      IF (K.LE.LB) GO TO 7                                                P 640
      R(JJJ)=R(JJJ-1)+(R2+R1)*PTIME*30.                                   P 650
      GO TO 8                                                             P 660
    7 R(JJJ)=0.0                                                          P 670
    8 R1=R2                                                               P 680
      IF (K.EQ.LC) SFLD(I1,J)=R(JJJ)                                      P 690
    9 CONTINUE                                                            P 700
      IF (IPL(I1).LT.2) RETURN                                            P 710
C             SIMULATED LOAD CHARACTERISTIC CURVE                         P 720
      TLD=SFLD(I1,J)                                                      P 730
      RUNVOL=0.0                                                          P 740
      JJJ=0                                                               P 750
      Q(1)=0.0                                                            P 760
      R(1)=0.0                                                            P 770
      JJ=LB-LK                                                            P 780
      DO 10 K=LB,LC                                                       P 790
      JJ=JJ+1                                                             P 800
      JJJ=JJJ+1                                                           P 810
      IF (K.EQ.LB) GO TO 10                                               P 820
      R(JJJ)=R(JJJ)/TLD                                                   P 830
      RUNVOL=FLW(JJ)+RUNVOL                                               P 840
      Q(JJJ)=RUNVOL                                                       P 850
   10 CONTINUE                                                            P 860
      DO 11 K=1,JJJ                                                       P 870
   11 Q(K)=Q(K)/RUNVOL                                                    P 880
      YMAX=0.91                                                           P 890
      CALL PLT(Q,R,JJJ,1,YMAX,I1,J,3)                                     P 900
      IF (IFILED.EQ.0) GO TO 15                                           P 910
      IF (JLOAD.EQ.1) GO TO 15                                            P 920
      IF (IV.EQ.0) GO TO 15                                               P 930
      IF (IFILED.EQ.0) GO TO 15                                           P 940
C             MEASURED  LOAD CHARACTERISTIC CURVE                         P 950
      TLD=FLD(I1,J)                                                       P 960
      JJJ=0                                                               P 970
      DO 14 K=LB,LC                                                       P 980
      JJJ=JJJ+1                                                           P 990
      AK=K                                                                P1000
      CALL QWTAB(I1,J,AK,F2,JK,IV)                                        P1010
      IF (K.EQ.LB) GO TO 12                                               P1020
      R2=F2*UD(K)                                                         P1030
      R(JJJ)=ROLD+(R2+R1)*PTIME*30.*CF1(J)                                P1040
      R1=R2                                                               P1050
      GO TO 13                                                            P1060
   12 R1=F2*UD(K)                                                         P1070
      R(JJJ)=0.0                                                          P1080
   13 ROLD=R(JJJ)                                                         P1090
      R(JJJ)=R(JJJ)/TLD                                                   P1100
   14 CONTINUE                                                            P1110
      CALL PLT(Q,R,JJJ,2,YMAX,I1,J,3)                                     P1120
   15 CONTINUE                                                            P1130
      CALL PLT(Q,R,JJJ,3,YMAX,I1,J,3)                                     P1140
      RETURN                                                              P1150
      END                                                                 P1160-
      SUBROUTINE INPUT1                                                   Q  10
C             THIS SUBROUTINE READS UNIT AND DAILY DATA                   Q  20
      INTEGER PCCN,DCCN,RODYS,DPD,DATERF,DATERL,BTIME,DATE                Q  30
      INTEGER STA,STAD,STAD1,STAUP,STAUP1,STAP,STAP1                      Q  40
      INTEGER YR,MO,DY,EYR,EMO,EDY,CN,CT,CODE,OPTION,OPT                  Q  50
      INTEGER YN(99),UPD,UDD,TESTNO(180)                                  Q  60
      DIMENSION TITLD(50), TITLUP(50), TITLP(50), IOUT(2), X2(16), MN(13  Q  70
     1)                                                                   Q  80
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             Q  90
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     Q 100
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   Q 110
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            Q 120
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    Q 130
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  Q 140
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     Q 150
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  Q 160
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             Q 170
      DATA IOUT/4HLIST,4HNONO/,PCCN/0/,DCCN/0/,UPD/0/,UDD/0/              Q 180
      DATA MN/0,31,59,90,120,151,181,212,243,273,304,334,365/             Q 190
C             JULIAN DATE FOR JAN. 1 OF EACH YEAR                         Q 200
C             STARTING FROM JAN. 1, 1901                                  Q 210
      YN(1)=0                                                             Q 220
      DO 1 I=2,99                                                         Q 230
      YN(I)=YN(I-1)+365                                                   Q 240
      IF (MOD(I-1,4).EQ.0) YN(I)=YN(I)+1                                  Q 250
    1 CONTINUE                                                            Q 260
C             INITIALIZE TO ZERO                                          Q 270
      DO 2 I=1,IUD                                                        Q 280
    2 UD(I)=0.0                                                           Q 290
      DO 3 I=1,7310                                                       Q 300
      DP(I)=0.0                                                           Q 310
    3 CONTINUE                                                            Q 320
      DO 4 I=1,4                                                          Q 330
      DO 4 J=1,60                                                         Q 340
      WFALL(I,J)=0.0                                                      Q 350
    4 CONTINUE                                                            Q 360
      NSS=1                                                               Q 370
C             OPTION=IOUT(1) LISTS INPUT DATA.                            Q 380
      READ (5,51) OPTION,NWQ,NOPT,NWF,ISS,IMODE,ILOAD,ISSFRQ,JRECDS       Q 390
      IF (JRECDS.GT.0.AND.IMODE.EQ.1) GO TO 50                            Q 400
      IF (NWQ.EQ.0) GO TO 8                                               Q 410
      READ (5,53) (IPA(I),IPB(I),I=1,NWQ)                                 Q 420
      READ (5,52) (NQU(I),I=1,NWQ)                                        Q 430
      DO 5 I=1,NWQ                                                        Q 440
      IF (NQU(I).EQ.1) CF1(I)=6.243E-5                                    Q 450
    5 IF (NQU(I).EQ.2) CF1(I)=6.243E-8                                    Q 460
      IF (NWF.NE.1) GO TO 8                                               Q 470
      DO 7 I=1,NWQ                                                        Q 480
      READ (5,54) IP1,IP2,(X2(J),J=1,12)                                  Q 490
      CALL ID(IP1,IP2,NWQ,L)                                              Q 500
      DO 6 J=1,12                                                         Q 510
    6 WFALL(L,J)=X2(J)                                                    Q 520
    7 CONTINUE                                                            Q 530
    8 IF (ISS.LT.2) GO TO 9                                               Q 540
C           READ-IN DATES ON WHICH STREETS WERE SWEPT                     Q 550
      READ (5,55) (NSSDAY(1,J),NSSDAY(2,J),NSSDAY(3,J),J=1,ISS)           Q 560
C             READ-IN STA.NOS. AND NAMES,DA,UNIT TIME, BEGIN AND END      Q 570
C             DATES.   STATION NUMBERS READ 2A4 FOR IBM WORD SIZE.        Q 580
    9 READ (5,59) STAD1,STAD,TITLD,DA                                     Q 590
      READ (5,59) STAP1,STAP,TITLP                                        Q 600
      READ (5,61) IYR,IMO,IDY,EYR,EMO,EDY                                 Q 610
C             INITIALIZE VARIABLES                                        Q 620
      DO 10 I=1,180                                                       Q 630
      NOUD(I)=0                                                           Q 640
   10 CONTINUE                                                            Q 650
      UPD=0                                                               Q 660
      PCCN=0                                                              Q 670
      NUDD=0                                                              Q 680
      READ (5,60) PTIME,IUDATA,JPUN                                       Q 690
      JLOAD=0                                                             Q 700
      IF (JPUN.LE.0) JPUN=5                                               Q 710
      IF (IUDATA.LT.1) IFILED=0                                           Q 720
C             DETERMINE JULIAN DATE FOR BEGIN AND END OF RECORD.          Q 730
C             DATE=1 FOR JAN. 1, 1901                                     Q 740
      IF (MOD(IYR,4).NE.0) GO TO 11                                       Q 750
      IF (IMO-2) 11,11,12                                                 Q 760
   11 LEAP=0                                                              Q 770
      GO TO 13                                                            Q 780
   12 LEAP=1                                                              Q 790
   13 DATERF=YN(IYR)+MN(IMO)+IDY+LEAP                                     Q 800
      IF (MOD(EYR,4).NE.0) GO TO 14                                       Q 810
      IF (EMO-2) 14,14,15                                                 Q 820
   14 LEAP=0                                                              Q 830
      GO TO 16                                                            Q 840
   15 LEAP=1                                                              Q 850
   16 DATERL=YN(EYR)+MN(EMO)+EDY+LEAP                                     Q 860
C             CALCULATE NUMBER OF DAYS OF RECORD                          Q 870
      RODYS=DATERL-DATERF+1                                               Q 880
      IF (RODYS.LE.NDYS) GO TO 17                                         Q 890
      WRITE (6,75) NDYS                                                   Q 900
      STOP                                                                Q 910
   17 WRITE (6,62) STAD1,STAD,TITLD,STAP1,STAP,TITLP,DA,PTIME,IMO,IDY,IY  Q 920
     1R,DATERF,EMO,EDY,EYR,DATERL                                         Q 930
      WRITE (6,63) JRECDS,IUDATA,IMODE,JPUN                               Q 940
C           WRITE QW AND STREET SWEEPING INFO                             Q 950
      DO 18 I=1,NWQ                                                       Q 960
      J=NQU(I)+2                                                          Q 970
      IF (I.EQ.1) WRITE (6,64) IPA(I),IPB(I),IND(J)                       Q 980
      IF (I.GT.1) WRITE (6,65) IPA(I),IPB(I),IND(J)                       Q 990
   18 CONTINUE                                                            Q1000
      IF (NWF.NE.1) GO TO 20                                              Q1010
      DO 19 I=1,NWQ                                                       Q1020
      J=NQU(I)+2                                                          Q1030
      WRITE (6,66) IPA(I),IPB(I),IND(J),(WFALL(I,K),K=1,12)               Q1040
   19 CONTINUE                                                            Q1050
   20 CONTINUE                                                            Q1060
      IF (ISS.EQ.1) WRITE (6,57) ISSFRQ                                   Q1070
      IF (ISS.LT.2) GO TO 21                                              Q1080
      WRITE (6,56)                                                        Q1090
      WRITE (6,58) (NSSDAY(1,J),NSSDAY(2,J),NSSDAY(3,J),J=1,ISS)          Q1100
   21 CONTINUE                                                            Q1110
C             COMPUTE TIME PARAMETERS                                     Q1120
      PDEL=PTIME/1440.0                                                   Q1130
      NDELS=1440/PTIME                                                    Q1140
      NOUT=IUD/NDELS                                                      Q1150
      NUPD=0                                                              Q1160
      BTIME=PTIME                                                         Q1170
      DT=PTIME                                                            Q1180
      QWINT=PTIME*60.                                                     Q1190
      DPD=DATERF-1                                                        Q1200
C             READ IN DATA FROM A CARD                                    Q1210
C             PERFORM EDIT CHECK ON STATION NO., UNIT TIME, AND           Q1220
C             CHRONOLOGICAL SEQUENCE OF CARD                              Q1230
C             ENTER DATA INTO ARRAYS ACCORDING TO CODING                  Q1240
C             CHECK LAST FOUR CHARACTERS OF STATION NOS. ONLY             Q1250
      IF (OPTION.EQ.IOUT(1)) WRITE (6,76)                                 Q1260
      KP=0                                                                Q1270
      NU=1                                                                Q1280
      NSD=1                                                               Q1290
   22 CONTINUE                                                            Q1300
      IF (PTIME.GT.4.9) READ (JPUN,67) STA1,STA,YR,MO,DY,CT,CN,(X2(I),I=  Q1310
     11,12),CODE                                                          Q1320
      IF (PTIME.LT.4.9) READ (JPUN,68) STA1,STA,YR,MO,DY,CT,CN,(X2(I),I=  Q1330
     11,12),CODE                                                          Q1340
      IF (CODE.LE.0) CODE=2                                               Q1350
      IF (CN.LE.0) CN=1                                                   Q1360
      IF (CODE.NE.9) GO TO 23                                             Q1370
      IF (IFILED.GT.0) WRITE (IFILED) K4DAY,(UD(I),I=1,K4DAY)             Q1380
      ICK(NSD)=NU                                                         Q1390
      GO TO 35                                                            Q1400
   23 IF (MOD(YR,4).NE.0) GO TO 24                                        Q1410
      IF (MO-2) 24,24,25                                                  Q1420
   24 LEAP=0                                                              Q1430
      GO TO 26                                                            Q1440
   25 LEAP=1                                                              Q1450
   26 DATE=YN(YR)+MN(MO)+DY+LEAP                                          Q1460
C             DATA ENTRIES FOR CODE 2                                     Q1470
      IF (STA.NE.STAD) GO TO 43                                           Q1480
      IF (CT.NE.BTIME.AND.CT.GT.0) GO TO 43                               Q1490
      IF (DATE-UDD) 43,30,27                                              Q1500
   27 NUDD=NUDD+1                                                         Q1510
      IPL(NUDD)=MO                                                        Q1520
      KOUT(NUDD)=DY                                                       Q1530
      TESTNO(NUDD)=YR                                                     Q1540
      NOUD(NUDD)=DATE                                                     Q1550
      UDD=DATE                                                            Q1560
      DCCN=CN                                                             Q1570
      IF (NUDD.EQ.1) GO TO 31                                             Q1580
      ITES=NOUD(NUDD)-NOUD(NUDD-1)                                        Q1590
      IF (ITES.EQ.1) GO TO 29                                             Q1600
      ICK(NSD)=NU                                                         Q1610
      NU=1                                                                Q1620
      NSD=NSD+1                                                           Q1630
      IF (IUDATA.EQ.0) GO TO 33                                           Q1640
      WRITE (IFILED) K4DAY,(UD(I),I=1,K4DAY)                              Q1650
      DO 28 I=1,K4DAY                                                     Q1660
   28 UD(I)=0.0                                                           Q1670
      GO TO 31                                                            Q1680
   29 NU=NU+1                                                             Q1690
      IF (NU.LE.NOUT) GO TO 31                                            Q1700
      WRITE (6,78) NOUT                                                   Q1710
      STOP                                                                Q1720
   30 IF (CN.LE.DCCN) GO TO 43                                            Q1730
      DCCN=CN                                                             Q1740
   31 K4DAY=NDELS*(NU-1)+12*CN                                            Q1750
      IF (IUDATA.EQ.0) GO TO 33                                           Q1760
C             ENTER DATA INTO ARRAYS ACCORDING TO CODE TYPE               Q1770
      KK=K4DAY-11                                                         Q1780
      I=0                                                                 Q1790
      DO 32 K=KK,K4DAY                                                    Q1800
      I=I+1                                                               Q1810
   32 UD(K)=X2(I)                                                         Q1820
   33 IF (OPTION.NE.IOUT(1)) GO TO 22                                     Q1830
      IF (IFILED.GT.0) GO TO 34                                           Q1840
      WRITE (6,69) STAD1,STA,YR,MO,DY                                     Q1850
      GO TO 22                                                            Q1860
   34 WRITE (6,69) STAD1,STA,YR,MO,DY,CT,CN,(X2(I),I=1,12),CODE           Q1870
      GO TO 22                                                            Q1880
C             DATES FOR CODES 3+4                                         Q1890
   35 READ (5,70) STAD1,STA,YR,MO,CN,(X2(I),I=1,16),CODE                  Q1900
      IF (CODE.EQ.9) GO TO 44                                             Q1910
      IF (OPTION.NE.IOUT(1)) GO TO 36                                     Q1920
      WRITE (6,71) STAD1,STA,YR,MO,CN,(X2(I),I=1,16),CODE                 Q1930
   36 CONTINUE                                                            Q1940
      LEAP=0                                                              Q1950
      IF (MOD(YR,4).EQ.0) LEAP=1                                          Q1960
      IF (CN.LT.2) GO TO 38                                               Q1970
      DATE=YN(YR)+MN(MO)+17                                               Q1980
      IF (MO.LE.2) GO TO 37                                               Q1990
      DATE=DATE+LEAP                                                      Q2000
   37 II=YN(YR)+MN(MO+1)-DATE+1                                           Q2010
      IF (MO.LE.1) GO TO 40                                               Q2020
      II=II+LEAP                                                          Q2030
      GO TO 40                                                            Q2040
   38 DATE=YN(YR)+MN(MO)+1                                                Q2050
      IF (MO.LE.2) GO TO 39                                               Q2060
      DATE=DATE+LEAP                                                      Q2070
   39 II=16                                                               Q2080
   40 CONTINUE                                                            Q2090
C             DATA ENTRIES FOR CODE 3                                     Q2100
      IF (STA.NE.STAP) GO TO 43                                           Q2110
      IF (DATE.LE.DPD) GO TO 43                                           Q2120
      DPD=DATE                                                            Q2130
      II=II+DPD-DATERF                                                    Q2140
      KK=DPD-DATERF+1                                                     Q2150
      IF (ISS.LT.2) GO TO 41                                              Q2160
      IF (NSS.GT.ISS) GO TO 41                                            Q2170
      CALL SSDAY(YR,MO,CN,KK,NSS)                                         Q2180
   41 I=0                                                                 Q2190
      DO 42 K=KK,II                                                       Q2200
      I=I+1                                                               Q2210
C             CHECK FOR GAP IN DAILY RECORD                               Q2220
      IF (X2(I).NE.99.990) GO TO 42                                       Q2230
C             IF THERE IS A GAP SET UP INDICATORS FOR THIS                Q2240
      KP=KP+1                                                             Q2250
      INDP(KP)=K                                                          Q2260
      X2(I)=0.0                                                           Q2270
   42 DP(K)=X2(I)                                                         Q2280
      GO TO 35                                                            Q2290
C             PRINT CARD WITH INCONSISTENT DATA                           Q2300
   43 WRITE (6,72) MO,YR,CN,CODE                                          Q2310
      STOP                                                                Q2320
   44 CONTINUE                                                            Q2330
      INDP(KP+1)=II+1                                                     Q2340
      I=0                                                                 Q2350
      J=1                                                                 Q2360
C             CHECK FOR INPUT DATA ERRORS                                 Q2370
      IDATE=TESTNO(NUDD)*10000+IPL(NUDD)*100+KOUT(NUDD)                   Q2380
      JDATE=EYR*10000+EMO*100+EDY                                         Q2390
      IF (JDATE.GT.IDATE) GO TO 45                                        Q2400
      WRITE (6,79)                                                        Q2410
      STOP                                                                Q2420
   45 IF (NSS.GE.ISS) GO TO 46                                            Q2430
      WRITE (6,73)                                                        Q2440
      STOP                                                                Q2450
   46 L=NOUD(1)                                                           Q2460
      K=0                                                                 Q2470
      GO TO 48                                                            Q2480
   47 WRITE (6,74) K,L                                                    Q2490
      STOP                                                                Q2500
   48 DO 49 K=DATERF,DATERL                                               Q2510
      I=I+1                                                               Q2520
      IF (DP(I).GE.0.0) GO TO 49                                          Q2530
      IF (K.NE.L) GO TO 47                                                Q2540
      J=J+1                                                               Q2550
      L=NOUD(J)                                                           Q2560
   49 CONTINUE                                                            Q2570
      RETURN                                                              Q2580
   50 WRITE (6,77)                                                        Q2590
      STOP                                                                Q2600
C                                                                         Q2610
   51 FORMAT (A4,I2,2I1,I2,2I1,I3,I6)                                     Q2620
   52 FORMAT (40I2)                                                       Q2630
   53 FORMAT (20A3)                                                       Q2640
   54 FORMAT (2A3,12F5.2)                                                 Q2650
   55 FORMAT (10(I3,I2,I2))                                               Q2660
   56 FORMAT (//1H0,40HSTREETS ARE SWEPT ON THE FOLLOWING DAYS:)          Q2670
   57 FORMAT (//1H0,24HSTREETS ARE SWEPT EVERY ,I3,5H DAYS)               Q2680
   58 FORMAT (10(I4,I2,I2))                                               Q2690
   59 FORMAT (2A4,50A1,F6.2)                                              Q2700
   60 FORMAT (F5.0,3I5)                                                   Q2710
   61 FORMAT (20X,3I3,3X,3I3)                                             Q2720
   62 FORMAT (1H0,22HDISCHARGE STATION     ,2A4,50A1/1H ,22HDAILY PRECIP  Q2730
     1. STATION ,2A4,50A1/1H ,14HDRAINAGE AREA=,F6.2,8H SQ. MI./1H ,16HU  Q2740
     2NIT DATA ARE IN,F9.3,18H MINUTE INCREMENTS/1H ,29HTHE PERIOD OF RE  Q2750
     3CORD IS FROM ,I2,1H-,I2,1H-,I2,6H (DAY=,I7,5H) TO ,I2,1H-,I2,1H-,I  Q2760
     42,6H (DAY=,I7,1H))                                                  Q2770
   63 FORMAT (1H0,8HJRECDS =,I6/1H ,8HIUDATA =,I2/1H ,7HIMODE =,I2/1H ,6  Q2780
     1HJPUN =,I3)                                                         Q2790
   64 FORMAT (1H0,56HTHE FOLLOWING WATER-QUALITY CONSTITUENTS ARE SIMULA  Q2800
     1TED: ,2A3,6H IN MI,A3,11HGRAMS/LITER)                               Q2810
   65 FORMAT (1H ,56X,2A3,6H IN MI,A3,11HGRAMS/LITER)                     Q2820
   66 FORMAT (/1H0,2A3,28H WETFALL CONTRIBUTIONS IN MI,A3,15HGRAMS/LITER  Q2830
     1 ARE/1H ,2X,4HJAN.,2X,4HFEB.,1X,5HMARCH,1X,5HAPRIL,3X,3HMAY,2X,4HJ  Q2840
     2UNE,2X,4HJULY,2X,4HAUG.,1X,5HSEPT.,2X,4HOCT.,2X,4HNOV.,2X,4HDEC./1  Q2850
     3H ,12(1X,F5.2))                                                     Q2860
   67 FORMAT (2A4,5I2,12F5.0,1X,I1)                                       Q2870
   68 FORMAT (2A4,4I2,I3,12F5.0,I1)                                       Q2880
   69 FORMAT (1H ,2A4,5I3,12F8.2,I3)                                      Q2890
   70 FORMAT (2A4,2I2,I1,16F4.2,2X,I1)                                    Q2900
   71 FORMAT (1H ,2A4,2I3,I2,16(1X,F4.2),I3)                              Q2910
   72 FORMAT (1H0,29HERROR ON A UNIT OR DAILY CARD/1H ,35HDATE,CN, AND C  Q2920
     1ODE OF THIS CARD ARE:,5X,I4,1H/,I2,5X,3HCN=,I4,5X,5HCODE=,I2)       Q2930
   73 FORMAT (1H0,44HERROR IN CARD ASSIGNING STREET SWEEPING DAYS)        Q2940
   74 FORMAT (20X,2I6/1H0,27HUNIT DAYS SPECIFIED ON UNIT,28HAND DAILY CA  Q2950
     1RDS DO NOT MATCH)                                                   Q2960
   75 FORMAT (1H0,30HPERIOD OF RECORD CANNOT EXCEED,I5,5H DAYS)           Q2970
   76 FORMAT (1H1)                                                        Q2980
   77 FORMAT (1H0,33HJRECDS CANNOT EXCEED 0 IF IMODE=1)                   Q2990
   78 FORMAT (1H ,37HPROGRAM IS DIMENSIONED FOR A MAX. OF ,I2,23H CONSEC  Q3000
     1UTIVE STORM DAYS)                                                   Q3010
   79 FORMAT (1H0,56HEND OF RECORD MUST BE AT LEAST 1 DAY AFTER LAST UNI  Q3020
     1T DAY)                                                              Q3030
      END                                                                 Q3040-
      SUBROUTINE INPUT2                                                   R  10
      INTEGER RODYS,TESTNO(180),O1                                        R  20
      REAL I2CFSP,ISEG                                                    R  30
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    R  40
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             R  50
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     R  60
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        R  70
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   R  80
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            R  90
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    R 100
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  R 110
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     R 120
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  R 130
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       R 140
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             R 150
C             5280**2/12*60*60*24=26.888:  CONVERTS INCHES TO CFS         R 160
      INTVAL=(PTIME+0.001)/DT                                             R 170
      I2CFSP=26.8888889*DA*NDELS                                          R 180
      NOFE=1                                                              R 190
      I1=1                                                                R 200
      NSDD=0                                                              R 210
      JRECQW=0                                                            R 220
      JCONC=0                                                             R 230
C             INITIALIZE VARIABLES                                        R 240
      DO 1 I=1,60                                                         R 250
      FPK(I)=0.0                                                          R 260
      FVOL(I)=0.0                                                         R 270
      DO 1 J=1,4                                                          R 280
      FLD(I,J)=0.0                                                        R 290
      CMX(I,J)=0.0                                                        R 300
      NWQM(I,J)=0                                                         R 310
      RVLC(I,J)=0.0                                                       R 320
      RVB(I,J)=0.0                                                        R 330
      DO 1 K=1,24                                                         R 340
      CO(I,J,K)=0.0                                                       R 350
      TIME(I,J,K)=0.0                                                     R 360
    1 CONTINUE                                                            R 370
C             FOR EACH SET OF EVENTS, THE NO. OF EVENTS IN THE SET        R 380
C             IS ENTERED FOR AS MANY TIMES AS THERE ARE EVENTS IN THE     R 390
C             SET. A SET OF EVENTS CONSISTS OF A FRACTION OF A DAY OR     R 400
C             A SERIES OF CONTINUOUS DAYS.                                R 410
      READ (5,19) I,(NF(K),K=1,I)                                         R 420
      WRITE (6,20) I,(NF(K),K=1,I)                                        R 430
C             BEGIN ANALYSIS OF A SET OF EVENTS                           R 440
    2 DO 3 I=I1,NUDD                                                      R 450
      IF (NOUD(I+1).NE.(NOUD(I)+1)) GO TO 4                               R 460
    3 CONTINUE                                                            R 470
    4 NFI1=NF(NOFE)                                                       R 480
      I4=I1                                                               R 490
      I1=I+1                                                              R 500
      NSDD=NSDD+1                                                         R 510
C             BEGIN ANALYSIS OF A STORM                                   R 520
    5 IF (NWF.EQ.2) READ (5,18) KS,KE,NWQP,(WFALL(J,NOFE),J=1,NWQ)        R 530
      IF (NWF.NE.2) READ (5,18) KS,KE,NWQP                                R 540
      WRITE (6,22) NOFE,KS,KE                                             R 550
      JRCS=(KE-KS+1)*INTVAL                                               R 560
      IF (JRCS.LT.NDTS) GO TO 6                                           R 570
      WRITE (6,28) NOFE,NDTS                                              R 580
      STOP                                                                R 590
    6 ITES=NDELS*ICK(NSDD)                                                R 600
      IF (KE.LE.ITES) GO TO 7                                             R 610
      WRITE (6,29) NOFE,ITES                                              R 620
      STOP                                                                R 630
    7 JRCS=JRCS/120+1-(1-MIN0(1,MOD(JRCS,120)))                           R 640
      JRCS=JRCS*NSEG*NWQ                                                  R 650
      IF (JRECQW.LT.JRCS) JRECQW=JRCS                                     R 660
      IF (NWF.NE.2) GO TO 9                                               R 670
      DO 8 I=1,NWQ                                                        R 680
      IF (CF1(I).GT.1.0E-6) J=3                                           R 690
      IF (CF1(I).LT.1.0E-6) J=4                                           R 700
      WRITE (6,21) IPA(I),IPB(I),WFALL(I,NOFE),IND(J)                     R 710
    8 CONTINUE                                                            R 720
    9 K1(NOFE)=KS                                                         R 730
      K2(NOFE)=KE                                                         R 740
      LJ=KS                                                               R 750
      LM=KE                                                               R 760
      NFI1=NFI1-1                                                         R 770
      IF (NWQP.EQ.0) GO TO 14                                             R 780
C          READ WATER-QUALITY DATA FOR A STORM                            R 790
      JCONC=1                                                             R 800
      DO 13 K=1,NWQP                                                      R 810
      READ (5,23) IP1,IP2,NNN                                             R 820
      IF (NNN.LE.24) GO TO 10                                             R 830
      WRITE (6,27) NOFE                                                   R 840
      STOP                                                                R 850
   10 CONTINUE                                                            R 860
      CALL ID(IP1,IP2,NWQ,L)                                              R 870
      NWQM(NOFE,L)=NNN                                                    R 880
      IV=NWQM(NOFE,L)                                                     R 890
      READ (5,24) (CO(NOFE,L,J),J=1,IV)                                   R 900
      READ (5,24) (TIME(NOFE,L,J),J=1,IV)                                 R 910
      ALJ=LJ                                                              R 920
      IVM=IV-1                                                            R 930
      DO 11 J=1,IVM                                                       R 940
      IF (CO(NOFE,L,J).GT.CMX(NOFE,L)) CMX(NOFE,L)=CO(NOFE,L,J)           R 950
   11 TIME(NOFE,L,J)=ALJ+TIME(NOFE,L,J)/PTIME                             R 960
      ADD=TIME(NOFE,L,IV)/PTIME                                           R 970
      IF (AMOD(ADD,1.).EQ.0.0) GO TO 12                                   R 980
      IADD=ADD                                                            R 990
      ADD=IADD+1.0                                                        R1000
   12 TIME(NOFE,L,IV)=ALJ+ADD                                             R1010
      KTIME=TIME(NOFE,L,IV)                                               R1020
      IF (KTIME.LE.K2(NOFE)) GO TO 13                                     R1030
      WRITE (6,17) IP1,IP2,NOFE                                           R1040
      STOP                                                                R1050
   13 CONTINUE                                                            R1060
C             NDATE IS USED FOR PRINTING OUT THE DATE OF STORM            R1070
   14 I3=I4+LJ/NDELS                                                      R1080
      NDATE(NOFE,1)=IPL(I3)                                               R1090
      NDATE(NOFE,2)=KOUT(I3)                                              R1100
      NDATE(NOFE,3)=TESTNO(I3)                                            R1110
      NOFE=NOFE+1                                                         R1120
C             CHECK FOR MORE STORMS IN SET OF EVENTS                      R1130
      IF (NFI1.GT.0) GO TO 5                                              R1140
C             CHECK TO SEE IF ALL EVENTS HAVE BEEN ANALYZED               R1150
      IF (NUDD.GE.I1) GO TO 2                                             R1160
      NOFE=NOFE-1                                                         R1170
      READ (5,19) (KOUT(I),I=1,NOFE)                                      R1180
      WRITE (6,25) (KOUT(I),I=1,NOFE)                                     R1190
      KNN=0                                                               R1200
      READ (5,19) (IPL(I),I=1,NOFE)                                       R1210
      WRITE (6,26) (IPL(I),I=1,NOFE)                                      R1220
      DO 15 I=1,NOFE                                                      R1230
      TESTNO(I)=1                                                         R1240
      KNN=KNN+1                                                           R1250
   15 CONTINUE                                                            R1260
      IF (IMODE.EQ.3) WRITE (6,30) JRECQW                                 R1270
      IF (IMODE.LT.3) JRECQW=0                                            R1280
      IF (IMODE.NE.2) RETURN                                              R1290
      DO 16 I=1,NOFE                                                      R1300
      KOUT(I)=0                                                           R1310
      IPL(I)=0                                                            R1320
      DO 16 J=1,NWQ                                                       R1330
   16 NWQM(I,J)=0.0                                                       R1340
      JCONC=0                                                             R1350
      RETURN                                                              R1360
C                                                                         R1370
   17 FORMAT (1H ,18HSAMPLING TIME FOR ,2A3,10H FOR STORM,I4,29H IS AFTE  R1380
     1R KE ON CARD GROUP 14)                                              R1390
   18 FORMAT (2I4,I2,4F5.2)                                               R1400
   19 FORMAT (40I2)                                                       R1410
   20 FORMAT (1H1,9HTHERE ARE,I4,32H STORM EVENTS GROUPED AS FOLLOWS,10I  R1420
     16/5(46X,10I6/))                                                     R1430
   21 FORMAT (1H ,2A3,27H WETFALL CONCENTRATIONS ARE,F7.3,3H MI,A3,11HGR  R1440
     1AMS/LITER)                                                          R1450
   22 FORMAT (1H0,9HSTORM NO.,I3,22H STARTS AT TIME PERIOD,I5,12H AND EN  R1460
     1DS AT,I5)                                                           R1470
   23 FORMAT (2A3,I2)                                                     R1480
   24 FORMAT (10F8.2)                                                     R1490
   25 FORMAT (1H0,27HDETAILED OUTPUT FOR STORMS ,30I3)                    R1500
   26 FORMAT (1H0,29HTHE STORM EVENTS PLOTTED ARE ,30I3)                  R1510
   27 FORMAT (1H ,27HNO. OF QW SAMPLES FOR STORM,I3,11H EXCEEDS 24)       R1520
   28 FORMAT (1H0,25HNUMBER OF DT'S FOR STORM ,I2,8H EXCEEDS,I5)          R1530
   29 FORMAT (1H0,12HKE FOR STORM,I3,18H SHOULD NOT EXCEED,I5)            R1540
   30 FORMAT (1H0,50HNO. OF RECORDS REQUIRED FOR DIRECT ACCESS FILE 27=,  R1550
     1I7)                                                                 R1560
      END                                                                 R1570-
      SUBROUTINE INPUT3                                                   S  10
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    S  20
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    S  30
      INTEGER                                  RODYS                    II062383
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     S  40
      DIMENSION Z(5)                                                      S  50
      NWQNLU=NWQ*NLU                                                      S  60
      IF (NWQNLU.GT.1) WRITE (6,11)                                       S  70
      DO 5 K=1,NWQNLU                                                     S  80
      READ (5,6) IP1,IP2,IP3,IP4,IP5,(Z(I),I=1,5)                         S  90
      DO 2 L=1,NLU                                                        S 100
      IF (LUSE(1,L).NE.IP1) GO TO 1                                       S 110
      IF (LUSE(2,L).NE.IP2) GO TO 1                                       S 120
      IF (LUSE(3,L).NE.IP3) GO TO 1                                       S 130
      LU=L                                                                S 140
      GO TO 3                                                             S 150
    1 IF (L.LT.NLU) GO TO 2                                               S 160
      WRITE (6,10) IP1,IP2,IP3                                            S 170
      STOP                                                                S 180
    2 CONTINUE                                                            S 190
    3 CONTINUE                                                            S 200
      CALL ID(IP4,IP5,NWQ,IWQ)                                            S 210
      IF (Z(5).LE.0.001) Z(5)=Z(3)                                        S 220
      DO 4 I=1,5                                                          S 230
    4 BK(I,IWQ,LU)=Z(I)                                                   S 240
      WRITE (6,7) IPA(IWQ),IPB(IWQ),(LUSE(LV,LU),LV=1,3),(Z(I),I=1,3)     S 250
      WRITE (6,8) Z(5)                                                    S 260
      IF (Z(4).GT.0.0001) WRITE (6,9) Z(4)                                S 270
    5 CONTINUE                                                            S 280
      RETURN                                                              S 290
C                                                                         S 300
    6 FORMAT (3A3,2A3,6F8.3)                                              S 310
    7 FORMAT (//1H0,21HMODEL PARAMETERS FOR ,2A3,22H ON AREAS OF LAND US  S 320
     1E ,3A3,9H   :  K1=,F8.3/65X,3HK2=,F8.3/65X,3HK3=,F8.3)              S 330
    8 FORMAT (59X,9HDAILY K3=,F8.3)                                       S 340
    9 FORMAT (65X,3HK4=,F8.3)                                             S 350
   10 FORMAT (1H0,39HERROR IN SPECIFICATION OF LAND-USE TYPE,2X,3A3)      S 360
   11 FORMAT (1H1)                                                        S 370
      END                                                                 S 380-
      SUBROUTINE CTCHMT                                                   T  10
C          THIS SUBROUTINE IS USED TO READ IN CATCHMENT DATA              T  20
      REAL ISEG,IUP,ILAT                                                  T  30
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    T  40
      COMMON /C2/ IPR(99),FLGTH(99),PARAM(99,4),LAND(99),NCAT,NRES        T  50
      COMMON /C3/ SSEFF(4),SSMIN(4),SSAREA(51),AKA(4),AKB(4)              T  60
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        T  70
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     T  80
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    T  90
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    T 100
      INTEGER                                  RODYS                    II062383
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     T 110
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  T 120
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             T 130
      DIMENSION ILAT(99,4), IUP(99,3)                                     T 140
      NCAT=1                                                              T 150
      LAND(1)=1                                                           T 160
      NRES=0                                                              T 170
      READ (5,18) DAE,AIMP,SSAREA(1)                                      T 180
      WRITE (6,19) DAE,AIMP                                               T 190
      EFF(1)=DAE                                                          T 200
      READ (5,17) NLU,(LUSE(1,I),LUSE(2,I),LUSE(3,I),I=1,NLU)             T 210
      WRITE (6,20) NLU,(LUSE(1,I),LUSE(2,I),LUSE(3,I),I=1,NLU)            T 220
      IF (ISS.EQ.0) GO TO 3                                               T 230
      READ (5,18) (SSEFF(J),J=1,NWQ)                                      T 240
      READ (5,18) (SSMIN(J),J=1,NWQ)                                      T 250
      WRITE (6,31)                                                        T 260
      DO 2 J=1,NWQ                                                        T 270
      IF (SSEFF(J).LE.1.0) GO TO 1                                        T 280
      WRITE (6,34) SSEFF(J)                                               T 290
      STOP                                                                T 300
    1 WRITE (6,32) IPA(J),IPB(J),SSEFF(J),SSMIN(J)                        T 310
    2 CONTINUE                                                            T 320
      IF (IMODE.EQ.1) WRITE (6,33) SSAREA(1)                              T 330
    3 IF (JRECDS.EQ.0) RETURN                                             T 340
      READ (5,21) NSEG1,(AKA(J),AKB(J),J=1,NWQ)                           T 350
      IF (NSEG1.EQ.NSEG) GO TO 4                                          T 360
      WRITE (6,30)                                                        T 370
      STOP                                                                T 380
    4 NCAT=0                                                              T 390
      WRITE (6,22) NSEG,DT                                                T 400
      IF (IMODE.EQ.1) RETURN                                              T 410
      IF (AKA(1).EQ.0.0.AND.AKB(1).EQ.0.0) GO TO 6                        T 420
      WRITE (6,23)                                                        T 430
      DO 5 J=1,NWQ                                                        T 440
      WRITE (6,24) IPA(J),IPB(J),AKA(J),AKB(J)                            T 450
    5 CONTINUE                                                            T 460
    6 WRITE (6,26)                                                        T 470
      DO 10 I=1,NSEG                                                      T 480
      READ (5,27) ISEG(I),(IUP(I,J),J=1,3),(ILAT(I,J),J=1,4),ITYPE(I),IP  T 490
     1R(I),FLGTH(I),(PARAM(I,J),J=1,4),IP1,IP2,IP3                        T 500
      IF (MOD(I,50).EQ.0) WRITE (6,26)                                    T 510
      WRITE (6,28) ISEG(I),(IUP(I,J),J=1,3),(ILAT(I,J),J=1,4),ITYPE(I),I  T 520
     1PR(I),FLGTH(I),(PARAM(I,J),J=1,4),IP1,IP2,IP3                       T 530
      IF (ITYPE(I).EQ.3) NRES=NRES+1                                      T 540
      IF (ITYPE(I).EQ.3) NRV(NRES)=I                                      T 550
      IF (ITYPE(I).NE.1) GO TO 9                                          T 560
      DO 8 LU=1,NLU                                                       T 570
      IF (IP1.NE.LUSE(1,LU)) GO TO 7                                      T 580
      IF (IP2.NE.LUSE(2,LU)) GO TO 7                                      T 590
      IF (IP3.NE.LUSE(3,LU)) GO TO 7                                      T 600
      NCAT=NCAT+1                                                         T 610
      LAND(NCAT)=LU                                                       T 620
      GO TO 9                                                             T 630
    7 IF (LU.LT.NLU) GO TO 8                                              T 640
      WRITE (6,25) IP1,IP2,IP3                                            T 650
      STOP                                                                T 660
    8 CONTINUE                                                            T 670
    9 CONTINUE                                                            T 680
   10 CONTINUE                                                            T 690
      IPR(NSEG)=0                                                         T 700
      IF (NCAT.LT.52) GO TO 11                                            T 710
      WRITE (6,29)                                                        T 720
      STOP                                                                T 730
   11 DTS=DT*60.                                                          T 740
C             NUMBER CONTRIBUTING SEGMENTS (IUP,ILAT) USING SUBROUTINE    T 750
C             ITRAN WHICH GIVES THE CONTRIBUTING SEGMENTS THE SAME        T 760
C             NUMBER AS THE ORDER OF THE SEGMENTS (I.E., I)               T 770
      DO 13 I=1,NSEG                                                      T 780
      DO 12 J=1,3                                                         T 790
      X=IUP(I,J)                                                          T 800
      JUP(I,J)=ITRAN(X)                                                   T 810
   12 CONTINUE                                                            T 820
      DO 13 J=1,4                                                         T 830
      X=ILAT(I,J)                                                         T 840
      JLAT(I,J)=ITRAN(X)                                                  T 850
   13 CONTINUE                                                            T 860
C             COMPUTE EFF. IMPERVIOUS AREA CONTRIBUTING TO EACH CHANNEL   T 870
      DAEC=0.0                                                            T 880
      NC=0                                                                T 890
      DO 16 I=1,NSEG                                                      T 900
      IF (ITYPE(I).NE.1) GO TO 16                                         T 910
      NC=NC+1                                                             T 920
      EFF(NC)=0.0                                                         T 930
      SSAREA(NC)=0.0                                                      T 940
      TOP=0.0                                                             T 950
      DO 15 J=1,4                                                         T 960
      IF (JLAT(I,J)) 15,15,14                                             T 970
   14 JJ=JLAT(I,J)                                                        T 980
      IF (PARAM(JJ,2).LE.0.0) GO TO 15                                    T 990
      TERM=PARAM(JJ,2)*FLGTH(JJ)*FLGTH(I)/43560.                          T1000
      EFF(NC)=EFF(NC)+TERM                                                T1010
      TOP=TOP+PARAM(JJ,1)*TERM                                            T1020
      SSAREA(NC)=TOP/EFF(NC)                                              T1030
   15 CONTINUE                                                            T1040
      DAEC=DAEC+EFF(NC)                                                   T1050
   16 CONTINUE                                                            T1060
      WRITE (6,35) DAEC                                                   T1070
      RETURN                                                              T1080
C                                                                         T1090
   17 FORMAT (I5,12A3)                                                    T1100
   18 FORMAT (5F5.2)                                                      T1110
   19 FORMAT (///20X,34HTOTAL EFFECTIVE IMPERVIOUS AREA = ,F7.2,6H ACRES  T1120
     1/20X,23HIMPERVIOUS RETENTION = ,F4.2,7H INCHES)                     T1130
   20 FORMAT (20X,9HTHERE ARE,I2,18H LAND-USE TYPES:  ,3A3/3(49X,3A3/))   T1140
   21 FORMAT (I5,8F5.0)                                                   T1150
   22 FORMAT (1H0,19X,26HTOTAL NUMBER OF SEGMENTS =,I3/20X,5HDT = ,F7.3,  T1160
     18H MINUTES)                                                         T1170
   23 FORMAT (//1H0,24HPERVIOUS AREA PARAMETERS/1H0,11HCONSTITUENT,5X,3H  T1180
     1AKA,5X,3HAKB)                                                       T1190
   24 FORMAT (1H ,2X,2A3,F11.2,F8.2)                                      T1200
   25 FORMAT (1H0,39HERROR IN SPECIFICATION OF LAND-USE TYPE,2X,3A3)      T1210
   26 FORMAT (1H1,55X,6HLENGTH/1H ,7HSEGMENT,1X,17HUPSTREAM SEGMENTS,3X,  T1220
     118HADJACENT SEGMENTS ,4HTYPE,4H IPR,1X,6H(FEET),8X,16HOTHER PARAME  T1230
     2TERS,8X,9H LAND USE)                                                T1240
   27 FORMAT (8A4,2I2,F7.0,4F5.0,3A3)                                     T1250
   28 FORMAT (2X,A4,3X,3(1X,A4),3X,4(1X,A4),I3,I4,F8.1,4F8.3,3A3)         T1260
   29 FORMAT (1H0,21HNCAT CANNOT EXCEED 51)                               T1270
   30 FORMAT (1H0,46HNSEG DOES NOT MATCH BETWEEN DR3M AND DR3M-QUAL)      T1280
   31 FORMAT (1H0,20HSTREET SWEEPING DATA/1H0,25HCONSTITUENT  SSEFF  SSM  T1290
     1IN)                                                                 T1300
   32 FORMAT (1H ,2X,2A3,5X,F5.2,F7.2)                                    T1310
   33 FORMAT (1H0,8HSSAREA =,F5.2)                                        T1320
   34 FORMAT (1H0,41HSWEEPING EFFICIENCY SHOULD NOT EXCEED 1.0,F15.3)     T1330
   35 FORMAT (/1H0,50HEFFECTIVE IMPERVIOUS AREA BASED ON SEGMENT DATA IS  T1340
     1,F8.2,6H ACRES)                                                     T1350
      END                                                                 T1360-
      SUBROUTINE SSDAY(YR,MO,CN,KK,NSS)                                   U  10
      INTEGER YR,CN,RODYS                                                 U  20
C           THIS SUBROUTINE IDENTIFIES STREET SWEEPING DAYS               U  30
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     U  40
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  U  50
    1 IF (MO.NE.NSSDAY(1,NSS)) RETURN                                     U  60
      IF (YR.NE.NSSDAY(3,NSS)) RETURN                                     U  70
      IF (CN.EQ.1.AND.NSSDAY(2,NSS).LE.16) GO TO 2                        U  80
      IF (CN.EQ.2.AND.NSSDAY(2,NSS).GE.17) GO TO 3                        U  90
      RETURN                                                              U 100
    2 NSSDAY(1,NSS)=KK+NSSDAY(2,NSS)-1                                    U 110
      GO TO 4                                                             U 120
    3 NSSDAY(1,NSS)=KK+NSSDAY(2,NSS)-17                                   U 130
    4 NSS=NSS+1                                                           U 140
      IF (NSS.GT.ISS) RETURN                                              U 150
      GO TO 1                                                             U 160
      END                                                                 U 170-
      SUBROUTINE OUTPT(ICNT,IDEL,JJ,JOUTPT)                               V  10
C             THIS SUBROUTINE OUTPUTS SIMULATED CONCENTRATION DATA        V  20
C             AND SETS UP ARRAYS FOR QWLOAD                               V  30
      REAL ISEG                                                           V  40
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)    V  50
      INTEGER RODYS,TESTNO(180)                                           V  60
      COMMON /F1/ ICT,Q(1442),R(1442),QMX,I1,DELTAT,DELPLG,NRV(10)        V  70
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            V  80
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    V  90
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  V 100
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     V 110
      COMMON /WQ1/ AT,ATO(4,51),XO(4,51),CON(4,1442),NSSDAY(3,40),ISWEEP  V 120
      DIMENSION RT(5), IHR(5), TMN(5), TOUT(5), MOUT(5)                   V 130
C             JOUTPT=2 IF SIMULATED CONCS. ARE LISTED                     V 140
C                   =1 IF SIM. CONCS. ARE PLOTTED BUT NOT LISTED          V 150
C                   =0 IF SIM. CONCS. ARE NEITHER LISTED NOR PLOTTED      V 160
C                   =3 IF SIM. CONCS. ARE NOT AT WATERSHED OUTLET         V 170
      IF (JOUTPT.LT.2) GO TO 1                                            V 180
      WRITE (6,10) I1,(NDATE(I1,III),III=1,3)                             V 190
      IF (JOUTPT.EQ.3) WRITE (6,11) ISEG(ICNT)                            V 200
      IF (JOUTPT.NE.3) WRITE (6,12)                                       V 210
      WRITE (6,6) IPA(JJ),IPB(JJ)                                         V 220
      IF (CF1(JJ).GT.1.0E-6) WRITE (6,7)                                  V 230
      IF (CF1(JJ).LT.1.0E-6) WRITE (6,8)                                  V 240
    1 LJ=K1(I1)                                                           V 250
      LK=K2(I1)                                                           V 260
      QMX=0.0                                                             V 270
      I5=0                                                                V 280
      ICT=0                                                               V 290
      ICNT=0                                                              V 300
      DO 5 I=LJ,LK                                                        V 310
      ICT=ICT+IDEL                                                        V 320
      I5=I5+1                                                             V 330
      RT(I5)=CON(JJ,ICT)                                                  V 340
      IF (RT(I5).GT.QMX) QMX=RT(I5)                                       V 350
      IF (JOUTPT.EQ.0) GO TO 2                                            V 360
      MOUT(I5)=I/NDELS                                                    V 370
      IRV=MOUT(I5)*NDELS                                                  V 380
      TOUT(I5)=((I-IRV)*PTIME)/60.                                        V 390
      IHR(I5)=INT(TOUT(I5))                                               V 400
      TMN(I5)=AMOD(TOUT(I5),1.)*60.                                       V 410
    2 IF (I5.LT.5.AND.I.LT.LK) GO TO 5                                    V 420
      IF (JOUTPT.LT.2) GO TO 3                                            V 430
      WRITE (6,9) (IHR(IV),TMN(IV),RT(IV),IV=1,I5)                        V 440
    3 DO 4 J=1,I5                                                         V 450
      ICNT=ICNT+1                                                         V 460
      R(ICNT)=RT(J)                                                       V 470
      IF (JOUTPT.EQ.0) GO TO 4                                            V 480
      IF (JOUTPT.EQ.3) GO TO 4                                            V 490
      Q(ICNT)=TOUT(J)+MOUT(J)*24.                                         V 500
    4 CONTINUE                                                            V 510
      I5=0                                                                V 520
    5 CONTINUE                                                            V 530
      RETURN                                                              V 540
C                                                                         V 550
    6 FORMAT (1H ,52X,9HDATA FOR ,2A3/)                                   V 560
    7 FORMAT (5(7X,4HTIME,5X,5HCONC.,1X)/5(7X,5H(HRS),4X,6H(MG/L)))       V 570
    8 FORMAT (5(7X,4HTIME,5X,5HCONC.,1X)/5(7X,5H(HRS),4X,6H(UG/L)))       V 580
    9 FORMAT (5(6X,I2,1H:,F3.0,F10.3))                                    V 590
   10 FORMAT (1H0,26HSTORM-RUNOFF EVENT NUMBER ,I3,7H  DATED,I3,1H/,I2,1  V 600
     1H/,I2)                                                              V 610
   11 FORMAT (1H ,52X,8HSEGMENT ,A4)                                      V 620
   12 FORMAT (1H ,52X,19HAT WATERSHED OUTLET)                             V 630
      END                                                                 V 640-
      SUBROUTINE RITE1                                                    W  10
C             THIS SUBROUTINE OUTPUTS A SUMMARY OF THE MEASURED DATA      W  20
      INTEGER RODYS,TESTNO(180),O1                                        W  30
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        W  40
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   W  50
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            W  60
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    W  70
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  W  80
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     W  90
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       W 100
      O1=0                                                                W 110
      WRITE (6,4)                                                         W 120
      DO 3 I=1,NOFE                                                       W 130
      WRITE (6,5) I,(NDATE(I,III),III=1,3)                                W 140
      WRITE (6,6) FVOL(I)                                                 W 150
      WRITE (6,7) FPK(I)                                                  W 160
      IF (NWQ.EQ.0) GO TO 3                                               W 170
      DO 2 J=1,NWQ                                                        W 180
      IF (NWQM(I,J).EQ.0) GO TO 2                                         W 190
      IF (O1.GT.0) GO TO 1                                                W 200
      WRITE (6,8)                                                         W 210
      WRITE (6,9)                                                         W 220
      WRITE (6,10)                                                        W 230
      O1=1                                                                W 240
    1 PER=RVLC(I,J)/FVOL(I)*100.                                          W 250
      WRITE (6,11) IPA(J),IPB(J),RVB(I,J),RVLC(I,J),PER,NWQM(I,J),FLD(I,  W 260
     1J)                                                                  W 270
    2 CONTINUE                                                            W 280
      O1=0                                                                W 290
    3 CONTINUE                                                            W 300
      RETURN                                                              W 310
C                                                                         W 320
    4 FORMAT (1H1,45X,24HSUMMARY OF MEASURED DATA/1H ,25X,60H*RUNOFF VOL  W 330
     1UMES IN INCHES ARE BASED ON TOTAL WATERSHED AREA*)                  W 340
    5 FORMAT (1H0/1H ,26HSTORM-RUNOFF EVENT NUMBER ,I3,7H  DATED,I3,1H/,  W 350
     1I2,1H/,I2)                                                          W 360
    6 FORMAT (1H ,24HMEASURED DIRECT RUNOFF =,F9.3,7H INCHES)             W 370
    7 FORMAT (1H ,25HMEASURED PEAK DISCHARGE =,F9.2,4H CFS)               W 380
    8 FORMAT (32X,13HRUNOFF VOLUME,2X,13HRUNOFF VOLUME,2X,10HPERCENTAGE,  W 390
     15X,3HNO.,5X,8HMEASURED)                                             W 400
    9 FORMAT (17X,13HWATER-QUALITY,2X,13HBEFORE FIRST ,2X,12HUSED IN LOA  W 410
     1D,3X,8HOF TOTAL,7X,2HOF,6X,7HLOAD IN)                               W 420
   10 FORMAT (19X,9HPARAMETER,7X,6HSAMPLE,6X,12HCOMPUTATIONS,3X,11HRUNOF  W 430
     1F VOL.,2X,7HSAMPLES,4X,6HPOUNDS)                                    W 440
   11 FORMAT (20X,2A3,6X,F8.3,7X,F8.3,8X,F5.1,I11,6X,F8.3)                W 450
      END                                                                 W 460-
      SUBROUTINE RITE2(N1,N2)                                             X  10
C           THIS SUBROUTINE PRINTS OUT A SUMMARY OF                       X  20
C             SIMULATED AND MEASURED LOADS                                X  30
      INTEGER TESTNO(180),RODYS                                           X  40
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW             X  50
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE     X  60
      COMMON /I1/ NLU,LUSE(3,4),BK(5,4,4),ISSFRQ,NPAGE                    X  70
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        X  80
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   X  90
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            X 100
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    X 110
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     X 120
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  X 130
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       X 140
      REAL                  I2CFSP                                      II062383
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             X 150
      WRITE (6,8)                                                         X 160
      IF (JCONC.EQ.1.AND.JLOAD.EQ.0) WRITE (6,9)                          X 170
      DO 3 J=N1,N2                                                        X 180
      WRITE (6,6) IPA(J),IPB(J)                                           X 190
      WRITE (6,10)                                                        X 200
      DO 2 I=1,NOFE                                                       X 210
      IF (FLD(I,J).EQ.0.0) GO TO 1                                        X 220
      IF (SFLD(I,J).EQ.0.0) GO TO 1                                       X 230
      VR=ALOG(FLD(I,J)/SFLD(I,J))**2                                      X 240
      WRITE (6,7) I,(NDATE(I,III),III=1,3),SFLD(I,J),FLD(I,J),VR          X 250
      GO TO 2                                                             X 260
    1 WRITE (6,7) I,(NDATE(I,III),III=1,3),SFLD(I,J)                      X 270
    2 CONTINUE                                                            X 280
    3 CONTINUE                                                            X 290
      IF (IMODE.GT.1) RETURN                                              X 300
      WRITE (6,8)                                                         X 310
C          OUTPUT EAT AND ALS                                             X 320
      DAR=(DA*640.)/DAE                                                   X 330
      DO 5 J=N1,N2                                                        X 340
      IF (BK(3,J,1).LE.0.0) GO TO 5                                       X 350
      IF (BK(4,J,1).GT.1.E-5) GO TO 5                                     X 360
      AK3=BK(3,J,1)                                                       X 370
      WRITE (6,6) IPA(J),IPB(J)                                           X 380
      WRITE (6,11)                                                        X 390
      DO 5 I=1,NOFE                                                       X 400
      IF (FLD(I,J).LE.0.0) GO TO 4                                        X 410
      RV1=RVLC(I,J)*DAR                                                   X 420
      RV2=RVB(I,J)*DAR                                                    X 430
      DIV=1.-EXP(-AK3*RV1)                                                X 440
      NWET=NDATE(I,1)                                                     X 450
      IF (NWF.EQ.2) NWET=I                                                X 460
      PLOAD=0.277*WFALL(J,NWET)*DAE*RV1                                   X 470
      IF (NQU(J).EQ.2) PLOAD=PLOAD/1000.                                  X 480
      RLOAD=FLD(I,J)-PLOAD                                                X 490
      ALS=RLOAD/(EXP(-AK3*RV2)*DIV)                                       X 500
      ALS=ALS/DAE                                                         X 510
      WRITE (6,12) I,EAT(I,J),ALS                                         X 520
      GO TO 5                                                             X 530
    4 WRITE (6,12) I,EAT(I,J)                                             X 540
    5 CONTINUE                                                            X 550
      RETURN                                                              X 560
C                                                                         X 570
    6 FORMAT (//1H0,9HDATA FOR ,2A3/)                                     X 580
    7 FORMAT (1H ,I5,5X,I3,1H/,I2,1H/,I2,F12.3,2F16.3)                    X 590
    8 FORMAT (1H1)                                                        X 600
    9 FORMAT (1H ,78HMEASURED AND SIMULATED LOADS ARE BASED ON RUNOFF BE  X 610
     1TWEEN FIRST AND LAST SAMPLE)                                        X 620
   10 FORMAT (1H ,22X,9HSIMULATED,7X,8HMEASURED,7X,12HCONTRIBUTION/1H ,6  X 630
     1H STORM,15X,11HRUNOFF LOAD,5X,11HRUNOFF LOAD,5X,12HTO OBJECTIVE/1H  X 640
     2 ,7H NUMBER,6X,4HDATE,6X,8H(POUNDS),8X,8H(POUNDS),8X,8H FCT. 1 )    X 650
   11 FORMAT (1H ,8X,10HEQUIVALENT,4X,8HEXPECTED/1H ,7X,12HACCUMULATION,  X 660
     13X,7HINITIAL/1H ,7X,13HTIME AT START,2X,12HIMP. SURFACE/1H ,5HSTOR  X 670
     2M,4X,8HOF STORM,5X,12HLOAD (LB/AC))                                 X 680
   12 FORMAT (1H ,I4,5X,F9.2,4X,F10.4,3X,F10.4)                           X 690
      END                                                                 X 700-
      SUBROUTINE STORM(I1)                                                Y  10
C             * STORM ANALYSIS *                                          Y  20
C             --PEAKS,VOLUMES,RUNOFF LOADS                                Y  30
      INTEGER RODYS,TESTNO(180),O1                                        Y  40
      REAL I2CFSP                                                         Y  50
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        Y  60
      COMMON /ST1/ FPK(60),FVOL(60),FLD(60,4),CMX(60,4),WFALL(4,60),NWF   Y  70
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)            Y  80
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT    Y  90
      COMMON /TIME/ NDELS,NOUD(180),INDP(20),NDATE(60,3)                  Y 100
      COMMON /UNIT/ NUDD,NWQ,UD(2881),DP(7310),RODYS,DA,ISS,PTIME,JPR     Y 110
      COMMON /WQ2/ EAT(60,4),XOS(60,4),SFLD(60,4),BFL(60),RVB(60,4)       Y 120
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS             Y 130
      NOFT=NOFE                                                           Y 140
      I4=I1                                                               Y 150
      NOFE=I1                                                             Y 160
C             BEGIN ANALYSIS OF A SET OF EVENTS                           Y 170
      DO 1 I=I1,NUDD                                                      Y 180
      IF (NOUD(I+1).NE.(NOUD(I)+1)) GO TO 2                               Y 190
    1 CONTINUE                                                            Y 200
    2 NFI1=NF(NOFE)                                                       Y 210
      I1=I+1                                                              Y 220
C             BEGIN ANALYSIS OF A STORM                                   Y 230
C             FIND PEAK DISCHARGE                                         Y 240
    3 QR=0.0                                                              Y 250
      QMX=0.0                                                             Y 260
      SRV=0.0                                                             Y 270
      LJ=K1(NOFE)                                                         Y 280
      LM=K2(NOFE)                                                         Y 290
      NFI1=NFI1-1                                                         Y 300
      DO 4 K=LJ,LM                                                        Y 310
      Q3=UD(K)                                                            Y 320
      IF (Q3.LE.QMX) GO TO 4                                              Y 330
      QMX=Q3                                                              Y 340
    4 CONTINUE                                                            Y 350
C             FIND RUNOFF VOLUME                                          Y 360
      DO 5 L=LJ,LM                                                        Y 370
      SRV=SRV+UD(L)                                                       Y 380
    5 CONTINUE                                                            Y 390
      FVOL(NOFE)=SRV/I2CFSP                                               Y 400
      FPK(NOFE)=QMX                                                       Y 410
      IF (NOPT.EQ.1) WRITE (6,12) NOFE,(NDATE(NOFE,III),III=1,3)          Y 420
C          COMPUTE STORM-RUNOFF LOADS                                     Y 430
      DO 11 L=1,NWQ                                                       Y 440
      IF (NWQM(NOFE,L).EQ.0) GO TO 11                                     Y 450
      IV=NWQM(NOFE,L)                                                     Y 460
      LB=TIME(NOFE,L,1)                                                   Y 470
      LE=TIME(NOFE,L,IV)                                                  Y 480
      IF (NOPT.NE.1) GO TO 6                                              Y 490
      WRITE (6,13) IPA(L),IPB(L)                                          Y 500
      IF (CF1(L).GT.1.0E-7) WRITE (6,14) IND(3)                           Y 510
      IF (CF1(L).LT.1.0E-7) WRITE (6,14) IND(4)                           Y 520
    6 J=1                                                                 Y 530
      DO 9 K=LB,LE                                                        Y 540
      IF (K.EQ.LB) GO TO 7                                                Y 550
      RVLC(NOFE,L)=RVLC(NOFE,L)+UD(K)                                     Y 560
    7 AK=K                                                                Y 570
      CALL QWTAB(NOFE,L,AK,F2,J,IV)                                       Y 580
      F2N=F2*UD(K)*CF1(L)                                                 Y 590
      IF (K.EQ.LB) GO TO 8                                                Y 600
      FLD(NOFE,L)=FLD(NOFE,L)+(F2N+F2O)*PTIME*30.                         Y 610
    8 CONTINUE                                                            Y 620
      F2O=F2N                                                             Y 630
      IF (NOPT.NE.1) GO TO 9                                              Y 640
      MOUT=K/NDELS                                                        Y 650
      MOUT=MOUT*NDELS                                                     Y 660
      TOUT=((K-MOUT)*PTIME)/60.                                           Y 670
      IHR=TOUT                                                            Y 680
      TMN=AMOD(TOUT,1.)*60.                                               Y 690
      WRITE (6,15) IHR,TMN,UD(K),F2,IND(J)                                Y 700
      J=2                                                                 Y 710
    9 CONTINUE                                                            Y 720
      DO 10 K=LJ,LB                                                       Y 730
   10 RVB(NOFE,L)=RVB(NOFE,L)+UD(K)                                       Y 740
      RVB(NOFE,L)=RVB(NOFE,L)/I2CFSP                                      Y 750
      RVLC(NOFE,L)=RVLC(NOFE,L)/I2CFSP                                    Y 760
   11 CONTINUE                                                            Y 770
      NOFE=NOFE+1                                                         Y 780
C             CHECK FOR MORE STORMS IN SET OF EVENTS                      Y 790
      IF (NFI1.GT.0) GO TO 3                                              Y 800
      NOFE=NOFT                                                           Y 810
      I1=I4                                                               Y 820
      RETURN                                                              Y 830
C                                                                         Y 840
   12 FORMAT (1H1/1H ,26HSTORM-RUNOFF EVENT NUMBER ,I3,7H  DATED,I3,1H/,  Y 850
     1I2,1H/,I2/14X,46HTHE FOLLOWING DATA ARE USED IN COMPUTING LOADS/15  Y 860
     2X,46H(MEASURED CONCENTRATIONS ARE MARKED WITH AN *))                Y 870
   13 FORMAT (1H0,7X,2A3,6X,4HTIME,9X,9HDISCHARGE,4X,13HCONCENTRATION)    Y 880
   14 FORMAT (1H ,19X,4H(HR),11X,5H(CFS),5X,3H(MI,A3,12HGRAMS/LITER))     Y 890
   15 FORMAT (18X,I2,1H:,F3.0,2(8X,F8.2),A1)                              Y 900
      END                                                                 Y 910-
      SUBROUTINE QWTAB(K,L,F1,F2,J,IV)                                    Z  10
C          THIS SUBROUTINE PERFORMS LINEAR INTERPOLATION                  Z  20
      COMMON /QWD/ CO(60,4,24),TIME(60,4,24),NWQM(60,4),RVLC(60,4)        Z  30
      IF (F1.LT.TIME(K,L,1)) GO TO 3                                      Z  40
      IF (F1.GE.TIME(K,L,IV)) GO TO 4                                     Z  50
      DO 1 I=2,24                                                         Z  60
      IF (F1.GT.TIME(K,L,I)) GO TO 1                                      Z  70
      IF (F1.EQ.TIME(K,L,I)) J=1                                          Z  80
      GO TO 2                                                             Z  90
    1 CONTINUE                                                            Z 100
      I=24                                                                Z 110
    2 F2=CO(K,L,I-1)+(CO(K,L,I)-CO(K,L,I-1))/(TIME(K,L,I)-TIME(K,L,I-1))  Z 120
     1*(F1-TIME(K,L,I-1))                                                 Z 130
      RETURN                                                              Z 140
    3 F2=CO(K,L,1)                                                        Z 150
      J=2                                                                 Z 160
      RETURN                                                              Z 170
    4 F2=CO(K,L,IV)                                                       Z 180
      RETURN                                                              Z 190
      END                                                                 Z 200-
      FUNCTION ITRAN(X)                                                  AA  10
C             THIS FUNCTION NUMBERS LATERAL AND UPSTREAM INFLOW          AA  20
C             SEGMENTS TO CORRESPOND TO THE ISEG'S                       AA  30
      REAL ISEG                                                          AA  40
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)   AA  50
      I=1                                                                AA  60
    1 IF (X-ISEG(I)) 3,2,3                                               AA  70
    2 ITRAN=I                                                            AA  80
      RETURN                                                             AA  90
    3 I=I+1                                                              AA 100
      IF (I-NSEG) 1,1,4                                                  AA 110
    4 ITRAN=0                                                            AA 120
      RETURN                                                             AA 130
      END                                                                AA 140-
      SUBROUTINE ID(IP1,IP2,NWQ,J)                                       AB  10
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT   AB  20
      DO 2 L=1,NWQ                                                       AB  30
      IF (IPA(L).NE.IP1) GO TO 1                                         AB  40
      IF (IPB(L).NE.IP2) GO TO 1                                         AB  50
      J=L                                                                AB  60
      GO TO 3                                                            AB  70
    1 IF (L.LT.NWQ) GO TO 2                                              AB  80
      WRITE (6,4) IP1,IP2                                                AB  90
      STOP                                                               AB 100
    2 CONTINUE                                                           AB 110
    3 CONTINUE                                                           AB 120
      RETURN                                                             AB 130
C                                                                        AB 140
    4 FORMAT (1H ,26HERROR IN SPECIFICATION OF ,48HALPHANUMERIC LABEL FO AB 150
     1R WATER-QUALITY CONSTITUENT,2X,2A4)                                AB 160
      END                                                                AB 170-
      SUBROUTINE HEADR                                                   AC  10
      REAL ISEG                                                          AC  20
      INTEGER HEAD1(120),HEAD2(60,2),HEAD3(60),BD(3),ED(3)               AC  30
      COMMON /C1/ NSEG,ISEG(99),JUP(99,3),JLAT(99,4),ITYPE(99),EFF(51)   AC  40
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE    AC  50
      COMMON /F5/ HEAD1,HEAD2,HEAD3                                      AC  60
      COMMON /Z1/ IUD,ILOAD,I2CFSP,QWINT,AIMP,DAE,DT,DTS,NDTS            AC  70
C     READ (IFILE'1) HEAD1,HEAD2,HEAD3                                  MM062783
      READ (IFILE,REC=1) HEAD1                                          II062783
      READ (IFILE,REC=2) HEAD2                                          II062783
      READ (IFILE,REC=3) HEAD3                                          II062783
      BD(3)=HEAD1(20)/10000                                              AC  90
      BD(1)=(HEAD1(20)/100)-(BD(3)*100)                                  AC 100
      BD(2)=HEAD1(20)-(BD(3)*10000)-(BD(1)*100)                          AC 110
      ED(3)=HEAD1(21)/10000                                              AC 120
      ED(1)=(HEAD1(21)/100)-(ED(3)*100)                                  AC 130
      ED(2)=HEAD1(21)-(ED(3)*10000)-(ED(1)*100)                          AC 140
      K=HEAD1(18)                                                        AC 150
      KK=HEAD1(17)                                                       AC 160
      WRITE (6,4) (HEAD1(I),I=1,19),(BD(I),I=1,3),(ED(I),I=1,3)          AC 170
      N=K+21                                                             AC 180
      WRITE (6,5) (HEAD1(J),J=22,N)                                      AC 190
      WRITE (6,6)                                                        AC 200
      DO 1 I=1,KK                                                        AC 210
      BD(3)=HEAD3(I)/10000                                               AC 220
      BD(1)=(HEAD3(I)/100)-(BD(3)*100)                                   AC 230
      BD(2)=HEAD3(I)-(BD(3)*10000)-(BD(1)*100)                           AC 240
    1 WRITE (6,7) I,BD,HEAD2(I,1),HEAD2(I,2)                             AC 250
      NSEG=HEAD1(18)                                                     AC 260
      DTS=HEAD1(19)                                                      AC 270
      DT=DTS/60                                                          AC 280
      IF (HEAD1(16).GT.JRECDS) GO TO 2                                   AC 290
      RETURN                                                             AC 300
    2 WRITE (6,3) HEAD1(16)                                              AC 310
      STOP                                                               AC 320
C                                                                        AC 330
    3 FORMAT (1H0,29HJRECDS SHOULD EQUAL OR EXCEED,I6)                   AC 340
    4 FORMAT (1H1,44H ***** HEADER RECORDS FROM RUNOFF FILE *****/1H0,27 AC 350
     1HSTREAMFLOW STATION NUMBER -,2A4,/,17H  STATION NAME - ,13A4,/,27H AC 360
     2  NO. OF RECORDS IN FILE = ,I6,/,24H  NO. OF STORM EVENTS = ,I3,/, AC 370
     323H  NUMBER OF SEGMENTS = ,I3,/,18H  DT IN SECONDS = ,I4,/,34H  BE AC 380
     4GINNING DATE OF SIMULATION =  ,I2,1H/,I2,1H/,I2,/,30H  ENDING DATE AC 390
     5 OF SIMULATION = ,I2,1H/,I2,1H/,I2,//,13H  SEGMENT ID )            AC 400
    5 FORMAT (5X,A4)                                                     AC 410
    6 FORMAT (1H1,//,72H  STORM NUMBER      DATE     STARTING RECORD NUM AC 420
     1BER    NUMBER OF VALUES )                                          AC 430
    7 FORMAT (/,7X,I2,8X,I2,1H/,I2,1H/,I2,11X,I5,16X,I7)                 AC 440
      END                                                                AC 450-
      BLOCK DATA                                                         AD  10
      INTEGER TESTNO(180)                                                AD  20
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)           AD  30
      DATA IND/1H*,1H ,3HLLI,3HCRO/                                      AD  40
      END                                                                AD  50-
      SUBROUTINE FILES                                                   AE  10
C              CREATES SPACE ON THE DIRECT ACCESS FILE FOR THE           AE  20
C              NUMBER OF RECORDS REQUESTED (JRECDS).                     AE  30
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE    AE  40
      OPEN (UNIT=15,RECL=240 ,ACCESS='DIRECT',FORM='UNFORMATTED')       II062783
      IFILE=15                                                          MM062383
C     IF (JRECDS.LE.50) GO TO 2                                          AE  60
C     IF (JRECDS.LE.100) GO TO 3                                         AE  70
C     IF (JRECDS-500) 1,7,8                                              AE  80
C   1 IGO=JRECDS/100+1-(1-MIN0(1,MOD(JRECDS,100)))                       AE  90
C     GO TO (3,4,5,6,7), IGO                                             AE 100
CC                                                                       AE 110
C   2 CONTINUE                                                           AE 120
C     DEFINE FILE 25(50,480,L,IRECD)                                     AE 130
C     GO TO 28                                                           AE 140
C   3 CONTINUE                                                           AE 150
C     DEFINE FILE 25(100,480,L,IRECD)                                    AE 160
C     GO TO 28                                                           AE 170
C   4 CONTINUE                                                           AE 180
C     DEFINE FILE 25(200,480,L,IRECD)                                    AE 190
C     GO TO 28                                                           AE 200
C   5 CONTINUE                                                           AE 210
C     DEFINE FILE 25(300,480,L,IRECD)                                    AE 220
C     GO TO 28                                                           AE 230
C   6 CONTINUE                                                           AE 240
C     DEFINE FILE 25(400,480,L,IRECD)                                    AE 250
C     GO TO 28                                                           AE 260
C   7 CONTINUE                                                           AE 270
C     DEFINE FILE 25(500,480,L,IRECD)                                    AE 280
C     GO TO 28                                                           AE 290
C   8 IGO=JRECDS/500-(1-MIN0(1,MOD(JRECDS,500)))                         AE 300
      IF (JRECDS.GT.10000) GO TO 29                                      AE 310
C     GO TO (9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27), I AE 320
C    1GO                                                                 AE 330
CC                                                                       AE 340
C   9 CONTINUE                                                           AE 350
C     DEFINE FILE 25(1000,480,L,IRECD)                                   AE 360
C     GO TO 28                                                           AE 370
C  10 CONTINUE                                                           AE 380
C     DEFINE FILE 25(1500,480,L,IRECD)                                   AE 390
C     GO TO 28                                                           AE 400
C  11 CONTINUE                                                           AE 410
C     DEFINE FILE 25(2000,480,L,IRECD)                                   AE 420
C     GO TO 28                                                           AE 430
C  12 CONTINUE                                                           AE 440
C     DEFINE FILE 25(2500,480,L,IRECD)                                   AE 450
C     GO TO 28                                                           AE 460
C  13 CONTINUE                                                           AE 470
C     DEFINE FILE 25(3000,480,L,IRECD)                                   AE 480
C     GO TO 28                                                           AE 490
C  14 CONTINUE                                                           AE 500
C     DEFINE FILE 25(3500,480,L,IRECD)                                   AE 510
C     GO TO 28                                                           AE 520
C  15 CONTINUE                                                           AE 530
C     DEFINE FILE 25(4000,480,L,IRECD)                                   AE 540
C     GO TO 28                                                           AE 550
C  16 CONTINUE                                                           AE 560
C     DEFINE FILE 25(4500,480,L,IRECD)                                   AE 570
C     GO TO 28                                                           AE 580
C  17 CONTINUE                                                           AE 590
C     DEFINE FILE 25(5000,480,L,IRECD)                                   AE 600
C     GO TO 28                                                           AE 610
C  18 CONTINUE                                                           AE 620
C     DEFINE FILE 25(5500,480,L,IRECD)                                   AE 630
C     GO TO 28                                                           AE 640
C  19 CONTINUE                                                           AE 650
C     DEFINE FILE 25(6000,480,L,IRECD)                                   AE 660
C     GO TO 28                                                           AE 670
C  20 CONTINUE                                                           AE 680
C     DEFINE FILE 25(6500,480,L,IRECD)                                   AE 690
C     GO TO 28                                                           AE 700
C  21 CONTINUE                                                           AE 710
C     DEFINE FILE 25(7000,480,L,IRECD)                                   AE 720
C     GO TO 28                                                           AE 730
C  22 CONTINUE                                                           AE 740
C     DEFINE FILE 25(7500,480,L,IRECD)                                   AE 750
C     GO TO 28                                                           AE 760
C  23 CONTINUE                                                           AE 770
C     DEFINE FILE 25(8000,480,L,IRECD)                                   AE 780
C     GO TO 28                                                           AE 790
C  24 CONTINUE                                                           AE 800
C     DEFINE FILE 25(8500,480,L,IRECD)                                   AE 810
C     GO TO 28                                                           AE 820
C  25 CONTINUE                                                           AE 830
C     DEFINE FILE 25(9000,480,L,IRECD)                                   AE 840
C     GO TO 28                                                           AE 850
C  26 CONTINUE                                                           AE 860
C     DEFINE FILE 25(9500,480,L,IRECD)                                   AE 870
C     GO TO 28                                                           AE 880
C  27 CONTINUE                                                           AE 890
C     DEFINE FILE 25(10000,480,L,IRECD)                                  AE 900
C  28 CONTINUE                                                           AE 910
      RETURN                                                             AE 920
   29 WRITE (6,30)                                                       AE 930
      STOP                                                               AE 940
C                                                                        AE 950
   30 FORMAT (1H0,45H*****ERROR--JRECDS IS GREATER THAN 10000*****)      AE 960
      END                                                                AE 970-
      SUBROUTINE FILE27                                                  AF  10
C              CREATES SPACE ON THE DIRECT ACCESS FILE FOR THE           AF  20
C              NUMBER OF RECORDS REQUESTED (JRECQW).                     AF  30
      COMMON /F2/ IYR,IMO,IDY,NDYS,ICK(60),JCONC,JLOAD,JRECQW            AF  40
      COMMON /F3/ IFILE,IFILED,IFILEQ,JRECDS,IRECD,IRECQ,NSTRMS,IMODE    AF  50
      IFILEQ=17                                                         MM062383
      OPEN (UNIT=17,STATUS='SCRATCH',ACCESS='DIRECT',RECL=240)          II090183
C     IF (JRECQW.LE.50) GO TO 2                                          AF  70
C     IF (JRECQW.LE.100) GO TO 3                                         AF  80
C     IF (JRECQW-500) 1,7,8                                              AF  90
C   1 IGO=JRECQW/100+1-(1-MIN0(1,MOD(JRECQW,100)))                       AF 100
C     GO TO (3,4,5,6,7), IGO                                             AF 110
CC                                                                       AF 120
C   2 CONTINUE                                                           AF 130
C     DEFINE FILE 27(50,480,L,IRECD)                                     AF 140
C     GO TO 18                                                           AF 150
C   3 CONTINUE                                                           AF 160
C     DEFINE FILE 27(100,480,L,IRECD)                                    AF 170
C     GO TO 18                                                           AF 180
C   4 CONTINUE                                                           AF 190
C     DEFINE FILE 27(200,480,L,IRECD)                                    AF 200
C     GO TO 18                                                           AF 210
C   5 CONTINUE                                                           AF 220
C     DEFINE FILE 27(300,480,L,IRECD)                                    AF 230
C     GO TO 18                                                           AF 240
C   6 CONTINUE                                                           AF 250
C     DEFINE FILE 27(400,480,L,IRECD)                                    AF 260
C     GO TO 18                                                           AF 270
C   7 CONTINUE                                                           AF 280
C     DEFINE FILE 27(500,480,L,IRECD)                                    AF 290
C     GO TO 18                                                           AF 300
C   8 IGO=JRECQW/500-(1-MIN0(1,MOD(JRECQW,500)))                         AF 310
      IF (JRECQW.GT.5000) GO TO 19                                       AF 320
C     GO TO (9,10,11,12,13,14,15,16,17), IGO                             AF 330
CC                                                                       AF 340
C   9 CONTINUE                                                           AF 350
C     DEFINE FILE 27(1000,480,L,IRECD)                                   AF 360
C     GO TO 18                                                           AF 370
C  10 CONTINUE                                                           AF 380
C     DEFINE FILE 27(1500,480,L,IRECD)                                   AF 390
C     GO TO 18                                                           AF 400
C  11 CONTINUE                                                           AF 410
C     DEFINE FILE 27(2000,480,L,IRECD)                                   AF 420
C     GO TO 18                                                           AF 430
C  12 CONTINUE                                                           AF 440
C     DEFINE FILE 27(2500,480,L,IRECD)                                   AF 450
C     GO TO 18                                                           AF 460
C  13 CONTINUE                                                           AF 470
C     DEFINE FILE 27(3000,480,L,IRECD)                                   AF 480
C     GO TO 18                                                           AF 490
C  14 CONTINUE                                                           AF 500
C     DEFINE FILE 27(3500,480,L,IRECD)                                   AF 510
C     GO TO 18                                                           AF 520
C  15 CONTINUE                                                           AF 530
C     DEFINE FILE 27(4000,480,L,IRECD)                                   AF 540
C     GO TO 18                                                           AF 550
C  16 CONTINUE                                                           AF 560
C     DEFINE FILE 27(4500,480,L,IRECD)                                   AF 570
C     GO TO 18                                                           AF 580
C  17 CONTINUE                                                           AF 590
C     DEFINE FILE 27(5000,480,L,IRECD)                                   AF 600
C  18 CONTINUE                                                           AF 610
      RETURN                                                             AF 620
   19 WRITE (6,20)                                                       AF 630
      STOP                                                               AF 640
C                                                                        AF 650
   20 FORMAT (1H0,45H*****ERROR--JRECQW IS GREATER THAN  5000*****)      AF 660
      END                                                                AF 670-
C     SUBROUTINE PLT(Q,R,ICNT,IEND,YMAX,I1,J,JK)                         AG  10
CC            THIS SUBROUTINE SETS UP FOR LINE PRINTER PLOTTING          AG  20
C     INTEGER TESTNO(180)                                                AG  30
C     COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)           AG  40
C     COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT   AG  50
C     LOGICAL *1IMAGE(5200)                                              AG  60
C     DIMENSION Q(ICNT), R(ICNT)                                         AG  70
C     GO TO (1,3,4), IEND                                                AG  80
C   1 IX=Q(1)                                                            AG  90
C     IY=Q(ICNT)                                                         AG 100
C     XMIN=IX                                                            AG 110
C     XMAX=IY+1                                                          AG 120
C     IF (JK.EQ.3) XMAX=1.0                                              AG 130
C     DIV=10.                                                            AG 140
C     IF (YMAX.LT.10.) DIV=0.1                                           AG 150
C     IF (YMAX.LT.0.1) DIV=0.01                                          AG 160
C     IF (YMAX.LT.0.01) DIV=0.001                                        AG 170
C     AJ=YMAX/DIV                                                        AG 180
C     IAJ=AJ                                                             AG 190
C     YMAX=(IAJ+1.)*DIV                                                  AG 200
C     IF (JK.EQ.4) XMIN=0.0                                              AG 210
C     IF (JK.EQ.4) XMAX=YMAX                                             AG 220
C     WRITE (6,7)                                                        AG 230
C     IF (JK.EQ.4) GO TO 2                                               AG 240
C     WRITE (6,5) I1                                                     AG 250
C   2 IF (J.GT.0) WRITE (6,6) IPA(J),IPB(J)                              AG 260
C     CALL PLOT2(IMAGE,XMAX,XMIN,YMAX,0.0,6)                             AG 270
C     CALL PLOT3(1HC,Q,R,ICNT)                                           AG 280
C     RETURN                                                             AG 290
C   3 CALL PLOT3(1H0,Q,R,ICNT)                                           AG 300
C     RETURN                                                             AG 310
C   4 CONTINUE                                                           AG 320
C     IF (JK.EQ.4) CALL PLOT4(11,11HSIM. LOADS )                         AG 330
C     IF (JK.EQ.2.AND.CF1(J).GT.1.0E-6) CALL PLOT4(12,12HCON. IN MG/L)   AG 340
C     IF (JK.EQ.2.AND.CF1(J).LT.1.0E-6) CALL PLOT4(12,12HCON. IN UG/L)   AG 350
C     IF (JK.EQ.3) CALL PLOT4(11,11HCHAR. CURVE)                         AG 360
C     RETURN                                                             AG 370
CC                                                                       AG 380
C   5 FORMAT (33X,12HSTORM NUMBER,I3)                                    AG 390
C   6 FORMAT (1H ,32X,2A3)                                               AG 400
C   7 FORMAT (1H1)                                                       AG 410
C     END                                                                AG 420-
C     SUBROUTINE PRPLOT                                                  AH  10
C     IMPLICIT LOGICAL*1(W),LOGICAL*1(K)                                 AH  20
C     DIMENSION NSCALE(5), ABNOS(26), X(1), Y(1)                         AH  30
C     LOGICAL *1NOS(10)/'0','1','2','3','4','5','6','7','8','9'/         AH  40
C     LOGICAL *1IMAGE(1),CH,LABEL(1),ERR1,ERR3,ERR5                      AH  50
C     LOGICAL *1VC,HC,FOR1(19),FOR2(15),FOR3(19),NC,BL,HF,HF1            AH  60
C     REAL *8FOX1(3),FOX2(2),FOX3(3)                                     AH  70
C     INTEGER *2VCR                                                      AH  80
C     EQUIVALENCE (FOR1(1),FOX1(1)), (FOR2(1),FOX2(1)), (FOR3(1),FOX3(1) AH  90
C    1), (VC,VCR)                                                        AH 100
C     INTEGER FILE                                                       AH 110
C     DATA HC/'-'/,NC/'+'/,BL/' '/,HF/'F'/,HF1/'.'/                      AH 120
C     DATA FOX1/'(1XA1,F9','.2,  121','A1)     '/                        AH 130
C     DATA FOX2/'(1XA1, 9','X121A1) '/                                   AH 140
C     DATA FOX3/'(1H0F  .',' ,  F   ','. )     '/                        AH 150
C     DATA VCR/Z4F00/                                                    AH 160
C     DATA KPLOT1/.FALSE./,KPLOT2/.FALSE./                               AH 170
C     DATA KABSC,KORD,KBOTGL/3*.FALSE./                                  AH 180
CC                                                                       AH 190
C     ENTRY PLOT1(NSCALE,NHL,NSBH,NVL,NSBV)                              AH 200
C     IFL=FILE                                                           AH 210
C     ERR1=.FALSE.                                                       AH 220
C     ERR3=.FALSE.                                                       AH 230
C     ERR5=.FALSE.                                                       AH 240
C     KPLOT1=.TRUE.                                                      AH 250
C     KPLOT2=.FALSE.                                                     AH 260
C     NH=IABS(NHL)                                                       AH 270
C     NSH=IABS(NSBH)                                                     AH 280
C     NV=IABS(NVL)                                                       AH 290
C     NSV=IABS(NSBV)                                                     AH 300
C     NSCL=NSCALE(1)                                                     AH 310
C     IF (NH*NSH*NV*NSV.NE.0) GO TO 1                                    AH 320
C     KPLOT=.FALSE.                                                      AH 330
C     ERR1=.TRUE.                                                        AH 340
C     RETURN                                                             AH 350
C   1 KPLOT=.TRUE.                                                       AH 360
C     IF (NV.LE.25) GO TO 2                                              AH 370
C     KPLOT=.FALSE.                                                      AH 380
C     ERR3=.TRUE.                                                        AH 390
C     RETURN                                                             AH 400
C   2 CONTINUE                                                           AH 410
C     NVM=NV-1                                                           AH 420
C     NVP=NV+1                                                           AH 430
C     NDH=NH*NSH                                                         AH 440
C     NDHP=NDH+1                                                         AH 450
C     NDV=NV*NSV                                                         AH 460
C     NDVP=NDV+1                                                         AH 470
C     NIMG=(NDHP*NDVP)                                                   AH 480
C     IF (NDV.LE.120) GO TO 3                                            AH 490
C     KPLOT=.FALSE.                                                      AH 500
C     ERR5=.TRUE.                                                        AH 510
C     RETURN                                                             AH 520
C   3 CONTINUE                                                           AH 530
C     IF (NSCL.EQ.0) GO TO 4                                             AH 540
C     FSY=10.**NSCALE(2)                                                 AH 550
C     FSX=10.**NSCALE(4)                                                 AH 560
C     IY=MIN0(IABS(NSCALE(3)),7)+1                                       AH 570
C     IX=MIN0(IABS(NSCALE(5)),9)+1                                       AH 580
C     GO TO 5                                                            AH 590
C   4 FSY=1.                                                             AH 600
C     FSX=1.                                                             AH 610
C     IY=4                                                               AH 620
C     IX=4                                                               AH 630
C   5 FOR1(10)=NOS(IY)                                                   AH 640
C     NA=MIN0(IX,NSV)-1                                                  AH 650
C     NS=NA-MIN0(NA,120-NDV)                                             AH 660
C     NB=11-NS+NA                                                        AH 670
C     I1=NB/10                                                           AH 680
C     I2=NB-I1*10                                                        AH 690
C     FOR3(6)=NOS(I1+1)                                                  AH 700
C     FOR3(7)=NOS(I2+1)                                                  AH 710
C     FOR3(9)=NOS(NA+1)                                                  AH 720
C     IF (NV.GT.0) GO TO 7                                               AH 730
C     DO 6 J=11,18                                                       AH 740
C   6 FOR3(J)=BL                                                         AH 750
C     GO TO 8                                                            AH 760
C   7 I1=NV/10                                                           AH 770
C     I2=NV-I1*10                                                        AH 780
C     FOR3(11)=NOS(I1+1)                                                 AH 790
C     FOR3(12)=NOS(I2+1)                                                 AH 800
C     FOR3(13)=HF                                                        AH 810
C     I1=NSV/100                                                         AH 820
C     I3=NSV-I1*100                                                      AH 830
C     I2=I3/10                                                           AH 840
C     I3=I3-I2*10                                                        AH 850
C     FOR3(14)=NOS(I1+1)                                                 AH 860
C     FOR3(15)=NOS(I2+1)                                                 AH 870
C     FOR3(16)=NOS(I3+1)                                                 AH 880
C     FOR3(17)=HF1                                                       AH 890
C     FOR3(18)=FOR3(9)                                                   AH 900
C   8 IF (KPLOT1) RETURN                                                 AH 910
C     KPLOT1=.TRUE.                                                      AH 920
CC                                                                       AH 930
C     ENTRY PLOT2(IMAGE,XMAX,XMIN,YMAX,YMIN,FILE)                        AH 940
C     IFL=FILE                                                           AH 950
C     KPLOT2=.TRUE.                                                      AH 960
C     IF (KPLOT1) GO TO 9                                                AH 970
C     NSCL=0                                                             AH 980
C     NH=5                                                               AH 990
C     NSH=10                                                             AH1000
C     NV=10                                                              AH1010
C     NSV=10                                                             AH1020
C     GO TO 1                                                            AH1030
C   9 CONTINUE                                                           AH1040
C     IF (KPLOT) GO TO 10                                                AH1050
C     IF (ERR1) WRITE (IFL,30)                                           AH1060
C     IF (ERR3) WRITE (IFL,31)                                           AH1070
C     IF (ERR5) WRITE (IFL,32)                                           AH1080
C     RETURN                                                             AH1090
C  10 YMX=YMAX                                                           AH1100
C     DH=(YMAX-YMIN)/FLOAT(NDH)                                          AH1110
C     DV=(XMAX-XMIN)/FLOAT(NDV)                                          AH1120
C     DO 11 I=1,NVP                                                      AH1130
C  11 ABNOS(I)=(XMIN+FLOAT((I-1)*NSV)*DV)*FSX                            AH1140
C     DO 12 I=1,NIMG                                                     AH1150
C  12 IMAGE(I)=BL                                                        AH1160
C     DO 16 I=1,NDHP                                                     AH1170
C     I2=I*NDVP                                                          AH1180
C     I1=I2-NDV                                                          AH1190
C     KNHOR=MOD(I-1,NSH).NE.0                                            AH1200
C     IF (KNHOR) GO TO 14                                                AH1210
C     DO 13 J=I1,I2                                                      AH1220
C  13 IMAGE(J)=HC                                                        AH1230
C  14 CONTINUE                                                           AH1240
C     DO 16 J=I1,I2,NSV                                                  AH1250
C     IF (KNHOR) GO TO 15                                                AH1260
C     IMAGE(J)=NC                                                        AH1270
C     GO TO 16                                                           AH1280
C  15 IMAGE(J)=VC                                                        AH1290
C  16 CONTINUE                                                           AH1300
C     XMIN1=XMIN-DV/2.                                                   AH1310
C     YMIN1=YMIN-DH/2.                                                   AH1320
C     RETURN                                                             AH1330
CC                                                                       AH1340
C     ENTRY PLOT3(CH,X,Y,N3)                                             AH1350
C     IF (KPLOT2) GO TO 18                                               AH1360
C  17 WRITE (IFL,33)                                                     AH1370
C  18 CONTINUE                                                           AH1380
C     IF (.NOT.KPLOT) RETURN                                             AH1390
C     IF (N3.GT.0) GO TO 19                                              AH1400
C     KPLOT=.FALSE.                                                      AH1410
C     WRITE (IFL,34)                                                     AH1420
C     RETURN                                                             AH1430
C  19 DO 26 I=1,N3                                                       AH1440
C     IF (DV) 21,20,21                                                   AH1450
C  20 DUM1=0                                                             AH1460
C     GO TO 22                                                           AH1470
C  21 CONTINUE                                                           AH1480
C     DUM1=(X(I)-XMIN1)/DV                                               AH1490
C  22 IF (DH) 24,23,24                                                   AH1500
C  23 DUM2=0                                                             AH1510
C     GO TO 25                                                           AH1520
C  24 CONTINUE                                                           AH1530
C     DUM2=(Y(I)-YMIN1)/DH                                               AH1540
C  25 CONTINUE                                                           AH1550
C     IF (DUM1.LT.0..OR.DUM2.LT.0.) GO TO 26                             AH1560
C     IF (DUM1.GE.NDVP.OR.DUM2.GE.NDHP) GO TO 26                         AH1570
C     NX=1+INT(DUM1)                                                     AH1580
C     NY=1+INT(DUM2)                                                     AH1590
C     J=(NDHP-NY)*NDVP+NX                                                AH1600
C     IMAGE(J)=CH                                                        AH1610
C  26 CONTINUE                                                           AH1620
C     RETURN                                                             AH1630
CC                                                                       AH1640
C     ENTRY PLOT4(NL,LABEL)                                              AH1650
C     ENTRY FPLOT4(NL,LABEL)                                             AH1660
C     IF (.NOT.KPLOT) RETURN                                             AH1670
C     IF (.NOT.KPLOT2) GO TO 17                                          AH1680
C     DO 28 I=1,NDHP                                                     AH1690
C     IF (I.EQ.NDHP.AND.KBOTGL) GO TO 28                                 AH1700
C     WL=BL                                                              AH1710
C     IF (I.LE.NL) WL=LABEL(I)                                           AH1720
C     I2=I*NDVP                                                          AH1730
C     I1=I2-NDV                                                          AH1740
C     IF (MOD(I-1,NSH).EQ.0.AND..NOT.KORD) GO TO 27                      AH1750
C     WRITE (IFL,FOR2) WL,(IMAGE(J),J=I1,I2)                             AH1760
C     GO TO 28                                                           AH1770
C  27 CONTINUE                                                           AH1780
C     ORDNO=(YMX-FLOAT(I-1)*DH)*FSY                                      AH1790
C     IF (I.EQ.NDHP) ORDNO=YMIN                                          AH1800
C     WRITE (IFL,FOR1) WL,ORDNO,(IMAGE(J),J=I1,I2)                       AH1810
C  28 CONTINUE                                                           AH1820
C     IF (KABSC) GO TO 29                                                AH1830
C     WRITE (IFL,FOR3) (ABNOS(J),J=1,NVP)                                AH1840
C  29 RETURN                                                             AH1850
CC                                                                       AH1860
C     ENTRY OMIT(LSW)                                                    AH1870
C     KABSC=MOD(LSW,2).EQ.1                                              AH1880
C     KORD=MOD(LSW,4).GE.2                                               AH1890
C     KBOTGL=LSW.GE.4                                                    AH1900
C     RETURN                                                             AH1910
CC                                                                       AH1920
CC                                                                       AH1930
CC                                                                       AH1940
C  30 FORMAT (T5,'SOME PLOT1 ARG. ILLEGALLY 0')                          AH1950
C  31 FORMAT (T5,'NO. OF VERTICAL LINES >25')                            AH1960
C  32 FORMAT (T5,'WIDTH OF GRAPH >121')                                  AH1970
C  33 FORMAT (T5,'PLOT2 MUST BE CALLED')                                 AH1980
C  34 FORMAT (T5,'PLOT3, ARG2 ) 0')                                      AH1990
C     END                                                                AH2000-
      SUBROUTINE PLT(Q,R,ICNT,IEND,YMAX,I1,J,JK)                         AG  10
C             THIS SUBROUTINE SETS UP FOR LINE PRINTER PLOTTING          AG  20
      INTEGER TESTNO(180)                                                AG  30
      COMMON /ST2/ NOFE,NF(60),NQU(4),TESTNO,KNN,CF1(4),IND(4)           AG  40
      COMMON /ST3/ IPL(180),K1(60),K2(60),KOUT(180),IPA(4),IPB(4),NOPT   AG  50
C     LOGICAL *1IMAGE(5200)                                              AG  60
      DIMENSION Q(ICNT), R(ICNT)                                         AG  70
C ***** CHANGE FOR THE HARRIS *****                                     XXXXXXXX
      LOGICAL   KPLOT1,KPLOT2,KPLOT                                     XXXXXXXX
      INTEGER   NSCALE(5)                                               XXXXXXXX
      CHARACTER*1 IMAGE(5200),CH                                        XXXXXXXX
      CHARACTER*12 LABEL,LABELX                                         XXXXXXXX
      INTEGER FILE                                                      XXXXXXXX
      COMMON /PLOT1/ NSCALE,NHL,NSBH,NVL,NSBV                           XXXXXXXX
      COMMON /PLOTI/ IMAGE                                              XXXXXXXX
      COMMON /PLOT2/       XMAX,XMIN,     YMIN,FILE                     XXXXXXXX
      COMMON /PLOT3/ CH                                                 XXXXXXXX
      COMMON /PLOT4/ NL,LABEL,LABELX                                    XXXXXXXX
      COMMON /KP/ KPLOT1,KPLOT2,KPLOT                                   XXXXXXXX
      KPLOT1 = .FALSE.                                                  XXXXXXXX
      KPLOT2 = .FALSE.                                                  XXXXXXXX
      KPLOT = .FALSE.                                                   XXXXXXXX
      FILE = 6                                                          XXXXXXXX
      YMIN = 0.0                                                        XXXXXXXX
      NL = 11                                                           XXXXXXXX
C ***** CHANGE FOR THE HARRIS *****                                     XXXXXXXX
      GO TO (10,30,40), IEND                                            AML0584
 10   IX=Q(1)                                                           AML0584
      IY=Q(ICNT)                                                         AG 100
      XMIN=IX                                                            AG 110
      XMAX=IY+1                                                          AG 120
      IF (JK.EQ.3) XMAX=1.0                                              AG 130
      DIV=10.                                                            AG 140
      IF (YMAX.LT.10.) DIV=0.1                                           AG 150
      IF (YMAX.LT.0.1) DIV=0.01                                          AG 160
      IF (YMAX.LT.0.01) DIV=0.001                                        AG 170
      AJ=YMAX/DIV                                                        AG 180
      IAJ=AJ                                                             AG 190
      YMAX=(IAJ+1.)*DIV                                                  AG 200
      IF (JK.EQ.4) XMIN=0.0                                              AG 210
      IF (JK.EQ.4) XMAX=YMAX                                             AG 220
      WRITE (6,7)                                                        AG 230
      IF (JK.EQ.4) GO TO 20                                             AML0584
      WRITE (6,5) I1                                                     AG 250
 20   IF (J.GT.0) WRITE (6,6) IPA(J),IPB(J)                             AML0584
C     CALL PLOT2(IMAGE,XMAX,XMIN,YMAX,0.0,6)                             AG 270
      CALL PRPLOT (2,Q,R,ICNT,YMAX)                                     AML0584
C     CALL PLOT3(1HC,Q,R,ICNT)                                           AG 280
      CH = 'C'
      CALL PRPLOT (3,Q,R,ICNT,YMAX)                                     AML0584
      RETURN                                                             AG 290
C   3 CALL PLOT3(1H0,Q,R,ICNT)                                           AG 300
 30   CH = '0'                                                          AML0584
      CALL PRPLOT (3,Q,R,ICNT,YMAX)                                     AML0584
      RETURN                                                             AG 310
 40   CONTINUE                                                          AML0584
C     IF (JK.EQ.4) CALL PLOT4(11,11HSIM. LOADS )                         AG 330
      IF (JK.EQ.4) THEN                                                 AML0584
        LABEL =' SIM. LOADS '                                           AML0584
        LABELX ='             '                                         AML0584
        CALL PRPLOT (4,Q,R,ICNT,YMAX)                                   AML0584
      END IF                                                            AML0584
C     IF (JK.EQ.2.AND.CF1(J).GT.1.0E-6) CALL PLOT4(12,12HCON. IN MG/L)   AG 340
      IF (JK.EQ.2.AND.CF1(J).GT.1.0E-6) THEN                            AML0584
        LABEL ='CON. MG/L    '                                          AML0584
        LABELX ='  TIME (HRS) '                                         AML0584
        CALL PRPLOT (4,Q,R,ICNT,YMAX)                                   AML0584
      END IF                                                            AML0584
C     IF (JK.EQ.2.AND.CF1(J).LT.1.0E-6) CALL PLOT4(12,12HCON. IN UG/L)   AG 350
      IF (JK.EQ.2.AND.CF1(J).LT.1.0E-6) THEN                            AML0584
        LABEL ='CON. MG/L    '                                          AML0584
        LABELX ='  TIME (HRS) '                                         AML0584
        CALL PRPLOT (4,Q,R,ICNT,YMAX)                                   AML0584
      END IF                                                            AML0584
C     IF (JK.EQ.3) CALL PLOT4(11,11HCHAR. CURVE)                         AG 360
      IF (JK.EQ.3) THEN                                                 AML0584
        LABEL ='CHAR CURVE   '                                          AML0584
        LABELX ='             '                                         AML0584
        CALL PRPLOT (4,Q,R,ICNT,YMAX)                                   AML0584
      END IF                                                            AML0584
      RETURN                                                             AG 370
C                                                                        AG 380
    5 FORMAT (33X,12HSTORM NUMBER,I3)                                    AG 390
    6 FORMAT (1H ,32X,2A3)                                               AG 400
    7 FORMAT (1H1)                                                       AG 410
      END                                                                AG 420-
      SUBROUTINE PRPLOT(INTRY,X,Y,N3,YMAX)                              XXXXXXXX
C     IMPLICIT LOGICAL*1(W),LOGICAL*1(K)                                00027940
      LOGICAL   KABSC,KBOTGL,KNHOR,KORD,KPLOT,KPLOT1,KPLOT2             XXXXXXXX
      DIMENSION NSCALE(5), ABNOS(26), X(1), Y(1)                        00027950
C     LOGICAL*1 NOS(10)/'0','1','2','3','4','5','6','7','8','9'/        00027960
C     LOGICAL*1 IMAGE(1),CH,LABEL(1),ERR1,ERR3,ERR5                     00027970
      CHARACTER*1 IMAGE(5200),CH                                        XXXXXXXX
      CHARACTER*12 LABEL,WL,BL,LABELX                                   XXXXXXXX
C     LOGICAL*1 VC,HC,FOR1(19),FOR2(15),FOR3(19),NC,BL,HF,HF1           00027980
      CHARACTER*1 VC,HC,NC,HF,HF1                                       XXXXXXXX
C     REAL*8 FOX1(3),FOX2(2),FOX3(3)                                    00027990
C     INTEGER*2 VCR                                                     00028000
C     EQUIVALENCE (FOR1(1),FOX1(1)),(FOR2(1),FOX2(1)),(FOR3(1),FOX3(1)),00028010
C    1,(VC,VCR)                                                         00028020
      INTEGER FILE                                                      00028030
      COMMON /PLOT1/ NSCALE,NHL,NSBH,NVL,NSBV                           XXXXXXXX
      COMMON /PLOTI/ IMAGE                                              XXXXXXXX
      COMMON /PLOT2/       XMAX,XMIN,  YMIN,IFL                         XXXXXXXX
      COMMON /PLOT3/ CH                                                 XXXXXXXX
      COMMON /PLOT4/ NL,LABEL,LABELX                                    XXXXXXXX
      COMMON /KP/ KPLOT1,KPLOT2,KPLOT                                   XXXXXXXX
C     DATA HC/'-'/,NC/'+'/,BL/' '/,HF/'F'/,HF1/'.'/                     00028040
      DATA HC/'-'/,NC/'+'/,BL/'            '/                           XXXXXXXX
C     DATA FOX1/'(1XA1,F9','.2,  121','A1)     '/                       00028050
C     DATA FOX2/'(1XA1, 9','X121A1) '/                                  00028060
C     DATA FOX3/'(1H0F  .',' ,  F   ','. )     '/                       00028070
C     DATA VCR/Z4F00/                                                   00028080
      DATA VC/'!'/                                                      XXXXXXXX
C     DATA KPLOT1/.FALSE./,KPLOT2/.FALSE./                              00028090
      DATA KABSC,KORD,KBOTGL/3*.FALSE./                                 00028100
C                                                                       00028110
C     ENTRY PLOT1(NSCALE,NHL,NSBH,NVL,NSBV)                             00028120
      GO TO (101,102,103,104) INTRY                                     XXXXXXXX
  101 CONTINUE                                                          XXXXXXXX
C     IFL=FILE                                                          00028130
C     ERR1=.FALSE.                                                      00028140
C     ERR3=.FALSE.                                                      00028150
C     ERR5=.FALSE.                                                      00028160
C     KPLOT1=.TRUE.                                                     00028170
C     KPLOT2=.FALSE.                                                    00028180
C     NH=IABS(NHL)                                                      00028190
C     NSH=IABS(NSBH)                                                    00028200
C     NV=IABS(NVL)                                                      00028210
C     NSV=IABS(NSBV)                                                    00028220
C     NSCL=NSCALE(1)                                                    00028230
C     IZ = 0
C     II = NH*NSH*NV*NSV
C     IF (II.NE.IZ) GO TO 1                                             00028240
C     KPLOT=.FALSE.                                                     00028250
C     ERR1=.TRUE.                                                       00028260
C     RETURN                                                            00028270
C ----------------------------------------------------------------------XXXXXXXX
    1 KPLOT=.TRUE.                                                      00028280
C     WRITE(6,701)                                                      XXXXXXXX
C     IF (NV.LE.25) GO TO 2                                             00028290
C     KPLOT=.FALSE.                                                     00028300
C     ERR3=.TRUE.                                                       00028310
C     RETURN                                                            00028320
    2 CONTINUE                                                          00028330
      NVM=NV-1                                                          00028340
      NVP=NV+1                                                          00028350
      NDH=NH*NSH                                                        00028360
      NDHP=NDH+1                                                        00028370
      NDV=NV*NSV                                                        00028380
      NDVP=NDV+1                                                        00028390
      NIMG=(NDHP*NDVP)                                                  00028400
      IF (NDV.LE.120) GO TO 3                                           00028410
      KPLOT=.FALSE.                                                     00028420
C     ERR5=.TRUE.                                                       00028430
      RETURN                                                            00028440
    3 CONTINUE                                                          00028450
      IF (NSCL.EQ.0) GO TO 4                                            00028460
      FSY=10.**NSCALE(2)                                                00028470
      FSX=10.**NSCALE(4)                                                00028480
      IY=MIN0(IABS(NSCALE(3)),7)+1                                      00028490
      IX=MIN0(IABS(NSCALE(5)),9)+1                                      00028500
      GO TO 5                                                           00028510
    4 FSY=1.                                                            00028520
      FSX=1.                                                            00028530
      IY=4                                                              00028540
      IX=4                                                              00028550
    5 CONTINUE                                                          XXXXXXXX
C   5 FOR1(10)=NOS(IY)                                                  00028560
C     NA=MIN0(IX,NSV)-1                                                 00028570
C     NS=NA-MIN0(NA,120-NDV)                                            00028580
C     NB=11-NS+NA                                                       00028590
C     I1=NB/10                                                          00028600
C     I2=NB-I1*10                                                       00028610
C     FOR3(6)=NOS(I1+1)                                                 00028620
C     FOR3(7)=NOS(I2+1)                                                 00028630
C     FOR3(9)=NOS(NA+1)                                                 00028640
C     IF (NV.GT.0) GO TO 7                                              00028650
C     DO 6 J=11,18                                                      00028660
C   6 FOR3(J)=BL                                                        00028670
C     GO TO 8                                                           00028680
C   7 I1=NV/10                                                          00028690
C     I2=NV-I1*10                                                       00028700
C     FOR3(11)=NOS(I1+1)                                                00028710
C     FOR3(12)=NOS(I2+1)                                                00028720
C     FOR3(13)=HF                                                       00028730
C     I1=NSV/100                                                        00028740
C     I3=NSV-I1*100                                                     00028750
C     I2=I3/10                                                          00028760
C     I3=I3-I2*10                                                       00028770
C     FOR3(14)=NOS(I1+1)                                                00028780
C     FOR3(15)=NOS(I2+1)                                                00028790
C     FOR3(16)=NOS(I3+1)                                                00028800
C     FOR3(17)=HF1                                                      00028810
C     FOR3(18)=FOR3(9)                                                  00028820
    8 IF (KPLOT1) RETURN                                                00028830
      KPLOT1=.TRUE.                                                     00028840
C                                                                       00028850
C     ENTRY PLOT2(IMAGE,XMAX,XMIN,YMAX,YMIN,FILE)                       00028860
  102 CONTINUE                                                          XXXXXXXX
C     WRITE(6,702)                                                      XXXXXXXX
C     IFL=FILE                                                          00028870
      KPLOT2=.TRUE.                                                     00028880
      IF (KPLOT1) GO TO 9                                               00028890
      NSCL=0                                                            00028900
      NH=5                                                              00028910
      NSH=10                                                            00028920
      NV=10                                                             00028930
      NSV=10                                                            00028940
      GO TO 1                                                           00028950
    9 CONTINUE                                                          00028960
C     IF (KPLOT) GO TO 10                                               00028970
C     IF (ERR1) WRITE (IFL,30)                                          00028980
C     IF (ERR3) WRITE (IFL,31)                                          00028990
C     IF (ERR5) WRITE (IFL,32)                                          00029000
C     RETURN                                                            00029010
   10 YMX=YMAX                                                          00029020
      DH=(YMAX-YMIN)/FLOAT(NDH)                                         00029030
      DV=(XMAX-XMIN)/FLOAT(NDV)                                         00029040
      DO 11 I=1,NVP                                                     00029050
   11 ABNOS(I)=(XMIN+FLOAT((I-1)*NSV)*DV)*FSX                           00029060
      DO 12 I=1,NIMG                                                    00029070
   12 IMAGE(I)=BL                                                       00029080
      DO 16 I=1,NDHP                                                    00029090
      I2=I*NDVP                                                         00029100
      I1=I2-NDV                                                         00029110
C     KNHOR=MOD(I-1,NSH).NE.0                                           00029120
C     IF (KNHOR) GO TO 14                                               00029130
      IF (MOD(I-1,NSH).NE.0) GO TO 14                                   XXXXXXXX
      DO 13 J=I1,I2                                                     00029140
   13 IMAGE(J)=HC                                                       00029150
   14 CONTINUE                                                          00029160
      DO 16 J=I1,I2,NSV                                                 00029170
C     IF (KNHOR) GO TO 15                                               00029180
      IF (MOD(I-1,NSH).NE.0) GO TO 15                                   XXXXXXXX
      IMAGE(J)=NC                                                       00029190
      GO TO 16                                                          00029200
   15 IMAGE(J)=VC                                                       00029210
   16 CONTINUE                                                          00029220
      XMIN1=XMIN-DV/2.                                                  00029230
      YMIN1=YMIN-DH/2.                                                  00029240
      RETURN                                                            00029250
C                                                                       00029260
C     ENTRY PLOT3(CH,X,Y,N3)                                            00029270
 103  CONTINUE                                                          XXXXXXXX
C     WRITE(6,703)                                                      XXXXXXXX
C     IF (KPLOT2) GO TO 18                                              00029280
C  17 WRITE (IFL,33)                                                    00029290
C  18 CONTINUE                                                          00029300
C     IF (.NOT.KPLOT) RETURN                                            00029310
C     IF (N3.GT.0) GO TO 19                                             00029320
C     KPLOT=.FALSE.                                                     00029330
C     WRITE (IFL,34)                                                    00029340
C     RETURN                                                            00029350
   19 DO 26 I=1,N3                                                      00029360
      IF (DV) 21,20,21                                                  00029370
   20 DUM1=0                                                            00029380
      GO TO 22                                                          00029390
   21 CONTINUE                                                          00029400
      DUM1=(X(I)-XMIN1)/DV                                              00029410
   22 IF (DH) 24,23,24                                                  00029420
   23 DUM2=0                                                            00029430
      GO TO 25                                                          00029440
   24 CONTINUE                                                          00029450
      DUM2=(Y(I)-YMIN1)/DH                                              00029460
   25 CONTINUE                                                          00029470
      IF (DUM1.LT.0..OR.DUM2.LT.0.) GO TO 26                            00029480
      IF (DUM1.GE.NDVP.OR.DUM2.GE.NDHP) GO TO 26                        00029490
      NX=1+INT(DUM1)                                                    00029500
      NY=1+INT(DUM2)                                                    00029510
      J=(NDHP-NY)*NDVP+NX                                               00029520
      IMAGE(J)=CH                                                       00029530
   26 CONTINUE                                                          00029540
      RETURN                                                            00029550
C                                                                       00029560
C     ENTRY PLOT4(NL,LABEL)                                             00029570
C     ENTRY FPLOT4(NL,LABEL)                                            00029580
 104  CONTINUE                                                          XXXXXXXX
C     WRITE(6,704)                                                      XXXXXXXX
C     IF (.NOT.KPLOT) RETURN                                            00029590
C     IF (.NOT.KPLOT2) GO TO 17                                         00029600
C     WRITE(6,705) NDHP                                                 XXXXXXXX
      DO 28 I=1,NDHP                                                    00029610
      IF (I.EQ.NDHP.AND.KBOTGL) GO TO 28                                00029620
      WL=BL                                                             00029630
C     IF (I.LE.NL) WL=LABEL                                             00029640
      IF (I.EQ.NDHP/2) WL = LABEL                                       XXXXXXXX
      I2=I*NDVP                                                         00029650
      I1=I2-NDV                                                         00029660
      IF (MOD(I-1,NSH).EQ.0.AND..NOT.KORD) GO TO 27                     00029670
C     WRITE (IFL,FOR2) WL,(IMAGE(J),J=I1,I2)                            00029680
      WRITE (IFL,602)  WL,(IMAGE(J),J=I1,I2)                            XXXXXXXX
      GO TO 28                                                          00029690
   27 CONTINUE                                                          00029700
      ORDNO=(YMX-FLOAT(I-1)*DH)*FSY                                     00029710
      IF (I.EQ.NDHP) ORDNO=YMIN                                         00029720
C     WRITE (IFL,FOR1) WL,ORDNO,(IMAGE(J),J=I1,I2)                      00029730
      WRITE (IFL,601)  WL,ORDNO,(IMAGE(J),J=I1,I2)                      XXXXXXXX
   28 CONTINUE                                                          00029740
      IF (KABSC) GO TO 29                                               00029750
C     WRITE (IFL,FOR3) (ABNOS(J),J=1,NVP)                               00029760
      WRITE (IFL,603)  (ABNOS(J),J=1,NVP)                               XXXXXXXX
      WRITE(IFL,604) LABELX                                             XXXXXXXX
   29 RETURN                                                            00029770
C                                                                       00029780
C     ENTRY OMIT(LSW)                                                   00029790
C     KABSC=MOD(LSW,2).EQ.1                                             00029800
C     KORD=MOD(LSW,4).GE.2                                              00029810
C     KBOTGL=LSW.GE.4                                                   00029820
C     RETURN                                                            00029830
C                                                                       00029840
  601 FORMAT(1X,A1,F9.2,121A1)                                          XXXXXXXX
  602 FORMAT(1X,A10,121A1)                                              XXXXXXXX
  603 FORMAT(1H0,1X,11F10.2)                                            XXXXXXXX
  604 FORMAT(56X,A12)                                                   XXXXXXXX
  701 FORMAT('  ENTRY POINT 1')                                         XXXXXXXX
  702 FORMAT('  ENTRY POINT 2')                                         XXXXXXXX
  703 FORMAT('  ENTRY POINT 3')                                         XXXXXXXX
  704 FORMAT('  ENTRY POINT 4')                                         XXXXXXXX
  705 FORMAT('  BEGIN LOOP, NDHP =',I5)                                 XXXXXXXX
C                                                                       00029860
   30 FORMAT (T5,'SOME PLOT1 ARG. ILLEGALLY 0')                         00029870
   31 FORMAT (T5,'NO. OF VERTICAL LINES >25')                           00029880
   32 FORMAT (T5,'WIDTH OF GRAPH >121')                                 00029890
   33 FORMAT (T5,'PLOT2 MUST BE CALLED')                                00029900
   34 FORMAT (T5,'PLOT3, ARG2 > 0')                                     00029910
      END                                                               00029920
