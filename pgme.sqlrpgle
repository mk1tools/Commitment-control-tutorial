**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGME avvia implicitamente una definizione di controllo sincronia a livello *dftactgrp
// |    ed è in esecuzione nel default activation group
// |-PGMF actgrp *new, avvia implicitamente controllo sincronia *actgrp

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  dftactgrp(*yes);                 // <==

// prototipi per chiamate
dcl-pr PGMF extpgm;
end-pr;

// API QCMDEXC
dcl-s cmdLen packed(15:5) inz(80);
dcl-s cmd char(80);
dcl-pr Pgm_QCMDEXC extpgm('QCMDEXC');
 cmd char(80);
 cmdLen packed(15:5);
end-pr;
// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

// direttiva per il compilatore. N.B. non è un'istruzione eseguibile
exec sql
  set option COMMIT = *CHG;

clear Risposta;
Domanda = 'Avvio programma PGME. Invio per proseguire.';
dsply Domanda ' ' Risposta;

exec sql
  update EMPLOYEE
    set bonus = bonus + 10
    where EMPNO = '000200';
if sqlcode >= *zeros;
  Domanda = 'Eseguito update 000200. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

// chiama PGMF che andrà in esecuzione in un nuovo activation group
//  PGMF avvia implicitamente una nuova definizione di controllo sincronia in ambito *ACTGRP
//  perchè è un programma embedded SQL
callp PGMF();

// arresta controllo sincronia a livello job
Domanda = 'PGME arresterà il contr.sincr. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;
cmd = 'ENDCMTCTL';     // <==
callp(e) Pgm_QCMDEXC(cmd : cmdLen);
if %error();
  Domanda = 'Arresto controllo di sincronia con errori';
  clear Risposta;
  dsply Domanda ' ' Risposta;
endif;

*inlr = *on;
return;
