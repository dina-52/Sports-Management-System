create database Milestone_2 ;
use Milestone_2
--2.1
go
CREATE PROCEDURE createAllTables
AS
create table SystemUser 
(
username varchar(20) PRIMARY KEY,
Password varchar(20)
);

create table SportsAssociationManager  
(
Id int identity  ,
Name varchar(20),
username varchar(20) ,
primary key ( id ),
FOREIGN KEY (username) REFERENCES SystemUser(username) on delete cascade on update cascade
);


create table SystemAdmin 
(
Id int identity  ,
Name varchar(20),
username varchar(20) ,
primary key ( id ),
FOREIGN KEY (username) REFERENCES SystemUser(username)  on delete cascade on update cascade
);


create table  Fan
(
NationalID varchar(20) ,
Name varchar(20),
Birth_Date DateTime ,
Address varchar(20),
phone_No int,
Status bit,
username varchar(20) ,
primary key ( NationalId ),
FOREIGN KEY (username) REFERENCES SystemUser(username) on delete cascade on update cascade
);


create table Club 
(
club_Id int identity primary key,
Name varchar (20)  ,
location varchar(20)
);

create table ClubRepresentative   
(
Id int identity ,
Name varchar(20),
Club_Id int ,
username varchar(20) ,
primary key ( id ),
foreign key (Club_Id ) references Club (club_Id) on delete cascade on update cascade,
FOREIGN KEY (username) REFERENCES SystemUser(username) on delete cascade on update cascade

);



create table Stadium 
(
Id int identity primary key,
Name varchar(20),
Location varchar(20),
Capacity int ,
Status bit 
);

create table StadiumManager  
( Id int identity ,
Name varchar(20),
Stadium_Id int ,
username varchar(20) ,

Primary key ( Id ),
foreign key (Stadium_Id ) references stadium (Id) on delete cascade on update cascade,
FOREIGN KEY (username) REFERENCES SystemUser(username) on delete cascade on update cascade
);

create table Match 
(
match_Id int identity primary key,
start_time Datetime ,
end_time datetime ,
host_club_Id int,
guest_club_Id int,
stadium_Id int ,
constraint Fk1 foreign key (host_club_Id) references Club (club_Id) ,
constraint Fk2 foreign key (guest_club_Id) references Club (club_Id),
constraint Fk3 foreign key (stadium_Id ) references Stadium (Id) 
);

create table Ticket 
(
Id int identity primary key,
Status bit,
match_Id int ,
foreign key (match_Id ) references Match (match_Id) on delete cascade on update cascade
);

create table HostRequest 
(
Id int identity primary key,
representative_Id int ,
manager_Id int,
match_Id int , 
Status  bit,
foreign key (representative_Id ) references ClubRepresentative (Id),
foreign key (match_Id ) references Match (match_Id) on delete cascade on update cascade,
foreign key (manager_Id ) references StadiumManager (Id)
);

create table TicketBuyingTransactions
(
  fan_nationalId varchar(20) ,
  ticket_Id int,
  foreign key (fan_nationalId ) references fan (NationalId) on delete cascade on update cascade,
  foreign key (ticket_Id ) references Ticket (Id) on delete cascade on update cascade
);


go
exec createAllTables
--a
go
Create Procedure dropAllTables
AS 
DROP TABLE TicketBuyingTransactions
DROP TABLE fan

DROP TABLE HostRequest
DROP TABLE Ticket 
DROP TABLE Match
DROP TABLE StadiumManager
DROP TABLE Stadium

DROP TABLE clubRepresentative
DROP TABLE club

DROP TABLE SportsAssociationManager

DROP TABLE SystemAdmin

DROP TABLE SystemUser

GO

go
create Procedure  clearAllTables 
AS 
delete from TicketBuyingTransactions
delete from Match 
delete from HostRequest
delete from club
delete from Stadium
delete from Ticket                 
delete from StadiumManager
delete from clubRepresentative
delete from fan
delete from SystemAdmin
delete from SportsAssociationManager
delete from SystemUser
go

--c
Create Procedure dropAllProceduresFunctionsViews
as
--stored procedure
drop procedure createAllTables
drop procedure dropAllTables
drop procedure clearAllTables
drop procedure addAssociationManager
drop procedure addNewMatch
drop procedure deleteMatch
drop procedure deleteMatchesOnStadium
drop procedure addClub
drop procedure addTicket
drop procedure deleteClub
drop procedure addStadium
drop procedure deleteStadium
drop procedure blockFan
drop procedure unblockFan
drop procedure addRepresentative
drop procedure addHostRequest
drop procedure addStadiumManager
drop procedure acceptRequest
drop procedure rejectRequest
drop procedure addFan
drop procedure purchaseTicket
drop procedure updateMatchHost
--functions
drop function viewAvailableStadiumsOn
drop function allUnassignedMatches
drop function allPendingRequests
drop function upcomingMatchesOfClub
drop function availableMatchesToAttend
drop function clubsNeverPlayed
drop function matchWithHighestAttendance
drop function matchesRankedByAttendance
drop function requestsFromClub
--views
drop view allAssocManagers
drop view allClubRepresentatives
drop view allStadiumManagers
drop view allFans
drop view allMatches
drop view allTickets
drop view allCLubs
drop view allStadiums
drop view allRequests
drop view clubsWithNoMatches
drop view matchesPerTeam
drop view clubsNeverMatched

go



go
--a

create view allAssocManagers
as 
select a.username , a.Name,s.Password
from SportsAssociationManager a inner join SystemUser s
on a.username=s.username

go

--b

go
create view allClubRepresentatives 
as
select c1.username ,u.Password,  c1.Name Rep_Name,  c.Name Club_Name
from Club c inner join ClubRepresentative c1 
on c.club_Id = c1.Club_Id
inner join SystemUser u
on u.username =c1.username

go

--c

create view allStadiumManagers 
as
select s1.username ,u.Password, s1.Name Manager_Name , s.Name Stadium_Name
from StadiumManager s1 
inner join Stadium s 
on s.Id = s1.Stadium_Id
inner join SystemUser u
on s1.username=u.username
go

--d

go
create view allFans 
as
select  u.username,u.Password, f.Name ,f.NationalID , f.Birth_Date , f.Status
from fan f
left outer join  SystemUser u
on f.username=u.username
go


--e

create view allMatches 
as
select c1.Name as 'HostClub', c2.Name as 'GuestClub' , s.start_time 
from Club c1 
inner join Match s 
on (s.host_club_Id = c1.club_Id) 
inner join club c2 
on ( s.guest_club_Id = c2.club_Id) 
go

--f

create view allTickets as
select c1.Name as 'Host', c2.Name as 'Guest', st.Name, s.start_time
from Club c1 
inner join Match s 
on ( s.host_club_Id = c1.club_Id) 
inner join club c2 
on ( s.guest_club_Id = c2.club_Id ) 
inner join Stadium st 
on ( st.id = s.stadium_Id)
inner join Ticket t
on t.match_Id=s.match_Id

go

--g
create view allClubs 
as select Name , location
from Club 
go

--h
create view allStadiums as 
select Name , Location , capacity , Status 
from Stadium 
go

--i
create view allRequests as
select c.username as 'Representative_Username', s.username as 'Manager_Username', h.Status 
from HostRequest h 
inner join ClubRepresentative c 
on ( h.representative_Id = c.Id) 
inner join StadiumManager s 
on (s.Id= h.manager_Id)
go

--2.3

go
create procedure addAssociationManager
@name varchar(20),
@username varchar(20),
@password varchar(20)
as 

if not exists (select * from SystemUser where @username=username)
begin
	insert into SystemUser values (@username, @password)
	insert into SportsAssociationManager values (@name, @username)
end
go

--ii

create procedure addNewMatch
@hostName varchar(20),
@guestName varchar(20),
@start_time datetime,
@endTime datetime
as 

declare @hostId int 
declare @guestId int

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c2.club_Id
from Club c2
where c2.Name=@guestName;

insert into Match values(@start_time,@endTime,@hostId,@guestId,null)
go



---iii

go
create view clubsWithNoMatches as 
select c.Name
from Club c
where not Exists (select *
				  from Match m
				  where m.host_club_Id=c.club_Id
						or m.guest_club_Id=c.club_Id);

--iv


go
create procedure deleteMatch
@hostName varchar(20),
@guestName varchar(20)
as 

declare @hostId int 
declare @guestId int

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

delete from Match 
where host_club_Id=@hostId and guest_club_Id=@guestId
go

--v

go
create procedure deleteMatchesOnStadium
@sname varchar(20)
as 
declare @sid int

select @sid=s.Id
from stadium s
where @sname=s.Name;

delete from Match where stadium_Id=@sid and start_time>current_timestamp
Go

--vi

create procedure addClub 
@cname varchar(20),
@loc varchar(20)
as 
insert into Club values (@cname, @loc)
Go

--vii

go
create procedure addTicket
@hostName varchar(20),
@guestName varchar(20),
@startMatch datetime
as
declare @matchid int 
select @matchid=m.match_Id
from Match m
inner join Club h
on h.club_Id=m.host_club_Id
inner join Club g 
on g.club_Id=m.guest_club_Id
where @startMatch = start_time and @hostName=h.Name and @guestName=g.Name
insert into Ticket values ( 1 ,@matchid)
go


--viii

go
create procedure deleteClub
@Name varchar(20)
as
declare @CId int
select @CId=c.club_Id
from Club c
where c.Name=@Name
delete from ClubRepresentative where Club_Id=@CId
delete from Match where guest_club_Id=@CId or host_club_Id=@CId
delete from Club where @Name = Name;
go

--ix

go
create procedure addStadium
@Name varchar(20),
@Location varchar(20),
@capacity int 
as
INSERT INTO Stadium values (@Name, @Location,@capacity,1)
go

--x

go
create procedure deleteStadium
@Name varchar(20)
as
declare @Sid int 
select @Sid=s.Id
from Stadium s
where s.Name=@Name

update Match set stadium_Id = Null where stadium_Id=@Sid
update StadiumManager set Stadium_Id = Null where stadium_Id=@Sid
delete from Stadium where @Name=Name
go

--xi

go

create procedure blockFan
@natID varchar(20)
as 
update fan 
set Status=0
where @natID=NationalID;
go

--xii

go
create procedure unblockFan
@natID varchar(20)
as 
update fan 
set Status=1 
where @natID=NationalID;
go


--xiii

go
create procedure addRepresentative
@repName varchar(20),
@CName varchar(20),
@username varchar(20),
@password varchar(20)
as
declare @cId int

if not exists (select * from SystemUser where @username=username)
begin
	select @cId=c.club_Id
	from Club c
	where @CName=Name
	insert into SystemUser values (@username, @password);
	insert into ClubRepresentative values(@repName,@cId,@username)
end
go


Go

--xiv

go
create function viewAvailableStadiumsOn
(@x datetime)
returns @y table (Name varchar(20) , 
				  Location varchar(20) , 
				  Capacity int)
as 
begin 
insert into @y 
select s.Name , s.Location , s.capacity 
from Stadium s 
left outer join Match sp 
on ( sp.stadium_Id = s.Id)
where s.Status = 1 AND (@x <> sp.start_time or sp.start_time is null)
return 
end
go



--xv

go
create procedure addHostRequest
@CName varchar(20),
@SName varchar(20),
@matchtime datetime  
as
declare @mgrId int
declare @repId int
declare @matchId int
declare @stId int

select @mgrId=mgr.id , @stId=s.Id
from Stadium s
inner join StadiumManager mgr
on s.Id=mgr.Stadium_Id
where @SName=s.Name

select @repId=r.id
from ClubRepresentative r
inner join Club c
on r.Club_Id =c.club_Id
where @CName=c.Name

select @matchId=m.match_Id
from Match m
where @matchtime = m.start_time 

insert into HostRequest values (@repId, @mgrId, @matchId, null)
go

--xvi

create function allUnassignedMatches
(@Name varchar(20))
returns @y table ( guestClub varchar(20) 
				  ,start_time datetime )
as
begin 
insert into @y 
select c1.Name , s.start_time
from Match s 
inner join Club c1 
on ( c1.club_Id = guest_club_Id) 
inner join Club c2 
on ( c2.club_Id = host_club_Id)
where s.stadium_Id is null 
AND @Name = c2.Name
return 
end
go

--xvii

go
create procedure addStadiumManager
@name varchar(20),
@SName varchar(20),
@username varchar(20),
@password varchar(20)
as 
declare @stadiumid int

if  not exists (select * from SystemUser where @username=username)
begin
select @stadiumid=s.Id
from Stadium s
where s.Name= @SName;

insert into SystemUser VALUES(@username,@password);
insert into StadiumManager VALUES(@name,@stadiumid,@username);
end
GO

--xviii

go
 create function allPendingRequests
 (@StadiumManagerUser varchar (20))
 returns @y table ( Name varchar(20) ,
					guestclub varchar(20) , 
					start_time datetime)
 as
 begin
 insert into @y
 select cr.Name , c.Name , s.start_time
 from ClubRepresentative cr 
 inner join HostRequest h 
 on (cr.id = h.representative_Id)
 inner join StadiumManager sm 
 on ( h.manager_Id = sm.id) 
 inner join  Match s 
 on (h.match_Id = s.match_Id)
 inner join Club c 
 on ( c.club_Id = s.guest_club_Id) 
 where h.Status is Null
 AND @StadiumManagerUser = sm.username 
 return
 end

go

--xix

go
create procedure acceptRequest
@StMgrUsername varchar(20),
@hostName varchar(20),
@guestName varchar(20),
@start_time datetime
as
declare @matchId int
declare @mgrId int
declare @hostId int 
declare @guestId int
declare @stId int
declare @capacity int

select @mgrId=m.Id, @stId=s.Id, @capacity=s.Capacity
from StadiumManager m inner join Stadium s
on m.Stadium_Id=s.Id
where @StMgrUsername=m.username;

select @hostId=c.club_Id from Club c
where c.Name=@hostName;

select @guestId=c.club_Id from Club c
where c.Name=@guestName;

select @matchId=m.match_Id from Match m
where @guestId=m.guest_club_Id and @hostId=m.host_club_Id ;

update HostRequest
set Status =1
where @matchId=match_Id;

update Match
set stadium_Id=@stId
where match_Id=@matchId

DECLARE @i INT 
SET @i=1
WHILE ( @i <=@capacity )
BEGIN
    exec addTicket @hostName, @guestName, @start_time
    SET @i  = @i  + 1
END

go

--xx

go
create procedure rejectRequest
@StMgrUsername varchar(20),
@hostName varchar(20),
@guestName varchar(20),
@start_time datetime
as

declare @matchId int
declare @mgrId int
declare @hostId int 
declare @guestId int

select @mgrId=s.id
from StadiumManager s
where @StMgrUsername=s.username;


select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

select @matchId=m.match_Id
from Match m
where @guestId=m.guest_club_Id and
@hostId=m.host_club_Id and 
start_time>CURRENT_TIMESTAMP;

update HostRequest
set Status =0
where @matchId=match_Id;
go


--xxi
go
create procedure addFan
@name varchar(20),
@username varchar(20),
@password varchar(20),
@natId varchar(20),
@bd datetime,
@address varchar(20),
@phone int
as 

if not exists (select * from SystemUser where @username=username)
begin
insert into SystemUser values(@username , @password)
insert into fan values (@natId,@name,@bd,@address,@phone,1, @username);
end
go

--xxii 

go
 create function upcomingMatchesOfClub
( @Name  varchar (20))
 returns @y table(hostname varchar(20),guestname varchar(20),
 matchtime datetime,Name varchar(20) )
 as
 begin
 insert into @y
 select c1.Name , c2.Name ,sm.start_time,s.Name
 from club c1 inner join Match sm on( c1.club_Id = sm.host_club_Id) 
 inner join club c2  on (c2.club_Id=sm.guest_club_Id)
 left outer join Stadium s on(sm.stadium_Id=s.Id)
 where (@Name= c1.Name or @Name= c2.Name)
 and current_Timestamp < sm.start_time 
 return
 end
 go


-- xxiii

go
create function availableMatchesToAttend
(@x datetime )
returns @y table ( hostname varchar(20) , guestname varchar(20) ,start_time datetime , Name varchar(20))
as 
begin
insert into @y 
select distinct c1.Name , c2.Name , s.start_time, st.Name
from Match s inner join Club c1 on ( c1.club_Id = s.host_club_Id)
inner join Club c2 on(c2.club_Id = s.guest_club_Id) 
inner join Stadium st on ( st.Id = s.stadium_Id) 
inner join Ticket t on ( t.match_Id = s.match_Id)
where t.Status= 1 
	  And @x < s.start_time 
	  --and s.start_time>CURRENT_TIMESTAMP
return 
end 
go


--xxiv 

go
create procedure purchaseTicket
@natId varchar(20),
@hostName varchar(20),
@guestName varchar(20),
@startTime datetime
as
declare @Fstatus bit
select @Fstatus=Status
from Fan 
where NationalID=@natId
if @Fstatus=1
begin
declare @matchId int
declare @hostId int 
declare @guestId int

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

select @matchId=m.match_Id
from Match m
where @guestId=m.guest_club_Id and 
	  @hostId=m.host_club_Id and 
	  m.start_time=@startTime;

if exists (select * from Ticket where @matchId=match_Id and Status=1)
begin
declare @ticketId as int=(select top 1 t.Id
					  from Ticket t
					  where t.match_Id=@matchId and Status=1)

update Ticket set Status=0 where @ticketId=Id

insert into TicketBuyingTransactions values (@natId,@ticketId)
end
end
go

--xxv

go
create procedure updateMatchHost
@hostName varchar(20),
@guestName varchar(20),
@startTime datetime
as

declare @hostId int
declare @guestId int

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

update Match
set host_club_Id=@guestId , guest_club_Id=@hostId, stadium_Id=null
where guest_club_Id=@guestId and host_club_Id =@hostId and start_time=@startTime


go


go
--xxvi
create view matchesPerTeam as
select c.Name , count(s.match_Id) Matches_Played
from Club c ,  Match s 
WHERE c.club_Id = s.host_club_Id or c.club_Id = s.guest_club_Id
group by c.Name
go

--xxvii
go
create view clubsNeverMatched as
select c.Name Club1, c2.Name Club2
from Club c, club c2
where c.club_Id<c2.club_Id and not Exists (select *
											from Match m
											where (m.guest_club_Id=c.club_Id and m.host_club_Id=c2.club_Id)
											or (m.guest_club_Id=c2.club_Id and m.host_club_Id=c.club_Id))

go


--xxviii
create function clubsNeverPlayed
( @clubname  varchar (20))
returns @y table(clubname varchar(20))
 as
 begin
 insert into @y
 select c.Name
 from Club c
 where @clubname <> c.Name
 except
 (
 select c2.Name
 from Club c2
 inner join Match m
 on c2.club_Id=m.guest_club_Id 
 inner join Club c3
 on c3.club_Id=m.host_club_Id
 where @clubname=c3.Name 
 union
 select c4.Name
 from Club c4
 inner join Match m1
 on c4.club_Id=m1.host_club_Id
 inner join Club c5
 on c5.club_Id=m1.guest_club_Id
 where @clubname=c5.Name  
 )
 return
 end
go


--xxix
drop function matchWithHighestAttendance
select * from Club
select * from Match
select * from Ticket
select * from matchWithHighestAttendance()
go
create function matchWithHighestAttendance()
returns @y table (hostName varchar(20),
				  guestName varchar(20) )
as
begin
insert into @y
select top 1 h.Name,g.Name
from Ticket t 
inner join Match m
on t.match_Id=m.match_Id
inner join Club h
on m.host_club_Id=h.club_Id
inner join Club g
on m.guest_club_Id=g.club_Id
where t.Status=0
group by m.match_Id, h.Name,g.Name
order by count (t.Id) desc

return 
end 
go

--xxx

go
create function matchesrankedbyattendance ()
returns @y table ( hostclub varchar(20) , guestclub varchar (20) ) 
as 
begin
insert into @y
select h.Name Host, g.Name Guest
from Match m
inner join Club h
on m.host_club_Id=h.club_Id
inner join Club g
on m.guest_club_Id=g.club_Id
left outer join (select t.match_Id mId, COUNT(t.Id) attendance
				from Ticket t
				where t.Status=0
				group by t.match_Id)tmp
on m.match_Id= tmp.mId
where m.end_time<CURRENT_TIMESTAMP
order by attendance desc
offset 0 rows

return 
end 
go


--xxxi

go
create function requestsFromClub
(@stName varchar(20), @cName varchar(20))
returns @y table (hostName varchar(20), guestName varchar(20))
as
begin 

declare @mgId int
select @mgId=mn.Id
from Stadium s
inner join StadiumManager mn
on mn.Stadium_Id=s.Id
where s.Name=@stName

insert into @y
select c.Name  Host_Club , c2.Name
from Club c
inner join ClubRepresentative r
on c.club_Id=r.Club_Id
inner join HostRequest req
on r.Id=req.representative_Id
inner join Match m
on req.match_Id=m.match_Id
inner join Club c2 
on m.guest_club_Id=c2.club_Id
where c.Name=@cName and req.manager_Id=@mgId

return
end
go

-----------------------------------------------------------------------------------
--------------------------Milestone 3----------------------------------------------
-----------------------------------------------------------------------------------
go


create procedure UserLogin 
@username varchar(20),
@password varchar(20),
@code int output
as

if exists(
		select * 
		from SystemUser u
		where @username=u.username and @password=u.Password)
	begin 
	if exists(select * from SystemAdmin a where @username='admin' and @password ='admin')
	begin
		select @code=1 from SystemAdmin a where @username='admin' and @password ='admin'
	end
	else if exists(select * from SportsAssociationManager a where @username=a.username)
	begin
	select @code=2 from SportsAssociationManager a where @username=a.username
	end
	else if exists(select * from ClubRepresentative a where @username=a.username)
	begin
	select @code=3 from ClubRepresentative a where @username=a.username
	end
	else if  exists(select * from Fan a where @username=a.username)
	begin 
	select @code=4 from Fan a where @username=a.username
	end
	else if  exists(select * from StadiumManager a where @username=a.username)
	begin 
	select @code=5 from StadiumManager a where @username=a.username
	end
else 
	set @code=0
	end
return

go

--for Association Manager Views

--d
create view allUpcomingMatches as
select h.Name Host, g.Name Guest, m.start_time, m.end_time 
from Club h
inner join Match m
on h.club_Id=m.host_club_Id
inner join Club g
on m.guest_club_Id=g.club_Id
where current_Timestamp < m.start_time


--e
go
create view allPlayedMatches as
select h.Name Host, g.Name Guest, m.start_time, m.end_time 
from Club h
inner join Match m
on h.club_Id=m.host_club_Id
inner join Club g
on m.guest_club_Id=g.club_Id
where current_Timestamp > m.end_time

--for club representative
go
--b
create procedure representativeClubInfo 
@user varchar(20)
as
select c.*
from ClubRepresentative r
inner join Club c
on r.Club_Id=c.club_Id
where r.username=@user

go
create procedure upcomingForMyClub 
@user varchar(20)
as
declare @CId int
select @CId=c.club_Id
from ClubRepresentative r
inner join Club c
on r.Club_Id=c.club_Id
where @user=r.username

 select c1.Name Host, c2.Name Guest,sm.start_time, sm.end_time ,s.Name Stadium
 from club c1 
 inner join Match sm 
 on( c1.club_Id = sm.host_club_Id) 
 inner join club c2  on (c2.club_Id=sm.guest_club_Id)
 left outer join Stadium s on(sm.stadium_Id=s.Id)
 where (@CId= c1.club_Id or @CId= c2.club_Id)
 and current_Timestamp < sm.start_time 


 --for stadium manager
 --b
 go
 create procedure managerStadiumInfo
 @user varchar(20)
 as
 select s.*
 from StadiumManager m
 inner join Stadium s
 on m.Stadium_Id=s.Id
 where m.username=@user

 go
 --c
 create procedure requestsForMe
 @user varchar(20)
 as
 select cr.Name, c.Name Host, gu.Name Guest,sm.start_time, sm.end_time, r.Status
 from StadiumManager m
 inner join HostRequest r
 on m.Id=r.manager_Id
 inner join ClubRepresentative cr
 on r.representative_Id=cr.Id
 inner join Club c
 on cr.Club_Id=c.club_Id
 inner join Match sm
 on r.match_Id=sm.match_Id
 inner join Club gu
 on sm.guest_club_Id=gu.club_Id
 where m.username=@user
 go


 --for fan 
 --b
 create procedure availableMatchToAttend
 @starting datetime
 as
select distinct c1.Name Host, c2.Name Guest, st.Name Stadium, st.Location Stad_Location
from Match s inner join Club c1 on ( c1.club_Id = s.host_club_Id)
inner join Club c2 on(c2.club_Id = s.guest_club_Id) 
inner join Stadium st on ( st.Id = s.stadium_Id) 
inner join Ticket t on ( t.match_Id = s.match_Id)
where t.Status= 1 
	  And @starting < s.start_time 


go
create procedure purchaseTicketUser
@user varchar(20),
@hostName varchar(20),
@guestName varchar(20),
@startTime datetime
as
declare @Fstatus bit
select @Fstatus=Status
from Fan 
where username=@user
if @Fstatus=1
begin
declare @matchId int
declare @hostId int 
declare @guestId int
declare @natId varchar(20)

select @natId=NationalID
from Fan 
where username=@user

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

select @matchId=m.match_Id
from Match m
where @guestId=m.guest_club_Id and 
	  @hostId=m.host_club_Id and 
	  m.start_time=@startTime;

if exists (select * from Ticket where @matchId=match_Id and Status=1)
begin
declare @ticketId as int=(select top 1 t.Id
					  from Ticket t
					  where t.match_Id=@matchId and Status=1)

update Ticket set Status=0 where @ticketId=Id

insert into TicketBuyingTransactions values (@natId,@ticketId)
end
end
go

create procedure checkNatId
@natId int, 
@flag int output
as
if exists(select * from Fan where @natId=NationalID)
begin 
set @flag=1
end
else 
begin
set @flag=0
end
return

go
create procedure checkUsername
@user varchar(20), 
@flag int output
as
if exists(select * from SystemUser where @user=username) 
set @flag=0
else 
set @flag=1
return

go
create procedure checkClub
@CName varchar(20),
@flag int output
as
if exists(select * from Club where Name=@CName)
set @flag=1
else 
set @flag=0
return

go
create procedure checkStadium
@SName varchar(20), 
@flag int output
as
if exists(select * from Stadium where @SName=Name)
set @flag=1
else 
set @flag=0
return

go
create procedure acceptReq2
@RId int 
as
declare @StId int
declare @MId int
declare @capacity int
declare @hostName varchar(20)
declare @guestName varchar(20)
declare @start_time datetime

update HostRequest set Status=1 where Id=@RId
select @MId=m.match_Id, @StId=s.Id, @capacity=s.Capacity, @start_time=m.start_time, @hostName=h.Name, @guestName=g.Name
from Match m
inner join HostRequest req
on req.match_Id=m.match_Id
inner join StadiumManager mgr
on req.manager_Id=mgr.Id
inner join Stadium s 
on mgr.Stadium_Id=s.Id
inner join Club h
on m.host_club_Id=h.club_Id
inner join Club g
on g.club_Id=m.guest_club_Id
where req.Id=@RId

update Match
set stadium_Id=@StId
where match_Id=@MId

DECLARE @i INT 
SET @i=1
WHILE ( @i <=@capacity )
BEGIN
    exec addTicket @hostName, @guestName, @start_time
    SET @i  = @i  + 1
END


go
create procedure rejectReq2
@RId int 
as
update HostRequest set Status=0 where Id=@RId

go

create procedure checkTicket 
@hostName varchar(20),
@guestName varchar(20), 
@startTime datetime,
@flag int output
as
declare @matchId int
declare @hostId int 
declare @guestId int
declare @natId varchar(20)

select @hostId=c.club_Id
from Club c
where c.Name=@hostName;

select @guestId=c.club_Id
from Club c
where c.Name=@guestName;

select @matchId=m.match_Id
from Match m
where @guestId=m.guest_club_Id and 
	  @hostId=m.host_club_Id and 
	  m.start_time=@startTime;
if exists(select * from Ticket t where @matchId=t.match_Id and t.Status=1)
set @flag=1
else 
set @flag=0

return
go
