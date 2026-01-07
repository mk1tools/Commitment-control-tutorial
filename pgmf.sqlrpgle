**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMF è chiamato a PGME. PGMF apre un nuovo activation group
//      gestito dal sistema operativo
//      PGMF implicitamente apre una nuova definizione di controllo
//      di sincronia in quanto è un programma embedded SQL

// PGME avvia commitment control a livello *job
// |    ed è in esecuzione nel default activation group
// |-PGMF   actgrp *new, avvia implicitamente controllo sincronia *actgrp

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  dftactgrp(*no) actgrp(*new);                 // <==

// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

// direttiva per il compilatore. N.B. non è un'istruzione eseguibile
exec sql
  set option COMMIT = *CHG;

clear Risposta;
Domanda = 'Avvio programma PGMF. Invio per proseguire.';
dsply Domanda ' ' Risposta;

exec sql
  update EMPLOYEE
    set bonus = bonus + 10
    where EMPNO = '000210';
if sqlcode >= *zeros;
  Domanda = 'Eseguito update 000210. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

// alla chiusura del programma coincide la chiusura normale
//  dell'activation group aperto con PGMF dal sistema operativo
//  viene quindi eseguita un'operazione di commit implicita

*inlr = *on;
return;
