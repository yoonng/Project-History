-- Level 2
        SELECT distinct C9.pjtno, C9.pjtname, C1.taskname, C1.ida2a2 TaskID, C3.name TaskDept, C3.ida2a2,  C1.ida3c4, C7.name PeopleDept
        FROM 
            JELTASK C1,
            (SELECT * FROM TASKMEMBERLINK I0 WHERE I0.TASKMEMBERTYPE = 1)C2,
            DEPARTMENT C3,
            WTUSER C5,
            People C6,
            Department C7,
            jelproject C8,
            jelprojectmaster C9,
            V_WBSLeve3Status C10 
        WHERE
            C1.IDA2A2 = C2.IDA3A5(+)
        AND C1.IDA3C4 = C3.IDA2A2(+)
        AND C2.IDA3A6 = C5.IDA2A2(+)
        and C5.ida2a2 = C6.ida3b4(+)
        and C6.ida3c4 = C7.ida2a2
        and C1.ida3b4 = C8.ida2a2
        and C8.ida3b8 = C9.ida2a2
        and C8.LASTEST = 1
        and C8.statestate <> 'COMPLETED'
        and ( C3.name is null OR C3.name <> C7.name)
        and C10.WBSLEVEL2ID = C1.ida2a2 


--Level 1
        SELECT distinct C9.pjtno, C9.pjtname, C1.taskname, C1.ida2a2 TaskID, C3.name TaskDept, C3.ida2a2,  C1.ida3c4, C7.name PeopleDept
        FROM 
            JELTASK C1,
            (SELECT * FROM TASKMEMBERLINK I0 WHERE I0.TASKMEMBERTYPE = 1)C2,
            DEPARTMENT C3,
            WTUSER C5,
            People C6,
            Department C7,
            jelproject C8,
            jelprojectmaster C9,
            V_WBSLeve3Status C10 
        WHERE
            C1.IDA2A2 = C2.IDA3A5(+)
        AND C1.IDA3C4 = C3.IDA2A2(+)
        AND C2.IDA3A6 = C5.IDA2A2(+)
        and C5.ida2a2 = C6.ida3b4(+)
        and C6.ida3c4 = C7.ida2a2
        and C1.ida3b4 = C8.ida2a2
        and C8.ida3b8 = C9.ida2a2
        and C8.LASTEST = 1
        and C8.statestate <> 'COMPLETED'
        and ( C3.name is null OR C3.name <> C7.name)
        and C10.WBSLEVEL1ID = C1.ida2a2 

--Delete Statement
delete from TASKMEMBERLINK where ida3a5 = 23732881;
update jeltask set ida3c4 = 0 where ida2a2 = 23732881