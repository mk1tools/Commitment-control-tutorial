**free

// TEST CONTROLLO SINCRONIA SU PROGRAMMI DIVERSI NELLO STESSO STACK DI CHIAMATE
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
  actgrp(*new);

dcl-s Domanda  char(51);
dcl-s Risposta char(1);
dcl-ds EMPLOYEE ext template end-ds;
dcl-s Bonus_1_From like(BONUS);
dcl-s Bonus_1_To   like(BONUS);
dcl-s Bonus_2_From like(BONUS);
dcl-s Bonus_2_To   like(BONUS);

dcl-pr pgmB extpgm('TCMT7B');
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

Domanda = 'Confermi modifica EMPLOYEE pgmA? (Sì/No/Boh)';
dsply Domanda ' ' Risposta;

// commit e rollback agiscono eventualmente anche su modifiche in sospeso
//  eseguite da pgmB
select;
  when %upper(Risposta) = 'S';
    exec sql
      commit;
    snd-msg 'pgm A Commit sqlcode: ' + %char(sqlcode);
  when %upper(Risposta) = 'N';
    exec sql
      rollback;
    snd-msg 'pgm A Rollback sqlcode: ' + %char(sqlcode);
  when %upper(Risposta) = 'B';
    snd-msg 'pgm A non fa niente';
endsl;

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
