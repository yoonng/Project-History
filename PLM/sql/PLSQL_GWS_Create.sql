-- 1. Stored Procedure

CREATE OR REPLACE PROCEDURE EveryHourUpdateJobStatus
IS
-- -----------------------------------------------------------------------------
-- 1. 프로그램 설명 : 매시간마다 Jobstatus를 수정
--                   지연의 기준은 관리자가 정한 목표 시작일, 목표 종료일
-- 2. 관련 테이블   : GWSJOBITEMINSTANCE(To-do Ad-hoc), GWSREPEATJOBITEMINSTANCE(반복업무)
-- 2. 프로그래머    : 장현수
-- 3. 작성 시간     : 2003-04-29
-- -----------------------------------------------------------------------------
err_code varchar2(100);
cnt      number;
BEGIN
-- ===============================================================
-- 1. Program Start
-- ===============================================================

    INSERT INTO GWSJOBSTATUSLOG
           ( PROGRAM,  DESCRIPTION, RUNSTAMP )
    VALUES ('EveryHourUpdateJobStatus', '1.START',  SYSDATE ) ;

    commit;

-- ===============================================================
-- 2. GWSJOBITEMINSTANCE (To-do Ad-hoc) 수정
-- ===============================================================

   BEGIN
        -- DelayedReady
        select count(ida2a2) into cnt  
        from GWSJOBITEMINSTANCE 
        WHERE  JOBSTATUS = 'Ready'
        AND    ORDEREDSTARTDATE < sysdate  ;
        
        if cnt > 0 then
                UPDATE GWSJOBITEMINSTANCE
                SET    JOBSTATUS = 'DelayedReady'
                WHERE  JOBSTATUS = 'Ready'
                AND    ORDEREDSTARTDATE < sysdate  ;
        
                INSERT INTO GWSJOBSTATUSLOG
                   ( PROGRAM,    DESCRIPTION,   RUNSTAMP )
                VALUES ('EveryHourUpdateJobStatus', '2.GWSJOBITEMINSTANCE - DelayedReady : ' || to_char(cnt) || ' items Completed',  SYSDATE ) ;
        else
                INSERT INTO GWSJOBSTATUSLOG
                   ( PROGRAM,    DESCRIPTION,   RUNSTAMP )
                VALUES ('EveryHourUpdateJobStatus', '2.GWSJOBITEMINSTANCE - DelayedReady : no items',  SYSDATE ) ;       
        end if;
       
        commit;

        EXCEPTION
            WHEN OTHERS THEN
                err_code :=  SQLCODE || SQLERRM;
                INSERT INTO GWSJOBSTATUSLOG (PROGRAM, DESCRIPTION, RUNSTAMP)
                VALUES ('EveryHourUpdateJobStatus', '2.GWSJOBITEMINSTANCE - DelayedReady : ' || err_code,  SYSDATE ) ;
                COMMIT;
    END;

    BEGIN
        -- DelayedInprograss
        select count(ida2a2) into cnt  
        from GWSJOBITEMINSTANCE 
        WHERE  JOBSTATUS = 'Inprograss'
        AND    ORDEREDENDDATE < sysdate  ;
        
        if cnt > 0 then 
                UPDATE GWSJOBITEMINSTANCE
                SET    JOBSTATUS = 'DelayedInprograss'
                WHERE  JOBSTATUS = 'Inprograss'
                AND    ORDEREDENDDATE < sysdate;
        
                INSERT INTO GWSJOBSTATUSLOG
                   ( PROGRAM,    DESCRIPTION,   RUNSTAMP )
                VALUES ('EveryHourUpdateJobStatus', '3.GWSJOBITEMINSTANCE - DelayedInprograss : ' || to_char(cnt) || ' items Completed',  SYSDATE ) ;
        else
                INSERT INTO GWSJOBSTATUSLOG
                   ( PROGRAM,    DESCRIPTION,   RUNSTAMP )
                VALUES ('EveryHourUpdateJobStatus', '3.GWSJOBITEMINSTANCE - DelayedInprograss : no items',  SYSDATE ) ;               
        end if;
        
        commit;

        EXCEPTION
            WHEN OTHERS THEN
                err_code := SQLCODE || SQLERRM;
                INSERT INTO GWSJOBSTATUSLOG (PROGRAM, DESCRIPTION, RUNSTAMP)
                VALUES ('EveryHourUpdateJobStatus', '3.GWSJOBITEMINSTANCE - DelayedInprograss : ' || err_code,  SYSDATE ) ;
                COMMIT;
    END;

        INSERT INTO GWSJOBSTATUSLOG
           ( PROGRAM,    DESCRIPTION,   RUNSTAMP )
        VALUES ('EveryHourUpdateJobStatus', '6.END',  SYSDATE ) ;

    COMMIT;
END;
/


-- 2. Trigger

CREATE OR REPLACE TRIGGER GwsJobItemInstance_History
before insert or update or delete   on GwsJobItemInstance
for each row
declare
   vHistoryType varchar2(10);
   vFlag varchar2(1);
begin
   vFlag := '0';
   
   if inserting then 
       vHistoryType := 'Insert';    
       vFlag := '1';        
   elsif updating then
       vHistoryType := 'update';    
       vFlag := '1';        
   elsif deleting then    
       vHistoryType := 'Delete';    
       vFlag := '2';             
   else 
       vFlag := '0'; 
   end if; 
   
   if vflag = '1' then
           insert into GwsJobItemInstanceOld
               (seq,                     HistoryType,               HistorySaveTime,     
                idA2A2,                  title,                     manager,             
                managerFullName,         jobOwner,                  jobOwnerFullname,    
                orderedStartDate,        orderedEndDate,            myPlannedStartDate,  
                myPlannedEndDate,        actualStartDate,           actualEndDate,       
                jobCategoryOidStr,       jobCategoryPath,           jobCategoryName,     
                description,             preJobItemOidStr,          postJobItemOidStr,   
                sourceType,              jobType,                   jobPriority,                 
                jobStatus,               previousJobStatus,         jobItemTemplateCode, 
                JOBITEMINSTANCECODE,     JOBDURATION,               firstRead,               
                oDFullDay,               mPDFullDay,                eventSet,                
                orgInfoOidStr,           MANAGERORGINFOOIDSTR,      period,              
                occurTime,               jobFamilyId,               repeatStartDate,     
                repeatEndDate,           PBOINFO,                   REQTYPE,
                inheritedDomain,         classnamekeyA4,      
                idA3A4,                  classnamekeydomainRef,     idA3domainRef,       
                createStampA2,           modifyStampA2,             classnameA2A2,       
                updateCountA2,           updateStampA2               ) 
            values
               (GwsJobItemInstanceold_seq.nextval,        vHistoryType,       sysdate,         
                :new.idA2A2,              :new.title,                  :new.manager,             
                :new.managerFullName,     :new.jobOwner,               :new.jobOwnerFullname,    
                :new.orderedStartDate,    :new.orderedEndDate,         :new.myPlannedStartDate,  
                :new.myPlannedEndDate,    :new.actualStartDate,        :new.actualEndDate,       
                :new.jobCategoryOidStr,   :new.jobCategoryPath,        :new.jobCategoryName,     
                :new.description,         :new.preJobItemOidStr,       :new.postJobItemOidStr,   
                :new.sourceType,          :new.jobType,                :new.jobPriority,                 
                :new.jobStatus,           :new.previousJobStatus,      :new.jobItemTemplateCode, 
                :new.JOBITEMINSTANCECODE, :new.JOBDURATION,            :new.firstRead,           
                :new.oDFullDay,           :new.mPDFullDay,             :new.eventSet,            
                :new.orgInfoOidStr,       :new.MANAGERORGINFOOIDSTR,   :new.period,              
                :new.occurTime,           :new.jobFamilyId,            :new.repeatStartDate,     
                :new.repeatEndDate,       :new.PBOINFO,                :new.REQTYPE,
                :new.inheritedDomain,     :new.classnamekeyA4,      
                :new.idA3A4,              :new.classnamekeydomainRef,  :new.idA3domainRef,       
                :new.createStampA2,       :new.modifyStampA2,          :new.classnameA2A2,       
                :new.updateCountA2,       :new.updateStampA2            )              ;
                
     elsif vflag = '2' then       
           insert into GwsJobItemInstanceOld
               (seq,                     HistoryType,               HistorySaveTime,     
                idA2A2,                  title,                     manager,             
                managerFullName,         jobOwner,                  jobOwnerFullname,    
                orderedStartDate,        orderedEndDate,            myPlannedStartDate,  
                myPlannedEndDate,        actualStartDate,           actualEndDate,       
                jobCategoryOidStr,       jobCategoryPath,           jobCategoryName,     
                description,             preJobItemOidStr,          postJobItemOidStr,   
                sourceType,              jobType,                   jobPriority,                 
                jobStatus,               previousJobStatus,         jobItemTemplateCode, 
                JOBITEMINSTANCECODE,     JOBDURATION,               firstRead,               
                oDFullDay,               mPDFullDay,                eventSet,                
                orgInfoOidStr,           MANAGERORGINFOOIDSTR,      period,              
                occurTime,               jobFamilyId,               repeatStartDate,     
                repeatEndDate,           PBOINFO,                   REQTYPE,
                inheritedDomain,         classnamekeyA4,      
                idA3A4,                  classnamekeydomainRef,     idA3domainRef,       
                createStampA2,           modifyStampA2,             classnameA2A2,       
                updateCountA2,           updateStampA2               ) 
            values
               (GwsJobItemInstanceold_seq.nextval,        vHistoryType,       sysdate,         
                :old.idA2A2,              :old.title,                  :old.manager,             
                :old.managerFullName,     :old.jobOwner,               :old.jobOwnerFullname,    
                :old.orderedStartDate,    :old.orderedEndDate,         :old.myPlannedStartDate,  
                :old.myPlannedEndDate,    :old.actualStartDate,        :old.actualEndDate,       
                :old.jobCategoryOidStr,   :old.jobCategoryPath,        :old.jobCategoryName,     
                :old.description,         :old.preJobItemOidStr,       :old.postJobItemOidStr,   
                :old.sourceType,          :old.jobType,                :old.jobPriority,                 
                :old.jobStatus,           :old.previousJobStatus,      :old.jobItemTemplateCode, 
                :old.JOBITEMINSTANCECODE, :old.JOBDURATION,            :old.firstRead,           
                :old.oDFullDay,           :old.mPDFullDay,             :old.eventSet,            
                :old.orgInfoOidStr,       :old.MANAGERORGINFOOIDSTR,   :old.period,              
                :old.occurTime,           :old.jobFamilyId,            :old.repeatStartDate,     
                :old.repeatEndDate,       :old.PBOINFO,                :old.REQTYPE,
                :old.inheritedDomain,     :old.classnamekeyA4,      
                :old.idA3A4,              :old.classnamekeydomainRef,  :old.idA3domainRef,       
                :old.createStampA2,       :old.modifyStampA2,          :old.classnameA2A2,       
                :old.updateCountA2,       :old.updateStampA2            )              ;
           
    end if;     
end;    
/  

CREATE OR REPLACE TRIGGER GwsToCheckItem_History
before insert or update or delete   on GwsToCheckItem
for each row
declare
   vHistoryType varchar2(10);
   vFlag varchar2(1);
begin
   vFlag := '0';
   
   if inserting then 
       vHistoryType := 'Insert';    
       vFlag := '1';        
   elsif updating then
       vHistoryType := 'update';    
       vFlag := '1';        
   elsif deleting then    
       vHistoryType := 'Delete';    
       vFlag := '2';             
   else 
       vFlag := '0'; 
   end if; 
     
   if vflag = '1' then
           insert into GwsToCheckItemOld
               (seq,                     HistoryType,               HistorySaveTime,     
                idA2A2,                  selected,                  userId,             
                defaultToCheck,          toCheckType,               SOURCEINSTANCEOIDSTR,
                classnamekeyA4,    
                idA3A4,                  createStampA2,             modifyStampA2, 
                classnameA2A2,           updateCountA2,             updateStampA2               ) 
            values
               (GwsToCheckItemOld_seq.nextval,        vHistoryType,    sysdate,         
                :new.idA2A2,             :new.selected,             :new.userId,             
                :new.defaultToCheck,     :new.toCheckType,          :new.SOURCEINSTANCEOIDSTR,
                :new.classnamekeyA4,    
                :new.idA3A4,             :new.createStampA2,        :new.modifyStampA2, 
                :new.classnameA2A2,      :new.updateCountA2,        :new.updateStampA2          )    ;
                
     elsif vflag = '2' then       
           insert into GwsToCheckItemOld
               (seq,                     HistoryType,               HistorySaveTime,     
                idA2A2,                  selected,                  userId,             
                defaultToCheck,          toCheckType,               SOURCEINSTANCEOIDSTR,
                classnamekeyA4,    
                idA3A4,                  createStampA2,             modifyStampA2, 
                classnameA2A2,           updateCountA2,             updateStampA2               ) 
            values
               (GwsToCheckItemOld_seq.nextval,        vHistoryType,   sysdate,         
                :old.idA2A2,             :old.selected,             :old.userId,             
                :old.defaultToCheck,     :old.toCheckType,          :old.SOURCEINSTANCEOIDSTR,
                :old.classnamekeyA4,    
                :old.idA3A4,             :old.createStampA2,        :old.modifyStampA2, 
                :old.classnameA2A2,      :old.updateCountA2,        :old.updateStampA2          )    ;
           
    end if;     
end;    
/       
        
--3. Function
CREATE OR REPLACE function getGwsJobType( p_jobType varchar2, p_userId varchar2, p_dbUserId varchar2) return varchar2 is
   v_string varchar2(64) default null;
begin
   if p_jobType = 'ToDo' then
      if p_userId = p_dbUserId then
	     v_string := p_jobType;
	  else
	     v_string := 'ToCheck';
	  end if;
   else
      v_string := p_jobType;
   end if;
   
   return v_string;   
end getGwsJobType;
/

CREATE OR REPLACE function getGwsSplitString( p_input varchar2, p_number number) return varchar2 is
   v_string varchar2(1024) default null;
   v_temp varchar2(1024) default null;
begin

   if p_number >= 1 then
   	  v_string := substr(p_input, 0, instr(p_input,',')-1);
	  v_temp := substr(p_input, instr(p_input,',')+1);
   end if;
   if p_number >= 2 then
      v_string := substr(v_temp, 0, instr(v_temp,',')-1);
	  v_temp := substr(v_temp, instr(v_temp,',')+1);
   end if;
   if p_number >= 3 then
      v_string := substr(v_temp, 0, instr(v_temp,',')-1);
	  v_temp := substr(v_temp, instr(v_temp,',')+1);
   end if;
   if p_number >= 4 then
      v_string := substr(v_temp, 0, instr(v_temp,',')-1);
	  v_temp := substr(v_temp, instr(v_temp,',')+1);
   end if;
   if p_number >= 5 then
      v_string := substr(v_temp, 0, instr(v_temp,',')-1);
	  v_temp := substr(v_temp, instr(v_temp,',')+1);
   end if;
   if p_number >= 6 then
      v_string := substr(v_temp, 0, instr(v_temp,',')-1);
	  v_temp := substr(v_temp, instr(v_temp,',')+1);
   end if;
   if p_number = 7 then
      v_string := v_temp;
   end if;

   return v_string;
end getGwsSplitString;
/



CREATE OR REPLACE function getGwsSequence( p_primary number, p_userId varchar2, p_select varchar2,
	   p_seqJobOwner varchar2, p_seqCategoryOidStr varchar2) return varchar2
is
	v_jobOid varchar2(64) default null;
	v_preOid varchar2(64) default null;
	v_postOid varchar2(64) default null;
	v_preToCheckOid varchar2(64) default null;
	v_postToCheckOid varchar2(64) default null;
	v_preToCheckSelect varchar2(64) default null;
	v_postToCheckSelect varchar2(64) default null;
	v_seqPreOid varchar2(64) default null;
	v_seqPostOid varchar2(64) default null;
	v_seqPreOid1 varchar2(64) default null;
	v_seqPostOid1 varchar2(64) default null;

   cursor qry is
   		select a0.joboid, b1.ida2a2 preoid, b2.ida2a2 postoid
		from (
			  select jobowner, ida2a2 joboid, substr(preJobitemOidstr, 37) preoid, substr(postJobitemOidstr, 37) postoid
			  from gwsjobItemInstance
			  where jobowner = p_userId
			  and ida2a2 = p_primary
			  and (prejobitemoidstr is not null or postjobitemoidstr is not null)
			  ) a0, gwsjobItemInstance b1,gwsjobItemInstance b2
		where a0.jobowner = p_userId
		and a0.preoid = b1.ida2a2(+)
		and a0.postoid = b2.ida2a2(+)
		and ( b1.ida2a2 is not null or b2.ida2a2 is not null);

   cursor qryToCheck(v_joboid varchar2, v_refoid varchar2) is
   		select 'OR:ext.cpcex.gws.GwsToCheckItem:'||a0.ida2a2 tocheckoid, a0.selected tocheckselected
		from gwstocheckitem a0
		where a0.ida3a4 = v_refoid and substr(a0.sourceinstanceoidstr, 37) = v_joboid and a0.userid = p_userId;

   cursor qrySequenceInstanceByJobOwner(v_refoid varchar2) is
   		select a0.ida2a2
		from gwsjobiteminstance a0
		where a0.ida2a2 = v_refoid and a0.jobowner = p_seqJobOwner;

   cursor qrySequenceInstanceByCategory(v_refoid varchar2) is
   		select a0.ida2a2
		from gwsjobiteminstance a0
		where a0.ida2a2 = v_refoid and a0.jobCategoryOidStr = p_seqCategoryOidStr;
-- sql%rowcount
begin


	open qry;
	fetch qry into v_jobOid, v_preOid, v_postOid;
	close qry;
	if v_preOid is not null and v_jobOid is not null then
		open qryToCheck(v_jobOid, v_preOid);
		fetch qryToCheck into v_preToCheckOid, v_preToCheckSelect;
		close qryToCheck;
	end if;
	if v_postOid is not null and v_jobOid is not null  then
		open qryToCheck(v_jobOid, v_postOid);
		fetch qryToCheck into v_postToCheckOid, v_postToCheckSelect;
		close qryToCheck;
	end if;
	if p_select is not null then
	   if v_preToCheckSelect <> p_select then
	   	  v_preToCheckOid := null;
		  v_preOid := null;
	   end if;
	   if v_postToCheckSelect <> p_select then
	   	  v_postToCheckOid := null;
		  v_postOid := null;
	   end if;

	   if v_preOid is null and v_postOid is null then
	   	  v_jobOid := null;
	   end if;
	end if;
	if v_preToCheckOid is null then
	   v_preOid := null;
	   v_preToCheckSelect := null;
	end if;
	if v_postToCheckOid is null then
	   v_postOid := null;
	   v_postToCheckSelect := null;
	end if;

	if v_preOid is not null and p_seqJobOwner is not null then
		open qrySequenceInstanceByJobOwner(v_preOid);
		fetch qrySequenceInstanceByJobOwner into v_seqPreOid;
		close qrySequenceInstanceByJobOwner;
		if v_seqPreOid is null then
		   v_preOid := null;
		   v_preToCheckOid := null;
		   v_preToCheckSelect := null;
		end if;
	end if;
	if v_preOid is not null and p_seqCategoryOidStr is not null then
		open qrySequenceInstanceByCategory(v_preOid);
		fetch qrySequenceInstanceByCategory into v_seqPreOid1;
		close qrySequenceInstanceByCategory;
		if v_seqPreOid1 is null then
		   v_preOid := null;
		   v_preToCheckOid := null;
		   v_preToCheckSelect := null;
		end if;
	end if;

	if v_postOid is not null and p_seqJobOwner is not null then
		open qrySequenceInstanceByJobOwner(v_postOid);
		fetch qrySequenceInstanceByJobOwner into v_seqPostOid;
		close qrySequenceInstanceByJobOwner;
		if v_seqPostOid is null then
		   v_postOid := null;
		   v_postToCheckOid := null;
		   v_postToCheckSelect := null;
		end if;
	end if;
	if v_postOid is not null and p_seqCategoryOidStr is not null then
		open qrySequenceInstanceByCategory(v_postOid);
		fetch qrySequenceInstanceByCategory into v_seqPostOid1;
		close qrySequenceInstanceByCategory;
		if v_seqPostOid1 is null then
		   v_postOid := null;
		   v_postToCheckOid := null;
		   v_postToCheckSelect := null;
		end if;
	end if;
	   if v_preOid is null and v_postOid is null then
	   	  v_jobOid := null;
	   end if;

	return (v_jobOid || ',' || v_preOid || ',' || v_postOid || ',' || v_preToCheckOid || ',' || v_postToCheckOid|| ',' || v_preToCheckSelect || ',' || v_postToCheckSelect);
end;
/

CREATE OR REPLACE function getSeqType( p_jobOid number, p_checkOid number) return varchar2 is
   v_string varchar2(64) default null;
   v_preOid varchar2(64) default null;
   v_postOid varchar2(64) default null;
   
   cursor qry is
   		select substr(a0.preJobitemOidstr, 37) preoid, substr(a0.postJobitemOidstr, 37) postoid
		from gwsjobItemInstance a0
		where a0.ida2a2 = p_jobOid;

begin
	open qry;
	fetch qry into v_preOid, v_postOid;
	close qry;
	
	if v_preOid is not null and v_preOid = p_checkOid  then
	   v_string := 'PRE';
	end if;   
	
	if v_postOid is not null and v_postOid = p_checkOid  then
	   v_string := 'POST';
	end if;
	
   return v_string;
end getSeqType;
/

   