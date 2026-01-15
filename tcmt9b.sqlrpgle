**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// (c) MarkOneTools - www.markonetools.it - 2026

// Esempio 9: PGMA e PGMB vengono eseguiti in due ACTGRP(*NEW) con COMMIT = *CHG
//            PGMA esegue un update, quindi chiama il PGMB
//            PGMB esegue un update di un altro record, esegue commit e ritorna al chiamante
//            PGMA esegue commit

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  actgrp(*new);

dcl-s Domanda  char(51);
dcl-s Risposta char(1);

exec sql
  set option COMMIT = *CHG;

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 100
    where EMPNO = '000020';

Domanda = 'Confermi modifica EMPLOYEE pgmB? (S/N)';
dsply Domanda ' ' Risposta;

if %upper(Risposta) = 'S';
  exec sql
    commit;     // consolida anche le modifiche in sospeso del pgmA
  snd-msg 'pgm B Commit sqlcode: ' + %char(sqlcode);
else;
  exec sql
    rollback;   // ripristina anche le modifiche in sospeso del pgmA
  snd-msg 'pgm B rollback sqlcode: ' + %char(sqlcode);
endif;

*inlr = *on;
return;
