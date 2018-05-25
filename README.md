
# Cascade Delete

## Oracle SQL and PL/SQL solution

The **F_CASCADE_DELETE** function generates the list of DELETE commands, goes cascading down the foreing key references.
Use the result list to check and delete or update the referenced rows from bottom to top.
Certainly not all of delete commands able to execute, because of other constraints, but the result shows every part in the schema, what may reference directly or indirectly to the top row(s).
Replacing the "delete" with "select * from" shows the referenced rows.

Parameters:

    I_TABLE_NAME        the name of table where we want to delete
    I_WHERE             the condition, without "where", what we want to delete

Sample:

    select * from table( F_CASCADE_DELETE ( 'PERSON', 'NAME=''Ferenc Toth''' ) );

Result:

    delete TEAM_PRODUCT_LINE where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete ITEM where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete PERSON_MATERIAL where (MATERIAL_TYPE_CODE) in (select CODE from MATERIAL_TYPE where (MATERIAL_TYPE_GROUP) in (select CODE from MATERIAL_TYPE_GROUP where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) ) 
    delete MATERIAL_TYPE where (MATERIAL_TYPE_GROUP) in (select CODE from MATERIAL_TYPE_GROUP where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) 
    delete MATERIAL_TYPE_GROUP where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete TEAM_MEMBER where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete SPRINT where (TEAM_CODE) in (select CODE from TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete TEAM where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete ITEM where (RESPONSIBLE_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete ITEM where (PROJECT_ID) in (select ID from PROJECT where (ASSIGNEE_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete PROJECT where (ASSIGNEE_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete EMPLOYEE where (PERSON_ID,SUPERIOR_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete PERSON_KNOWLEDGE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete TEAM_PRODUCT_LINE where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete ITEM where (PRODUCT_CODE) in (select CODE from PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) 
    delete ITEM where (PROJECT_ID) in (select ID from PROJECT where (PRODUCT_CODE) in (select CODE from PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) ) 
    delete PROJECT where (PRODUCT_CODE) in (select CODE from PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) 
    delete ITEM where (MODULE_ID) in (select ID from MODULE where (PRODUCT_CODE) in (select CODE from PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) ) 
    delete MODULE where (PRODUCT_CODE) in (select CODE from PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) ) 
    delete PRODUCT where (PRODUCT_LINE_CODE) in (select CODE from PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') ) 
    delete PRODUCT_LINE where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete TEAM_MEMBER where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete VACATION where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete SECURE_KEY_OWNER where (OWNER) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete PERSON_MATERIAL where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete PARTICIPANT where (PERSON_ID) in (select ID from PERSON where NAME='Ferenc Toth') 
    delete PERSON where NAME='Ferenc Toth'

