**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMG avvia commitment control a livello *job
//      ed è in esecuzione nel default activation group
// PGMG     dftactgrp, avvia controllo sincronia *job      <==
// |-PGMH   dftactgrp, avvia controllo sincronia *actgrp   <==

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
// prototipi per chiamate
dcl-pr PGMH extpgm;
end-pr;

// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

// avvia controllo sincronia a livello job
cmd = 'STRCMTCTL LCKLVL(*CHG) CMTSCOPE(*JOB)';     // <==
Pgm_QCMDEXC(cmd : cmdLen);
Domanda = 'Avviato contr.sincr. *JOB. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

open employee;

kEmp.EMPNO = '000200';
chain %kds(kEmp) employee;
if %found();
  bonus += 10;
  update emprec;
  Domanda = 'Eseguito update 000200. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

// chiama PGMH che andrà in esecuzione nel dftactgrp e apre
//  la definizione di controllo sincronia in ambito *ACTGRP
callp PGMH();

// arresta controllo sincronia a livello job
Domanda = 'PGMG arresterà il contr.sincr. Invio per proseguire';
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
