BEGIN
    DBMS_FGA.ADD_POLICY (
                        object_schema       => 'INFERNAL',
                        object_name         => 'EMPLOYEES',
                        policy_name         => 'EMP_SAL',
                        audit_column        => 'SALARY',
                        audit_condition     => 'USER=''NADYA''',
                        statement_types     => 'INSERT, UPDATE, DELETE'
                        );
END;


CREATE AUDIT POLICY app_leadership_pol
    ACTIONS 
        ALL ON Infernal.Employees WHENEVER NOT SUCCESSFUL, 
        SELECT ON Infernal.Cases,
        INSERT ON Infernal.Cases,
        UPDATE ON Infernal.Cases,
        DELETE ON Infernal.Cases,
        ALL ON Infernal.AssignedCases
    CONTAINER = CURRENT;

AUDIT policy app_leadership_pol BY USERS WITH GRANTED ROLES leadership_dep;
AUDIT policy app_leadership_pol BY SKINNER;
AUDIT policy app_leadership_pol BY INFERNAL;

NOAUDIT policy app_leadership_pol BY USERS WITH GRANTED ROLES leadership_dep;
NOAUDIT policy app_leadership_pol BY SKINNER;
NOAUDIT policy app_leadership_pol BY INFERNAL;

DROP AUDIT POLICY app_leadership_pol;

SELECT dbusername, event_timestamp, action_name, object_name, sql_text, unified_audit_policies 
FROM UNIFIED_AUDIT_TRAIL
WHERE dbusername = 'SKINNER';

    

AUDIT policy ORA_LOGON_FAILURES;
AUDIT policy ORA_SECURECONFIG;
AUDIT policy ORA_ACCOUNT_MGMT;


SELECT * FROM dba_fga_audit_trail;


BEGIN 
    DBMS_FGA.DROP_POLICY (
                        object_schema       => 'INFERNAL',
                        object_name         => 'EMPLOYEES',
                        policy_name         => 'EMP_SAL'
                        );
END;

BEGIN
    DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL (
    audit_trail_type         =>  DBMS_AUDIT_MGMT.AUDIT_TRAIL_ALL,
    use_last_arch_timestamp  =>  FALSE);
END;

select  count(*) from unified_audit_trail;
