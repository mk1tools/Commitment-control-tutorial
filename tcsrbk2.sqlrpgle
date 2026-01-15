**free

// TEST ESECUZIONE ROLLBACK ALL'INTERNO DI UN CICLO DI LETTURA DI UN CURSORE
// (c) MarkOneTools - www.markonetools.it - 2026

// Esempio 1: cursore di aggiornamento
//            lettura primo record
//            aggiornamento di un altra tabella
//            aggiornamento record letto da cursore
//            rollback
//            proseguimento lettura cursore
//
// NOTA: se il cursore è di sola lettura anche un rollback eseguito durante il ciclo
//        non modifica il posizionamento del cursore
//       se invece il cursore è di aggiornamento un rollback eseguito durante il ciclo
//        riposiziona il cursore al record sul quale si trovava a inizio del ciclo di commit
//        quindi dopo il rollback non è possibile eseguire un update/delete where current of...
//        e la successiva fetch riparte dal record letto all'inizio del ciclo di commit
//
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

exec sql
  set option COMMIT = *CHG;

exec sql
  declare c1 cursor for
    select EMPNO, LASTNAME, BONUS
      from EMPLOYEE
      order by EMPNO
      --for read only
      for update
  ;

exec sql
  open c1;

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
  if sqlcode = 100;
    snd-msg 'Fine ciclo EMPLOYEE sqlcode: ' + %char(sqlcode);
    leave;
  endif;
  snd-msg 'Elaborazione impiegato: ' + o1.EMPNO + ' ' + o1.LASTNAME;
  // sezionamento ciclo di commit al punto in cui ho letto il record da EMPLOYEE
  exec sql
    savepoint A on rollback retain cursors on rollback retain locks;

  // elaborazione progetti
  exec sql
    update EMPPROJACT
      set EMPTIME = EMPTIME + 0.5
      where EMPNO = :o1.EMPNO;

  // aggiornamento EMPLOYEE letto da cursore
  if UpdEmp;
    exec sql
      update EMPLOYEE
        set BONUS = BONUS + 100
        where current of c1;
  endif;

  Domanda = 'Confermi modifica EMPLOYEE+PROJACT? (S/N)';
  dsply Domanda ' ' Risposta;

  if %upper(Risposta) = 'S';
    exec sql
      commit hold;
    snd-msg 'Commit sqlcode: ' + %char(sqlcode);
  else;
    // rollback fino all'ultimo punto di salvataggio in modo
    //  che la prossima fetch prosegua dal record successivo
    //  all'ultimo letto
    exec sql
      rollback to savepoint;
    snd-msg 'Rollback sqlcode: ' + %char(sqlcode);
  endif;
enddo;

exec sql
  close c1;

*inlr = *on;
return;
