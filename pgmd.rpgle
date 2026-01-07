**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMD è chiamato a PGMC. Anche PGMD è in esecuzione nel dftactgrp
//      ed eredita la definizione di controllo sincronia avviata
//      da PGMC

// PGMC     dftactgrp, avvia controllo sincronia *job
// |-PGMD   dftactgrp                                      <==
//   |-PGMA actgrp *new
// |-PGMB   actgrp *new, avvia controllo sincronia *actgrp

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  dftactgrp(*yes);                 // <==

// db esempio
dcl-f employee keyed usage(*update) rename(employee:emprec)
      commit;                      // <==
dcl-ds kEmp likerec(emprec:*key);

// prototipi per chiamate
dcl-pr PGMA extpgm;
end-pr;

// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

clear Risposta;
Domanda = 'Avvio programma PGMD. Invio per proseguire.';
dsply Domanda ' ' Risposta;

kEmp.EMPNO = '000210';
chain %kds(kEmp) employee;
if %found();
  bonus += 10;
  update emprec;
  Domanda = 'Eseguito update 000210. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

// chiama PGMA che andrà in esecuzione in un nuovo activation group
//  senza avviare una definizione di controllo sincronia specifica e
//  quindi eredita la definizione avviata da PGMC in ambito *JOB
callp PGMA();

*inlr = *on;
return;
