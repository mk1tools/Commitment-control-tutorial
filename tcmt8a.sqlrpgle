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
  extbinint(*yes)
  actgrp(*new);

dcl-s Domanda  char(51);
dcl-s Risposta char(1);
dcl-ds EMPLOYEE ext template end-ds;
dcl-s Bonus_2_From like(BONUS);
dcl-s Bonus_2_To   like(BONUS);

dcl-pr pgmB extpgm('TCMT8B');
end-pr;

exec sql
  set option COMMIT = *CHG;

// situazione di partenza
exec sql
  select BONUS
    into :Bonus_2_From
    from EMPLOYEE
    where EMPNO = '000020';

//==>
  callp(e) pgmB();
//==>

// aggiornamento dello stesso record aggiornato da pgmB ==> fallisce per rek allocato
exec sql
  update EMPLOYEE
    set BONUS = BONUS + 30
    where EMPNO = '000020';

Domanda = 'Confermi modifica EMPLOYEE pgmA? (S/N)';
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
endsl;

// situazione di arrivo
exec sql
  select BONUS
    into :Bonus_2_To
    from EMPLOYEE
    where EMPNO = '000020';

// riepilogo
snd-msg 'EMPNO 000020 bonus ' + %char(Bonus_2_From) +
          ' ==> ' + %char(Bonus_2_To);

*inlr = *on;
return;
