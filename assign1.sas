/*1*/
PROC IMPORT 
OUT= agent_score
DATAFILE= "/folders/myfolders/data/Agent_Score.csv"
DBMS=CSV 
REPLACE;
GETNAMES=YES;
RUN;

PROC IMPORT 
OUT= online
DATAFILE= "/folders/myfolders/data/Online.csv"
DBMS=CSV 
REPLACE;
GETNAMES=YES;
RUN;


PROC IMPORT 
OUT= third_party
DATAFILE= "/folders/myfolders/data/Third_Party.csv"
DBMS=CSV 
REPLACE;
GETNAMES=YES;
RUN;


PROC IMPORT 
OUT= roll_agent
DATAFILE= "/folders/myfolders/data/Roll_Agent.csv"
DBMS=CSV 
REPLACE;
GETNAMES=YES;
RUN;


/*2*/
data policy;
set online third_party roll_agent;
run;


PROC SORT
data = policy;
by policy_num;
run;

/*Joining Agent Score file with policy data-> base_policy*/
PROC SQL;
Create Table base_policy AS
Select A.*, B.Persistency_Score, B.NoFraud_Score
FROM policy A LEFT JOIN agent_score B
ON A.agentid = B.AgentID;
QUIT;


/*3*/
Data base_policy(drop=hhid proposal_num);
SET base_policy;
run;


/*4*/
DATA premium;
SET base_policy;
IF payment_mode = 'Quaterly' then Premium= Premium*4;
Else if payment_mode = 'Semi Annual' then Premium= Premium*2;
Else if payment_mode = 'Monthly' then Premium= Premium*12;
Else Premium = Premium;
RUN;




/*5*/
data premium;
set premium;
customer_age= intck('year',dob,'31JUL2020'd,'continuous');
policy_tenure= intck('year',policy_date,'31JUL2020'd,'continuous');
run;

/*6*/
data premium;
set premium;
product_level_2 = substr(product_lvl2, 6, 10);
run;

data premium (drop= product_lvl2);
set premium;
run;


data premium;
set premium;
product_name = cats(product_lvl1," | " ,product_level_2);
run;


data premium (drop=product_level_2 product_lvl1);
set premium;
run; 


/*7*/

PROC SQL;
create table policy_analysis as
SELECT policy_status, product_name
FROM premium
WHERE policy_status in ('Lapsed','Payment Due', 'Inforced');
QUIT;

proc FREQ data = policy_analysis;
tables product_name*policy_status /NOCOL NOROW; 
run;

/*8*/
proc sql;
select
	payment_mode,avg(Premium) as Average_premium
from premium
group by payment_mode;
quit;


/*9*/
proc sql;
select
policy_status, product_name ,avg(Persistency_Score) as Average_ps, avg(NoFraud_Score) as average_fs, avg(policy_tenure) as Average_pt
from premium
group by policy_status, product_name;
quit; 

/*10*/
proc sql;
select
acq_chnl, policy_status, avg(customer_age) as Average_customer_age
from premium
group by acq_chnl, policy_status;
quit;




