**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// (c) MarkOneTools - www.markonetools.it - 2026

// Esempio 8: PGMA e PGMB vengono eseguiti in *DFTACTGRP con COMMIT = *CHG
//            PGMA chiama il PGMB
//            PGMB esegue un update di un record
//                 NON esegue commit esplicito e ritorna al chiamante
//            PGMA esegue update sullo stesso record toccato da pgmB

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes);

dcl-f EMPLO01L keyed usage(*update) rename(EMPLOYEE:EMPREC) commit;
dcl-ds kEmp likerec(EMPREC:*key);


kEmp.WORKDEPT = 'B01';
kEmp.EMPNO = '000020';

chain %kds(kEmp) EMPLO01L;
if %found();
  BONUS = BONUS + 100;
  update EMPREC;
endif;

*inlr = *on;
return;
