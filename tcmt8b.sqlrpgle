**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// Esempio 8: PGMA viene eseguito in ACTGRP(*NEW) e pgmB in *DFTACTGRP con COMMIT = *CHG
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

exec sql
  set option COMMIT = *CHG;

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 100
    where EMPNO = '000020';

*inlr = *on;
return;
