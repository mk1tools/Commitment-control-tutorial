**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMA è chiamato a PGMD. PGMA apre un nuovo activation group
//      gestito dal sistema operativo ed eredita la definizione
//      di controllo sincronia avviata da PGMC
//      perché nell'activation group non esegue un avvio di un'altra
//      definizione di controllo sincronia con ambito *ACTGRP

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
  dftactgrp(*no) actgrp(*new);                 // <==

// db esempio
dcl-f employee keyed usage(*update) rename(employee:emprec)
      commit;                      // <==
dcl-ds kEmp likerec(emprec:*key);

// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

clear Risposta;
Domanda = 'Avvio programma PGMA. Invio per proseguire.';
dsply Domanda ' ' Risposta;

kEmp.EMPNO = '000220';
chain %kds(kEmp) employee;
if %found();
  bonus += 10;
  update emprec;
  Domanda = 'Eseguito update 000220. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

*inlr = *on;
return;
