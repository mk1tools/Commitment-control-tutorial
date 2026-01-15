**free

// ESEMPIO CONCORRENZA DI ACCESSO
// (c) MarkOneTools - www.markonetools.it - 2026

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes);

dcl-s Domanda char(51);
dcl-s Risposta char(1);

exec sql
  //set option COMMIT = *CS;
  set option COMMIT = *CS, CONACC = *CURCMT;
  //set option COMMIT = *CHG;
  //set option COMMIT = *RS, CONACC = *CURCMT;

exec sql
  update EMPLOYEE
    set MIDINIT = 'X'
    where EMPNO = '000010';

  Domanda = 'Confermi la modifica di EMPLOYEE? (S/N)';
  dsply Domanda ' ' Risposta;

  if %upper(Risposta) = 'S';
    exec sql
      commit;
  else;
    exec sql
      rollback;
  endif;

*inlr = *on;
return;
