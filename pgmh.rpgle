**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMH tenta di avviare commitment control a livello *actgrp
//      ed è in esecuzione nel default activation group
// PGMG     dftactgrp, avvia controllo sincronia *job      <==
// |-PGMH   dftactgrp, tenta avvia controllo sincronia *actgrp   <==

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  dftactgrp(*yes);                 // <==

// db esempio
dcl-f employee keyed usage(*update) rename(employee:emprec) usropn
      commit;                      // <==
dcl-ds kEmp likerec(emprec:*key);

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

// tenta di avviare controllo sincronia a livello actgrp
//  ma fallisce perché è già attivo una definizione di controllo sincronia
//  a livello job ed il programma PGMH è in esecuzione sempre nel
//  gruppo attivazione di default
cmd = 'STRCMTCTL LCKLVL(*CHG) CMTSCOPE(*ACTGRP)';     // <==
Pgm_QCMDEXC(cmd : cmdLen);
Domanda = 'Avviato contr.sincr. *ACTGRP. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

open employee;

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

// arresta controllo sincronia a livello job
Domanda = 'PGMH arresterà il contr.sincr. Invio per proseguire';
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
