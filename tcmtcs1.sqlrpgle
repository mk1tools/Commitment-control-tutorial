**free

// TEST CONTROLLO SINCRONIA VS CURSORI SQL
// (c) MarkOneTools - www.markonetools.it - 2026

// Esempio 1: viene aperto un cursore
//            Nel ciclo di lettura del cursore vengono eseguite operazione di I/O
//            che vengono consolidate o ripristinate
//            Se commit e rollback NON specificano la keyword hold
//            il cursore viene immediatamente chiuso e quindi la prossima lettura (fetch)
//            del ciclo restituirà un sqlcode < 0

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes);

dcl-ds EMPLOYEE ext template end-ds;
dcl-ds oEmp qualified;
  EMPNO like(EMPNO);
  LASTNAME like(LASTNAME);
  SALARY like(SALARY);
  BONUS like(BONUS);
end-ds;
dcl-c PERC_BONUS 2;
dcl-s i uns(5) inz(*zeros);

exec sql
  set option COMMIT = *CHG;

exec sql
  declare cEmp cursor for
    select EMPNO, LASTNAME, SALARY, BONUS
      from EMPLOYEE
      order by LASTNAME
      for update of BONUS;

exec sql
  open cEmp;

if sqlcode < *zeros;
  // gestione errore
endif;

dow *on;
  exec sql
    fetch next
    from cEmp
    into :oEmp;

  if sqlcode < *zeros;
    // gestione errore
    snd-msg 'Errore fetch sqlcode: ' + %char(sqlcode) +
             ' a ripetizione del ciclo numero ' + %char(i);
    leave;
  endif;
  if sqlcode = 100;
    leave;
  endif;
  // elaborazione
  oEmp.BONUS = oEmp.SALARY * PERC_BONUS / 100;
  exec sql
    update EMPLOYEE
      set BONUS = :oEmp.BONUS
      where current of cEmp;
  snd-msg 'Eseguito update di ' + oEmp.EMPNO;
  // ogni 3 aggiornamenti consolido
  i += 1;
  if %rem(i:3) = *zeros;
    exec sql
      commit;
    snd-msg 'Eseguito commit';
  endif;
enddo;

exec sql
  close cEmp;

*inlr = *on;
return;
