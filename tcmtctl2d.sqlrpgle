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
dcl-s wBonus packed(9:2);

exec sql
  //set option COMMIT = *CHG;                   // A
  // con controllo sincronia *CS non è possibile
  //  leggere il record allocato dalla transazione che lo
  //  sta modificando
  //set option COMMIT = *CS;                    // B
  // con controllo sincronia *CS e concurrent access resolution *CURCMT
  //  viene letto il record originale senza la modifica in sospeso
  //  in una transazione di un altro job non ancora consolidata
  // quando nell'altro job la transazione viene consolidata
  //  rileggendo il record vedo i dati aggiornati
  //set option COMMIT = *CS, CONACC = *CURCMT;  // C
  set option COMMIT = *ALL;                     // D
  // con *RR o *ALL se c'è in sospeso un commit su un altro job non si riesce
  //  a leggere record perché anche questa read tenta di allocarlo
  //set option COMMIT = *ALL, CONACC = *CURCMT; // E
  //set option COMMIT = *RR, CONACC = *CURCMT;  // F

dou %upper(Risposta) <> 'S';
  exec sql
    select BONUS
      into :wBonus
      from EMPLOYEE
      where EMPNO = '000010';

  if sqlcode < *zeros;
    Domanda = 'errore lettura sqlcode: ' +
              %char(sqlcode) + '. Rileggo? (S/N)';
  else;
    Domanda = 'BONUS di EMPNO 000010 è ' +
              %char(wBonus) + '. Rileggo? (S/N)';
  endif;
  dsply Domanda ' ' Risposta;
enddo;

// ATTENZIONE con *RR o *RS il record viene allocato anche per le operazioni
//  di lettura, quindi bisogna ricordarsi di chiudere il controllo di sincronia
//  o con commit o con rollback
//exec sql
//  rollback;

*inlr = *on;
return;
