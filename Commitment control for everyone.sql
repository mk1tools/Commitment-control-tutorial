/* COMMITMENT CONTROL FOR EVERYONE */
/* (c) 2026 MarkOneTools - www.markonetools.it */

call qcmdexc('CHGCURLIB MK1SAMPLE');

-- visualizzazioni transazioni database (ACS)
call QSYS/QTNOUTCD('QADBTXLST QTEMP     ', '', 'CFMT0500', '0', 0);

select QTNUOWID "ID unità di lavoro",
       case QTNUOWSTT
         when 'RST' then 'Ripristina'
         when 'PIP' then 'Preparazione in corso'
         when 'PRP' then 'Preparato'
         when 'LAP' then 'Ultimo agent in sospeso'
         when 'CIP' then 'Commit in corso'
         when 'CMT' then 'Sottoposto a commit'
         when 'VRO' then 'Indica come sola lettura'
         when 'RBR' then 'Rollback necessario'
         when 'RIP' then 'Rollback in corso'
         when 'HUR' then 'Completato in modalità euristica'
         else 'Sconosciuto'
       end "Stato unità di lavoro",
       QTNJOBNAME "Nome lavoro",
       QTNJOBUSR "Utente lavoro",
       QTNJOBNUM "Numero lavoro",
       case QTNRIP
         when 'Y' then 'Sì'
         when 'N' then 'No'
         else cast(QTNRIP as varchar(1))
       end "Risincronizzazione in corso",
       QTNCMTDFN "Definizione di commit",
       QTNEFUSR "Utente",
       case QTNCHGPND
         when 'Y' then 'Sì'
         when 'N' then 'No'
         else cast(QTNCHGPND as varchar(1))
       end "Modifiche in sospeso locali",
       QTNLCKSID "ID spazio blocco",
       QTNLCKSH "Gestore spazio blocco",
       QTNDLCKL "Livello lock"
  from QTEMP/QADBTXLST
  where QTNLCKSID like 'UDB_%'
    and QTNASPGRP = '*SYSBAS'
    and QTNEFUSR = current user   -- utente corrente
  order by 1 asc;

select *
  from QTEMP/QADBTXLST
  where QTNLCKSID like 'UDB_%'
    and QTNASPGRP = '*SYSBAS'
    and QTNEFUSR = current user;   -- utente corrente  
    
-- file registrati su giornale (old way)
call qcmdexc('DSPFD FILE(*CURLIB/*ALL) TYPE(*MBR) OUTPUT(*OUTFILE) FILEATR(*PF) OUTFILE(*CURLIB/PF_01)');
select MBFILE as "File", MBTXT as "Descrizione", MBJRNL "Reg.attiva", MBJRNM as "Giornale", MBJRLB as "Lib.giornale",  
    MBJRIM as "Tipo immagine", MBJRSD as "Data avvio reg.", MBJRST as "Ora avvio reg."
  from PF_01
  where MBJRNM <> ' '
  order by MBFILE;

-- file registrati su giornale (new way)
select OBJNAME "File", OBJTEXT "Descrizione", JOURNALED "Reg.attiva", JOURNAL_NAME as "Giornale", JOURNAL_LIBRARY as "Lib.giornale", 
       JOURNAL_IMAGES as "Tipo immagine", timestamp(JOURNAL_START_TIMESTAMP, 0) as "Data/ora avvio reg."
  from table(OBJECT_STATISTICS(:Libreria, 'FILE')) as T
  where JOURNALED = 'YES'
  order by OBJNAME;

-- info giornale
select JOURNAL_NAME "Giornale", JOURNAL_TEXT "Descrizione", ASP_NUMBER ASP, JOURNAL_STATE "Stato", 
    ATTACHED_JOURNAL_RECEIVER_LIBRARY concat '/' concat ATTACHED_JOURNAL_RECEIVER_NAME "Ricevitore", 
    NUMBER_JOURNAL_RECEIVERS "Num.ric.", TOTAL_SIZE_JOURNAL_RECEIVERS/1024  "Dim.ric. (Mb)",
    DELETE_RECEIVER_OPTION "Canc.ric.", MANAGE_RECEIVER_OPTION "Ges.ric.", 
    JOURNALED_OBJECTS "Ogg.registrati", JOURNALED_FILES "Files registrati", JOURNALED_DATA_AREAS "Aree dati registrate", 
    JOURNALED_DATA_QUEUES "Code dati registrate", JOURNALED_IFS_OBJECTS "Stream files registrati", 
    JOURNALED_ACCESS_PATHS "Vie d'accesso registrate", JOURNALED_COMMITMENT_DEFINITIONS "Definizioni controllo sincronia registrate", JOURNALED_LIBRARIES "Librerie registrate"
  from JOURNAL_INFO
  where JOURNAL_LIBRARY = :Libreria;

-- info ricevitori di giornale
select JOURNAL_RECEIVER_LIBRARY "Libreria", JOURNAL_RECEIVER_NAME "Ricev.", JOURNAL_NAME "Giornale",
       THRESHOLD "Soglia", SIZE/1024 "Dim. (Mb)", STATUS "Stato",
       FIRST_SEQUENCE_NUMBER "Seq.iniz.", LAST_SEQUENCE_NUMBER "Seq.fin.",
       timestamp(ATTACH_TIMESTAMP, 0) "Data/ora coll.", timestamp(DETACH_TIMESTAMP, 0) "Data/ora scoll.",
       timestamp(SAVE_TIMESTAMP, 0) "Data/ora salv.",
       PREVIOUS_JOURNAL_RECEIVER "Ric.prec.", NEXT_JOURNAL_RECEIVER "Ric.succ.",
       PENDING_TRANSACTIONS "Transaz.pendenti"
  from JOURNAL_RECEIVER_INFO
  where JOURNAL_LIBRARY = :Libreria
  order by JOURNAL_LIBRARY, JOURNAL_NAME, ATTACH_TIMESTAMP;

-- dimensione occupata dai ricevitori associati ai giornali
select JRN_LIB "Libreria", JOURNAL "Giornale", count(*) "Num.ricev.", sum(SIZE)/1024 "Dim.ricev. (Mb)",
       timestamp(min(DETACH_TIMESTAMP), 0) "Data/ora scoll. più vecchio", 
       timestamp(max(DETACH_TIMESTAMP), 0) "Data/ora scoll. più recente"
  from JOURNAL_RECEIVER_INFO
  where JRN_LIB = :Libreria
  group by JRN_LIB, JOURNAL 
  order by "Dim.ricev. (Mb)" desc;

-- lista ricevitori più vecchi di 30 gg eliminabili
call SYSTOOLS.DELETE_OLD_JOURNAL_RECEIVERS
 (DELETE_OLDER_THAN => current date - 30 days,  
  JOURNAL_RECEIVER_LIBRARY => :Libreria, 
  PREVIEW => 'YES');

-- file registrati su giornale
select JOURNAL_NAME "Giornale", OBJECT_TYPE "Tipo ogg.", FILE_TYPE "Attr.", 
       OBJECT_LIBRARY "Lib.ogg.", OBJECT_NAME "Oggetto", JOURNAL_IMAGES "Tipo immagine"
  from JOURNALED_OBJECTS
  where JOURNAL_LIBRARY = :Libreria
    and OBJECT_TYPE = '*FILE'
  order by JOURNAL_NAME, OBJECT_TYPE, OBJECT_LIBRARY, OBJECT_NAME;

-- tipo voci di giornale relative al controllo di sincronia
select JOURNAL_CODE "Codice", JOURNAL_CODE_DESCRIPTION "Descr.",
       JOURNAL_ENTRY_TYPE "Tipo voce", JOURNAL_ENTRY_TYPE_DESCRIPTION "Descr.tipo voce"
  from JOURNAL_CODE_INFO
  where JOURNAL_CODE in ('C', 'R')
    or (JOURNAL_CODE = 'D' and JOURNAL_ENTRY_TYPE = 'JF')
    or (JOURNAL_CODE = 'F' and JOURNAL_ENTRY_TYPE in('C1', 'EJ', 'JM'))
  order by 1, 3;

-- estrazioni voci di giornale (senza dettaglio del record) degli ultimi 7 gg
select ENTRY_TIMESTAMP "Data/Ora", SEQUENCE_NUMBER "Seq.", JOURNAL_CODE concat ' ' concat JOURNAL_ENTRY_TYPE "Tipo voce", 
       JOB_NUMBER concat '/' concat trim(JOB_USER) concat '/' concat trim(JOB_NAME) "Lavoro", CURRENT_USER "Utente corr.", PROGRAM_NAME "Programma",
       left(OBJECT, 10) "Ogg.", COUNT_OR_RRN "RRN", COMMIT_CYCLE "ID ciclo commit", 
       INDICATOR_FLAG "Contrassegno", 
       case when JOURNAL_ENTRY_TYPE in ('CM', 'RB') then 
          case INDICATOR_FLAG when '0' then 'esplicito'
                              when '2' then 'implicito'
                              else INDICATOR_FLAG
          end 
       end as "Tipo chiusura" 
  from table(DISPLAY_JOURNAL(
                JOURNAL_LIBRARY => :Libreria 
              , JOURNAL_NAME => :Giornale
              , STARTING_TIMESTAMP => timestamp(current date - :Num_gg days, '00:00:00')
              --, STARTING_RECEIVER_NAME => '*CURCHAIN' -- scorre tutta la catena dei ricevitori, altrimenti solo il corrente
              , JOURNAL_CODES => 'C,R'
              --, JOURNAL_ENTRY_TYPES => 'SC'           -- solo apertura transazioni
              --, JOURNAL_ENTRY_TYPES => 'SC,CM,RB'       -- solo apertura, chiusura transazioni
              --, COMMIT_CYCLE => :ID_Commit                    -- solo uno specifico ciclo di commit
            )) as J
  order by SEQUENCE_NUMBER;

-- estrazioni voci di giornale (con dettaglio del record) degli ultimi 7 gg
select ENTRY_TIMESTAMP "Data/Ora", SEQUENCE_NUMBER "Seq.", JOURNAL_CODE concat ' ' concat JOURNAL_ENTRY_TYPE "Tipo voce", 
       JOB_NUMBER concat '/' concat trim(JOB_USER) concat '/' concat trim(JOB_NAME) "Lavoro", CURRENT_USER "Utente corr.", PROGRAM_NAME "Programma",
       left(OBJECT, 10) "Ogg.", COUNT_OR_RRN "RRN", COMMIT_CYCLE "ID ciclo commit", 
       INDICATOR_FLAG "Contrassegno", 
       case when JOURNAL_ENTRY_TYPE in ('CM', 'RB') then 
          case INDICATOR_FLAG when '0' then 'esplicito'
                              when '2' then 'implicito'
                              else INDICATOR_FLAG
          end 
       end as "Tipo chiusura",
       interpret(substr(ENTRY_DATA, 1, 6) as char(6)) as "Codice",
       interpret(substr(ENTRY_DATA, 22, 15) as varchar(15)) as "Last name",
       interpret(substr(ENTRY_DATA, 95, 5) as dec(9, 2)) as "Bonus",
       interpret(substr(ENTRY_DATA, 56, 5) as dec(8)) as "Hire date"
  from table(DISPLAY_JOURNAL(
                JOURNAL_LIBRARY => :Libreria 
              , JOURNAL_NAME => :Giornale
              , STARTING_TIMESTAMP => timestamp(current date - :Num_gg days, '00:00:00')
              --, STARTING_RECEIVER_NAME => '*CURCHAIN' -- scorre tutta la catena dei ricevitori, altrimenti solo il corrente
              , JOURNAL_CODES => 'R'
              --, COMMIT_CYCLE => :ID_Commit                    -- solo uno specifico ciclo di commit
            )) as J
  order by SEQUENCE_NUMBER;

-- estrazioni voci di giornale (con dettaglio del record) degli ultimi 7 gg ==> metodo De Pedrini
select *
  from MK1SAMPLE.EMPLOYEE_JRN;