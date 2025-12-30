**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// Esempio 6: PGMA viene eseguito in *DFTACTGRP e PGMB in ACTGRP(*NEW) con COMMIT = *CHG
//            PGMA esegue un update, quindi chiama il PGMB
//            PGMB esegue un update di un altro record,
//                 NON esegue commit esplicito e ritorna al chiamante
//            PGMA si chiude normalmente senza eseguire commit
//                 e poi viene chiuso normalmente il job

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  actgrp(*new);

exec sql
  set option COMMIT = *CHG;

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 100
    where EMPNO = '000020';

*inlr = *on;
return;
