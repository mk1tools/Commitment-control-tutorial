**free

// ESEMPIO AMBITO CONTROLLO SINCRONIA
// (c) MarkOneTools - www.markonetools.it - 2026

// PGMB è chiamato a PGMC. PGMB apre un nuovo activation group
//      gestito dal sistema operativo.
//      Avvia una nuova definizione di controllo di sincronia
//      nell'ambito dell'activation group

// PGMC     dftactgrp, avvia controllo sincronia *job      <==
// |-PGMD   dftactgrp
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

// avvia controllo sincronia a livello job
cmd = 'STRCMTCTL LCKLVL(*CHG) CMTSCOPE(*ACTGRP)';     // <==
Pgm_QCMDEXC(cmd : cmdLen);
Domanda = 'Avviato contr.sincr. *ACTGRP. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

open employee;

kEmp.EMPNO = '000240';
chain %kds(kEmp) employee;
if %found();
  bonus += 10;
  update emprec;
  Domanda = 'Eseguito update 000240. Proseguire? (S/N)';
  dou %upper(Risposta) = 'S';
    clear Risposta;
    dsply Domanda ' ' Risposta;
  enddo;
endif;

// consolido le modifiche in sospeso nella definizione di
//  controllo sincronia nell'ambito di questo activation group
commit;
Domanda = 'PGMB ha eseguito commit. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

// arresta controllo sincronia a livello activation group
//  poiché il file EMPLOYEE è ancora aperto l'ENDCMTCTL terminerà in errore
Domanda = 'PGMB arresterà il contr.sincr. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;
cmd = 'ENDCMTCTL';     // <==
callp(e) Pgm_QCMDEXC(cmd : cmdLen);
if %error();
  Domanda = 'Arresto controllo di sincronia con errori';
  clear Risposta;
  dsply Domanda ' ' Risposta;
endif;

close EMPLOYEE;
Domanda = 'PGMB ha chiuso il file EMPLOYEE. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

// arresta controllo sincronia a livello activation group
Domanda = 'PGMB arresterà il contr.sincr. Invio per proseguire';
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
