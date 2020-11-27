REM
REM --------------------------------------------------------------------
REM
REM indexreport.sql
REM
REM Used to get the object identifiers of all the indexable objects in the
REM Windchill system for mass index loading.  Right now that consists of ...
REM
REM classname                   tablename
REM -------------------------------------------------
REM wt.doc.WTDocument                 WTDocument
REM wt.part.WTPart                    WTPart
REM wt.change2.WTChangeRequest2       WTChangeRequest2
REM wt.change2.WTChangeOrder2         WTChangeOrder2
REM wt.change2.WTChangeActivity2      WTChangeActivity2
REM wt.change2.WTChangeIssue          WTChangeIssue
REM wt.change2.WTChangeInvestigation  WTChangeInvestigation
REM wt.change2.WTChangeProposal       WTChangeProposal
REM wt.change2.WTAnalysisActivity     WTAnalysisActivity
REM
REM
REM NOTE:  You must add to this file if you model new indexable
REM classes and intend on doing massive index loading.  Follow the examples below.
REM NOTE THAT THE COMMANDS ARE DIFFERENT BETWEEN ITERATED (i.e. Documents)
REM AND NON-ITERATED (i.e. Change Requests) OBJECTS.  MODEL THE SCRIPT COMMANDS FOR 
REM YOUR CLASSES ACCORDINGLY.
REM
REM Kim Chase
REM May 1998
REM
REM $Header:$
REM
REM --------------------------------------------------------------------
REM

set heading off

set echo off
set verify off
set feedback off

column classnamea2a2 format a40 trunc
column ida2a2 format 999999

accept domain prompt 'Enter domain name to index: '
accept filename prompt 'Enter filename for report: '

spool &filename

select 'VR', x.classnamea2a2, x.branchiditerationinfo from 
   AdministrativeDomain a, 
   wtdocument x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain'
/


select 'VR', x.classnamea2a2, x.branchiditerationinfo from 
   AdministrativeDomain a, 
   wtpart x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangerequest2 x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangeorder2 x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangeactivity2 x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangeissue x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangeinvestigation x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtchangeproposal x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'OR', x.classnamea2a2, x.ida2a2 from 
   AdministrativeDomain a, 
   wtanalysisactivity x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
/

select 'VR', x.classnamea2a2, x.branchiditerationinfo from 
   AdministrativeDomain a, 
   epmdocument x
   where a.ida2a2 = x.ida3domainref and
   a.name = '&domain' 
;
spool off
