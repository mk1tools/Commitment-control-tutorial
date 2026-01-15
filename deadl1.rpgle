**free

// ESEMPIO DEADLOCK JOB 1
// (c) MarkOneTools - www.markonetools.it - 2026

// chiamo il pgm DEADL1 nel job 1
//  e contemporaneamente chiamo il pgm DEADL2 nel job 2

ctl-opt copyright('MarkOneTools')
  decedit('0,')
  indent(' ')
  option(*nodebugio: *srcstmt: *showcpy: *nounref)
  expropts(*resdecpos)
  extbinint(*yes)
  dftactgrp(*no) actgrp(*new);

// db esempio
dcl-f employee keyed usage(*update) rename(employee:emprec) usropn
      commit;
dcl-ds kEmp likerec(emprec:*key);

// messaggi per joblog
dcl-s Domanda char(51);
dcl-s Risposta char(1);

// API QCMDEXC
dcl-s cmdLen packed(15:5) inz(80);
dcl-s cmd char(80);
dcl-pr Pgm_QCMDEXC extpgm('QCMDEXC');
 cmd char(80);
 cmdLen packed(15:5);
end-pr;

// avvia controllo sincronia a livello job
cmd = 'STRCMTCTL LCKLVL(*CS) CMTSCOPE(*JOB)';     // <==
Pgm_QCMDEXC(cmd : cmdLen);
Domanda = 'Avviato contr.sincr. *JOB. Invio per proseguire';
clear Risposta;
dsply Domanda ' ' Risposta;

open employee;

// allocazione rek 000200
kEmp.EMPNO = '000200';
chain %kds(kEmp) employee;
if %found();
  bonus += 10;
  Domanda = 'Alloco il rek 000200. Avviare DEADL2 in job 2.';
  clear Risposta;
  dsply Domanda ' ' Risposta;
endif;

// eseguo nel job 2 la call a DEADL2 fino a quando alloca il rek 000210

// tento di allocare il rek 000210
kEmp.EMPNO = '000210';
chain %kds(kEmp) employee;
if %error();
  Domanda = 'Errore lettura 000210. Status: ' + %char(%status(employee));
  clear Risposta;
  dsply Domanda ' ' Risposta;
endif;
if %found();
  bonus += 10;
  Domanda = 'Alloco il rek 000210. In DEADL2 proseguo ad allocare 000200.';
  clear Risposta;
  dsply Domanda ' ' Risposta;
  update emprec;
  commit;
endif;

*inlr = *on;
return;
