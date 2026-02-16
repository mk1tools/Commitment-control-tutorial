**free

// TEST ESECUZIONE ROLLBACK ALL'INTERNO DI UN CICLO DI LETTURA DI UN CURSORE
// Esempio 1: cursore di aggiornamento
//            lettura e aggiornamento di alcuni record
//            rollback
//            proseguimento lettura cursore
//
// NOTA: se il cursore è di aggiornamento un rollback eseguito durante il ciclo
//        riposiziona il cursore al record sul quale si trovava a inizio del ciclo di commit
//        quindi dopo il rollback non è possibile eseguire un update/delete where current of...
//        e la successiva fetch riparte dal record letto all'inizio del ciclo di commit

//        impostando un savepoint (disponibile da V5R2) è possibile sezionare il ciclo di commit

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

dcl-ds o1 qualified;
  EMPNO like(EMPNO);
  LASTNAME like(LASTNAME);
  BONUS like(BONUS);
end-ds;
dcl-s UpdEmp ind inz(*on);
dcl-s i uns(3) inz(*zeros);

exec sql
  set option COMMIT = *CHG;

// ! cursore aperto in aggiornamento
exec sql
  declare c1 cursor for
    select EMPNO, LASTNAME, BONUS
      from EMPLOYEE
      order by EMPNO
      for update;

exec sql
  open c1;
Domanda = 'Apro cursore EMPLOYEE in aggiornamento.';
dsply Domanda;

if sqlcode < *zeros;
  snd-msg 'Errore open sqlcode: ' + %char(sqlcode);
endif;

dow *on;
  exec sql
    fetch next
    from c1
    into :o1;

  if sqlcode < *zeros;
    snd-msg 'Errore fetch sqlcode: ' + %char(sqlcode);
  endif;
  if sqlcode = 100 or i >= 6;
    snd-msg 'Fine ciclo lettura EMPLOYEE';
    leave;
  endif;
  Domanda = 'Elaborazione impiegato: ' + o1.EMPNO + ' ' + o1.LASTNAME;
  dsply Domanda;

  // sezionamento ciclo di commit al punto in cui ho letto il record da EMPLOYEE
  exec sql
    savepoint A on rollback retain cursors on rollback retain locks;
  Domanda = 'Savepoint a EMPNO ' + o1.EMPNO;
  dsply Domanda;

  i += 1;

  // aggiornamento EMPLOYEE
  if UpdEmp;
    exec sql
      update EMPLOYEE
        set BONUS = BONUS + 100
        where current of c1;
    if sqlcode < *zeros;
      Domanda = 'Errore update impiegato ' + o1.EMPNO + ', sqlcode='  + %char(sqlcode);
      dsply Domanda;
    endif;
  endif;

  // ogni 3 impiegati consolido le modifiche
  if %rem(i:3) = *zeros;
    Domanda = 'Confermi modifica impiegato? (S/N)';
    dsply Domanda ' ' Risposta;

    if %upper(Risposta) = 'S';
      exec sql
        commit hold;
      Domanda = 'Commit hold sqlcode: ' + %char(sqlcode);
      dsply Domanda;
    else;
      exec sql
        rollback to savepoint;
      Domanda = 'Rollback to savepoint sqlcode: ' + %char(sqlcode);
      dsply Domanda;
    endif;
  endif;
enddo;

exec sql
  close c1;

*inlr = *on;
return;
