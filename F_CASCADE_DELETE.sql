

create or replace type T_STRING_LIST as table of varchar2( 32000 );
/

 

create or replace function F_CASCADE_DELETE ( I_TABLE_NAME    in varchar2
                                            , I_WHERE         in varchar2 
                                            ) return T_STRING_LIST is

/* ********************************************************************************************************

    History of changes
    yyyy.mm.dd | Version | Author         | Changes
    -----------+---------+----------------+-------------------------
    2017.01.06 |  1.0    | Ferenc Toth    | Created 

******************************************************************************************************** */

    V_RESULT            T_STRING_LIST := T_STRING_LIST();
    V_PK                varchar2( 32000 );
    V_WHERE             varchar2( 32000 );
begin

    select listagg( COLUMN_NAME, ',' ) within group ( order by position )
      into V_PK
      from USER_CONSTRAINTS UC
         , USER_CONS_COLUMNS DBC
     where UC.CONSTRAINT_TYPE  = 'P'
       and DBC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
       and DBC.TABLE_NAME      = UPPER( I_TABLE_NAME );
      
    -- delete its children first
    for L_CHC in (select distinct CHILDREN.TABLE_NAME as CHILD_TABLE_NAME
                     from (select TABLE_NAME
                                 , R_CONSTRAINT_NAME
                              from USER_CONSTRAINTS   
                             where STATUS      = 'ENABLED'    
                               and TABLE_NAME != upper( I_TABLE_NAME )
                          ) CHILDREN,
                          (select CONSTRAINT_NAME
                              from USER_CONSTRAINTS   
                             where CONSTRAINT_TYPE = 'P'                
                               and TABLE_NAME      = upper( I_TABLE_NAME )
                          ) PARENT
                    where CHILDREN.R_CONSTRAINT_NAME = PARENT.CONSTRAINT_NAME
                 )
    loop

        for L_CHFK in (select listagg( CHILDREN.COLUMN_NAME, ',' ) within group ( order by CHILDREN.POSITION ) as FK
                          from (select UC.TABLE_NAME
                                      , DBC.COLUMN_NAME
                                      , POSITION
                                      , UC.CONSTRAINT_NAME
                                      , R_CONSTRAINT_NAME
                                   from USER_CONSTRAINTS   UC
                                      , USER_CONS_COLUMNS DBC
                                  where UC.CONSTRAINT_TYPE  = 'R' 
                                    and UC.STATUS           = 'ENABLED'               
                                    and DBC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME
                                    and UC.TABLE_NAME       = L_CHC.CHILD_TABLE_NAME
                               ) CHILDREN,
                               (select UC.TABLE_NAME
                                      , DBC.COLUMN_NAME
                                      , POSITION
                                      , UC.CONSTRAINT_NAME
                                   from USER_CONSTRAINTS   UC
                                      , USER_CONS_COLUMNS DBC
                                  where UC.CONSTRAINT_TYPE  = 'P'                
                                    and DBC.CONSTRAINT_NAME = UC.CONSTRAINT_NAME 
                                    and UC.TABLE_NAME       = upper( I_TABLE_NAME )
                               ) PARENT
                         where CHILDREN.R_CONSTRAINT_NAME = PARENT.CONSTRAINT_NAME
                           and CHILDREN.POSITION          = PARENT.POSITION  
                      )
        loop

            V_WHERE := '('||L_CHFK.FK||') in (select '||V_PK||' from '||UPPER( I_TABLE_NAME )||' where '||I_WHERE||') ';

            for L_CHD in (select * from table( F_CASCADE_DELETE( L_CHC.CHILD_TABLE_NAME, V_WHERE ) ) )
            loop
                V_RESULT.extend;
                V_RESULT( V_RESULT.count ) := L_CHD.COLUMN_VALUE;
            end loop;

        end loop;

    end loop;
   
    -- the children are deleted, then delete itself

    V_RESULT.extend;
    V_RESULT( V_RESULT.count ) := 'delete '||UPPER( I_TABLE_NAME )||' where '||I_WHERE;
 
    return V_RESULT;
    
end;
/

