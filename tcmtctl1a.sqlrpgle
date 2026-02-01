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
  set option COMMIT = *CHG;                    // A
  //set option COMMIT = *CS;                   // B
  //set option COMMIT = *CS, CONACC = *CURCMT; // C
  //set option COMMIT = *RS, CONACC = *CURCMT; // D
  //set option COMMIT = *RR, CONACC = *CURCMT; // E

exec sql
  update EMPLOYEE
    set BONUS = BONUS + 10
    where EMPNO = '000010';

  Domanda = 'Ho incrementato il bonus di 10€ per EMPNO 000010';
  dsply Domanda;
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
