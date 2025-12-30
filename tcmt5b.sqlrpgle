**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
// Esempio 5: PGMA viene eseguito in *DFTACTGRP e PGMB in ACTGRP(*NEW) con COMMIT = *CHG
//            PGMA esegue un update, quindi chiama il PGMB con estensore errore CALLP(E)
//            PGMB esegue un update di un altro record e prima di eseguire commit
//                 si interrompe per un'eccezione non prevista,
//                 quindi ritorna a PGMA che prosegue all'istruzione successiva
//            PGMA esegue commit

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  actgrp(*new);

dcl-s Domanda char(51);
dcl-s Risposta char(1);
dcl-s a int(3) inz(10);
dcl-s b int(3) inz(*zeros);
dcl-s c packed(5:2);

exec sql
  set option COMMIT = *CHG;

exec sql
  update EMPLOYEE
    set MIDINIT = 'Y'
    where EMPNO = '000020';

// !!! eccezione imprevista divisione per zero
c = a/b;

Domanda = 'Confermi modifica EMPLOYEE pgmB? (S/N)';
dsply Domanda ' ' Risposta;

if %upper(Risposta) = 'S';
  exec sql
    commit;
  snd-msg 'pgm B Commit sqlcode: ' + %char(sqlcode);
else;
  exec sql
    rollback;
  snd-msg 'pgm B rollback sqlcode: ' + %char(sqlcode);
endif;

*inlr = *on;
return;
