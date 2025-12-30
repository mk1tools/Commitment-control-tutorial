**free

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes);

dcl-s Domanda char(51);
dcl-s Risposta char(1);

dcl-ds o1 extname('EMPLOYEE') alias qualified inz end-ds;

exec sql
  set option COMMIT = *CS;
  //set option COMMIT = *CS, CONACC = *CURCMT;
  //set option COMMIT = *CHG;
  //set option COMMIT = *RS, CONACC = *CURCMT;

exec sql
  declare c1 cursor for
    select EMPNO
      from EMPLOYEE
      where EMPNO >= '200000'
      order by EMPNO
      for update;

exec sql
  open c1;

dow *on;
  exec sql
    fetch next
    from c1
    into :o1.EMPNO;

  if sqlcode = 100;
    leave;
  endif;

  Domanda = 'Confermi la cancellazione di ' + o1.EMPNO + '? (S/N)';
  dsply Domanda ' ' Risposta;

  if %upper(Risposta) = 'S';
    exec sql
      delete EMPLOYEE
        where current of c1;
    exec sql
      commit;
  endif;

enddo;

exec sql
  close c1;

*inlr = *on;
return;
