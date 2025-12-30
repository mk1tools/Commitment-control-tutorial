**free

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes);

dcl-s Domanda char(51);
dcl-s Risposta char(1);
dcl-s wLastName char(20);

exec sql
  -- con controllo sincronia *CS e concurrent access resolution *CURCMT
  --  viene letto il record originale senza la modifica in sospeso
  --  in una unità di work di un altro job non ancora committata
  -- quando nell'altro job l'unità di work viene committata
  --  rileggendo il record vedo i dati aggiornati
  set option COMMIT = *CS;
  //set option COMMIT = *CS, CONACC = *CURCMT;
  //set option COMMIT = *CHG;
  // con *RR o *RS se c'è in sospeso un commit su un altro job non si riesce
  //  a leggere record perché anche questa read tenta di allocarlo
  //set option COMMIT = *RR, CONACC = *CURCMT;
  //set option COMMIT = *RS, CONACC = *CURCMT;

exec sql
  declare c1 cursor for
    select LASTNAME
      from EMPLOYEE
      where EMPNO >= '200000'
      order by EMPNO;

exec sql open c1;

dou %upper(Risposta) <> 'S';
  exec sql
    fetch next from c1
      into :wLastName;
  if sqlcode = 100;
    leave;
  endif;

  Domanda = 'LASTNAME di 200010 è ' + %trim(wLastName) + '. Proseguo? (S/N)';
  dsply Domanda ' ' Risposta;
enddo;

exec sql close c1;

// ATTENZIONE con *RR o *RS il record viene allocato anche per le operazioni
//  di lettura, quindi bisogna ricordarsi di chiudere il controllo di sincronia
//  o con commit o con rollback
//exec sql
//  rollback;

*inlr = *on;
return;
