Drop table car;
USE world;
CREATE TABLE car (
IDpol INT(10) NOT NULL,
ClaimNb INT(10) NOT NULL,
Exposure float(10) NOT NULL,
Area VARCHAR(256) NOT NULL,
VehPower INT(10) NOT NULL,
VehAge INT(10) NOT NULL,
DrivAge INT(10) NOT NULL,
BonusMalus INT(10) NOT NULL,
VehBrand  VARCHAR(256) NOT NULL,
VehGas  VARCHAR(256) NOT NULL,
Density  INT(10) NOT NULL,
Region  VARCHAR(256) NOT NULL

);
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Dataset+-+auto_insurance_risk (1).csv"
INTO TABLE car
COLUMNS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#1)
select (count(case when claimnb>=1 then IDpol  else null END  )/count(*))*100 as percen from car;
#2)
ALTER TABLE car
add column claim_flag INT AS
(
case 
when claimnb > 0 then 1
else 0
END);

#3)

Select Avg(Exposure) from car
WHERE claim_flag=1;

Select Avg(Exposure) from car
WHERE claim_flag=0;

#4)

ALTER TABLE car
add column exposure_bucket VARCHAR(10) AS
(
CASE when exposure BETWEEN 0 and 0.25 then 'E1'
when exposure BETWEEN 0.26 and 0.5 then 'E2'
when exposure BETWEEN 0.51 and 0.75 then 'E3'
else 'E4'
END
);

with total as
( select sum(claimnb) as total
    from car )
select exposure_bucket, (sum(claimnb)/total.total) *100 as sel_cnt
from car,total
group by exposure_bucket
order by exposure_bucket;


#5)
Select area,(sum(claimnb)/count(IDpol))*100 as percent   
from car
group by area
order by area;


#6)

Select area,exposure_bucket,(sum(claimnb)/count(IDpol))*100 as average   
from car
group by area,exposure_bucket
order by area,exposure_bucket;
#7)

Select claim_flag,avg(VehAge)  as Avg_vehage
from car
group by claim_flag;
Select area, avg(VehAge) as Avg_vehage
from car
where claim_flag = 1
group by area
order by area;

#8)

Select exposure_bucket,claim_flag, avg(VehAge) as Avg_vehicle 
from car 
group by exposure_bucket,claim_flag
order by exposure_bucket,claim_flag;

#9)

ALTER TABLE car
add column Claim_Ct VARCHAR(10) AS
( 
CASE when Claimnb = 1 then '1 Claim'
when Claimnb > 1 then 'MT 1 Claims'
when Claimnb = 0 then 'No Claims'
END);

SELECT Claim_Ct, avg(BonusMalus) as Avg_BM from car
group by Claim_Ct;

#10)

SELECT Claim_Ct, avg(Density) as Avg_den
from car
group by Claim_Ct;

#11)
Select a.VehBrand,a.VehGas,max(a.avgclaim) as Avgclaim from  (
Select VehBrand,VehGas,avg(claimNb) as avgclaim from car group by VehBrand,VehGas
) as a

#12)

Select region,exposure_bucket,(sum(case when claim_flag =1 then claimnb else null end)*100/count(IDpol)) as claimrate  
from car 
group by region,exposure_bucket
order by claimrate DESC
LIMIT 5;

#13)
Select count(*) from car
where DrivAge <18 and claim_flag=1;

ALTER TABLE world.car
add column DrivAge_bucket VARCHAR(32) AS 
(case 
when DrivAge=18 then '1-Beginner'
when DrivAge<=30 then '2-Junior'
when DrivAge<=45 then '3-Middle Age'
when DrivAge<=60 then '4-Mid-Senior'
else '5-Senior'
 end);
 
Select avg(BonusMalus) as Avg_BonusMalus, DrivAge_bucket
from car
group by DrivAge_bucket
order by DrivAge_bucket;



