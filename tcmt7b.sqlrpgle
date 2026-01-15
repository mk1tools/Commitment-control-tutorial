**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// (c) MarkOneTools - www.markonetools.it - 2026

// Esempio 7: PGMA viene eseguito in ACTGRP(*NEW) e PGMB in ACTGRP(*CALLER) con COMMIT = *CHG
//            PGMA esegue un update, quindi chiama il PGMB
//            PGMB esegue un update di un altro record,
//                 NON esegue commit esplicito e ritorna al chiamante
//            PGMA esegue commit

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  actgrp(*caller);

exec sql
  set option COMMIT = *CHG;

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 100
    where EMPNO = '000020';

*inlr = *on;
return;
