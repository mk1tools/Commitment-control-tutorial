**free

// TEST ESECUZIONE ROLLBACK ALL'INTERNO DI UN CICLO DI LETTURA DI UN CURSORE
// Esempio 1: cursore di sola lettura o aggiornamento
//            lettura primo record
//            aggiornamento di un altra tabella
//            rollback
//            proseguimento lettura cursore
//
// NOTA: se il cursore è di sola lettura un rollback eseguito durante il ciclo
//        non modifica il posizionamento del cursore
//       se invece il cursore è di aggiornamento un rollback eseguito durante il ciclo
//        riposiziona il cursore al record sul quale si trovava a inizio del ciclo di commit
//        quindi dopo il rollback non è possibile eseguire un update/delete where current of...
//        e la successiva fetch riparte da capo

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
  if sqlcode = 100 or i >= 3;
    snd-msg 'Fine ciclo lettura EMPLOYEE';
    leave;
  endif;
  Domanda = 'Elaborazione impiegato: ' + o1.EMPNO + ' ' + o1.LASTNAME;
  dsply Domanda;

  i += 1;
  // elaborazione progetti
  exec sql
    update EMPPROJACT
      set EMPTIME = EMPTIME + 0.5
      where EMPNO = :o1.EMPNO;

  Domanda = 'Confermi modifica EMPPROJACT? (S/N)';
  dsply Domanda ' ' Risposta;
  if %upper(Risposta) = 'S';
    exec sql
      commit hold;
    Domanda = 'Commit hold sqlcode: ' + %char(sqlcode);
    dsply Domanda;
  else;
    exec sql
      rollback hold;
    Domanda = 'Rollback hold sqlcode: ' + %char(sqlcode);
    dsply Domanda;
  endif;

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
    Domanda = 'Confermi modifica impiegato ' + o1.EMPNO  + '? (S/N)';
    dsply Domanda ' ' Risposta;

    if %upper(Risposta) = 'S';
      exec sql
        commit hold;
      Domanda = 'Commit hold sqlcode: ' + %char(sqlcode);
      dsply Domanda;
    else;
      exec sql
        rollback hold;
      Domanda = 'Rollback hold sqlcode: ' + %char(sqlcode);
      dsply Domanda;
    endif;
  endif;
enddo;

exec sql
  close c1;

*inlr = *on;
return;
