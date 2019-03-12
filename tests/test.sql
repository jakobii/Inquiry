USE [master]  
GO

drop table if exists [Employees]
GO

DROP DATABASE IF EXISTS [MHUSD]
GO

CREATE DATABASE [MHUSD]
GO

USE [MHUSD]

create table [Employees] (
    [ID] int primary key,
    [Firstname] varchar(50),
    [middlename] varchar(50),
    [lastname] varchar(50),
    [Hired] date,
    [Rehired] date,
    [Terminated] date,
)

insert into [dbo].[Employees] (
    [ID],
    [Firstname],
    [middlename],
    [lastname],
    [Hired]
)
Values 
(1,'Jacob','Regino','Ochoa','2017-4-1'),
(2,'Reah','Gacho','Ochoa','2018-6-1')

select *
from [Employees]