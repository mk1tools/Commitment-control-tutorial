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
  extbinint(*yes);

dcl-s Domanda  char(51);
dcl-s Risposta char(1);
dcl-ds EMPLOYEE ext template end-ds;
dcl-s Bonus_1_From like(BONUS);
dcl-s Bonus_1_To   like(BONUS);
dcl-s Bonus_2_From like(BONUS);
dcl-s Bonus_2_To   like(BONUS);

dcl-pr pgmB extpgm('TCMT5B');
end-pr;

exec sql
  set option COMMIT = *CHG;

// situazione di partenza
exec sql
  select BONUS
    into :Bonus_1_From
    from EMPLOYEE
    where EMPNO = '000010';
exec sql
  select BONUS
    into :Bonus_2_From
    from EMPLOYEE
    where EMPNO = '000020';

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 100
    where EMPNO = '000010';

//==>
  callp(e) pgmB();
//==>

Domanda = 'Confermi modifica EMPLOYEE pgmA? (S/N)';
dsply Domanda ' ' Risposta;

// commit e rollback a questo punto sono ininfluenti perché
//  quelle esegue dal pgmB hanno già chiuso la transazione
if %upper(Risposta) = 'S';
  exec sql
    commit;
  snd-msg 'pgm A Commit sqlcode: ' + %char(sqlcode);

else;
  exec sql
    rollback;
  snd-msg 'pgm A Rollback sqlcode: ' + %char(sqlcode);
endif;

// situazione di arrivo
exec sql
  select BONUS
    into :Bonus_1_To
    from EMPLOYEE
    where EMPNO = '000010';
exec sql
  select BONUS
    into :Bonus_2_To
    from EMPLOYEE
    where EMPNO = '000020';

// riepilogo
snd-msg 'A => EMPNO 000010 bonus ' + %char(Bonus_1_From) +
          ' ==> ' + %char(Bonus_1_To);
snd-msg 'B => EMPNO 000020 bonus ' + %char(Bonus_2_From) +
          ' ==> ' + %char(Bonus_2_To);

*inlr = *on;
return;
