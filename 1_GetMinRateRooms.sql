USE [welcomgroup]
GO

/****** Object:  StoredProcedure [hotels].[SP_GetMinRateRoomsByHotel_new]    Script Date: 06/08/2016 12:03:58 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hotels].[SP_GetMinRateRoomsByHotel_new]') AND type in (N'P', N'PC'))
DROP PROCEDURE [hotels].[SP_GetMinRateRoomsByHotel_new]
GO

USE [welcomgroup]
GO

/****** Object:  StoredProcedure [hotels].[SP_GetMinRateRoomsByHotel_new]    Script Date: 06/08/2016 12:03:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Description:	<To get min rate rooms by hotel >
-- =============================================
CREATE PROCEDURE [hotels].[SP_GetMinRateRoomsByHotel_new]
@hotelId numeric(18,0),
@checkInDate datetime,
@checkOutDate datetime,
@noOfDays int,
@advDays int
AS
BEGIN
	declare @tempCheckInDate datetime
	declare @tempCheckOutDate datetime
	Declare @planCheckInDate datetime
	Declare @planCheckOutDate datetime
	Declare @planCount numeric(5,0)
	set @planCheckInDate = convert(DATE,@checkInDate)
	set @planCheckOutDate = convert(DATE,@checkOutDate)
	set @tempCheckInDate = convert(DATE,@checkInDate)
	
	-- new
	Select @planCount = count(distinct rate_code) from b_ratecategory brc inner join
	b_ratecategory_date brd on brc.id_ratecategory = brd.id_ratecategory_date where brc.id_hotel = @hotelId
	and CONVERT(DATE,brd.Date_planstatus) between
	@planCheckInDate and @planCheckOutDate and brd.Flg_openstatus = 'O'
	-- end
	    
	if(@noOfDays > 7)
	begin
	   set @tempCheckOutDate = DATEADD(DAY,7,@checkInDate)
	end
	else
	begin
	   set @tempCheckOutDate = @checkOutDate
	end
	
	-- temp table to store dependent plan rates
	CREATE TABLE #temp_dependent_plans
	(
	 id_plan numeric(18,0),id_room numeric(18,0),DiscountSign varchar(1),DiscountValue numeric(18,2),DiscountType varchar(1),
     Flg_avlday1 char(1),Flg_avlday2 char(1),Flg_avlday3 char(1),Flg_avlday4 char(1),Flg_avlday5 char(1),
     Flg_avlday6 char(1),Flg_avlday7 char(1),Flg_arrday1 char(1),Flg_arrday2 char(1),Flg_arrday3 char(1),
     Flg_arrday4 char(1),Flg_arrday5 char(1),Flg_arrday6 char(1),Flg_arrday7 char(1),date_startocc datetime,
     date_endocc datetime 
	)

    while(@checkInDate < @checkOutDate)
        begin
            INSERT INTO #temp_dependent_plans
            (id_plan,id_room,DiscountSign,DiscountValue,DiscountType,
			 Flg_avlday1,Flg_avlday2,Flg_avlday3,Flg_avlday4,Flg_avlday5,
			 Flg_avlday6,Flg_avlday7,Flg_arrday1,Flg_arrday2,Flg_arrday3,
			 Flg_arrday4,Flg_arrday5,Flg_arrday6,Flg_arrday7,bpr.date_startocc,bpr.date_endocc)
			 Select bp.id_plan,bpr.id_room,bp.DiscountSign,bp.DiscountValue,bp.DiscountType,Flg_avlday1,Flg_avlday2,Flg_avlday3,
			 Flg_avlday4,Flg_avlday5,Flg_avlday6,Flg_avlday7,Flg_arrday1,Flg_arrday2,Flg_arrday3,Flg_arrday4,
			 Flg_arrday5,Flg_arrday6,Flg_arrday7,bpr.date_startocc,bpr.date_endocc 
			 from b_plan bp inner join b_plan_rate bpr on bp.id_plan=bpr.id_plan and bp.id_hotel=bpr.id_hotel
			 inner join b_planstatus bps on bp.id_plan = bps.id_plan and bp.id_hotel=bps.id_hotel
			 inner join b_hotelstatus bhs on bp.id_hotel = bhs.id_hotel
			 where bp.id_hotel=@hotelId and bpr.date_startocc <= @planCheckInDate and bpr.date_endocc >= @planCheckOutDate
			 and bhs.flg_openStatus = 'O' and convert(DATE,bhs.date_hotelStatus) = convert(DATE,@checkInDate) 
			 and bp.Flg_del = 'N' and bp.soft_delete = 'N' and bp.DiscountValue is not null and bps.Flg_openstatus = 'O'
			 and Convert(DATE,bps.Date_planstatus) = Convert(DATE,@checkInDate)
			 
			 set @checkInDate = DATEADD(day,1,@checkInDate)  
        end
        
        set @checkInDate = @tempCheckInDate
        
    -- temp table to store plans which are having rate_code : 'NONE'
    CREATE TABLE #temp_room_rates
	(
	 curr_date varchar(20),Id_room numeric(18,0),Desc_room varchar(50),text_content1 varchar(8000),No_priority int,
	 bed_type varchar(50),location varchar(100),size varchar(50),DepositType char(1),DepositValue int,CancelType char(1),
	 CancelValue int,CancelDays int,CancelTime varchar(5),flg_breakfast char(1),flg_wifi char(1),flg_one_major_meals char(1),
	 flg_spa_treatment char(1),flg_two_major_meals char(1),
	 amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),amt_rspaxex numeric(18,2),
	 Flg_avlday1 char(1),Flg_avlday2 char(1),Flg_avlday3 char(1),Flg_avlday4 char(1),Flg_avlday5 char(1),
	 Flg_avlday6 char(1),Flg_avlday7 char(1),Flg_arrday1 char(1),Flg_arrday2 char(1),Flg_arrday3 char(1),
	 Flg_arrday4 char(1),Flg_arrday5 char(1),Flg_arrday6 char(1),Flg_arrday7 char(1),id_plan numeric(18,0),
	 No_avail int,fileloc_image1 varchar(200),redemptionType char(1),points numeric(18,0)
	)
	
	-- temp table to store independent plan rates
	CREATE TABLE #temp_ind_room_rates
	(
	 curr_date varchar(20),Id_room numeric(18,0),Desc_room varchar(50),text_content1 varchar(8000),No_priority int,
	 bed_type varchar(50),location varchar(100),size varchar(50),DepositType char(1),DepositValue int,CancelType char(1),
	 CancelValue int,CancelDays int,CancelTime varchar(5),flg_breakfast char(1),flg_wifi char(1),flg_one_major_meals char(1),
	 flg_spa_treatment char(1),flg_two_major_meals char(1),
	 amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),amt_rspaxex numeric(18,2),
	 Flg_avlday1 char(1),Flg_avlday2 char(1),Flg_avlday3 char(1),Flg_avlday4 char(1),Flg_avlday5 char(1),
	 Flg_avlday6 char(1),Flg_avlday7 char(1),Flg_arrday1 char(1),Flg_arrday2 char(1),Flg_arrday3 char(1),
	 Flg_arrday4 char(1),Flg_arrday5 char(1),Flg_arrday6 char(1),Flg_arrday7 char(1),id_plan numeric(18,0),
	 No_avail int,fileloc_image1 varchar(200),redemptionType char(1),points numeric(18,0)
	)
	while(@checkInDate < @checkOutDate)
    begin
		INSERT INTO #temp_room_rates
		(
		 curr_date,Id_room,Desc_room,text_content1,No_priority,
		 bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,amt_rspax1,amt_rspax2,amt_rspaxex,
		 Flg_avlday1,Flg_avlday2,Flg_avlday3,Flg_avlday4,Flg_avlday5,
		 Flg_avlday6,Flg_avlday7,Flg_arrday1,Flg_arrday2,Flg_arrday3,
		 Flg_arrday4,Flg_arrday5,Flg_arrday6,Flg_arrday7,id_plan,No_avail,fileloc_image1,
		 redemptionType,points
		)
		select convert(DATE,@checkInDate),br.Id_room,br.Desc_room, br.text_content1, br.No_priority,
		br.bed_type, br.location,br.size, bp.DepositType, bp.DepositValue, bp.CancelType, 
		bp.CancelValue,bp.CancelDays, bp.CancelTime,bp.flg_breakfast,bp.flg_wifi,bp.flg_one_major_meals,
	    bp.flg_spa_treatment,bp.flg_two_major_meals
	    ,case when bpr.amt_rspax1=0 and bp.redemptionType = 'F' then bpr.points else bpr.amt_rspax1 end as amt_rspax1
	    ,case when bpr.amt_rspax2=0 and bp.redemptionType = 'F' then bpr.points else bpr.amt_rspax2 end as amt_rspax2
	    ,bpr.amt_rspaxex,
		bp.Flg_avlday1,bp.Flg_avlday2,bp.Flg_avlday3,bp.Flg_avlday4,bp.Flg_avlday5,
		bp.Flg_avlday6,bp.Flg_avlday7,bp.Flg_arrday1,bp.Flg_arrday2,bp.Flg_arrday3,
		bp.Flg_arrday4,bp.Flg_arrday5,bp.Flg_arrday6,bp.Flg_arrday7,bp.id_plan,
		bravail.No_avail,br.fileloc_image1,bp.redemptionType,bpr.points
		from dbo.b_room br inner join dbo.b_room_avail bravail on br.Id_room=bravail.id_room
		inner join dbo.b_plan_rate bpr on br.Id_room=bpr.id_room 
		inner join dbo.b_plan bp on bpr.id_plan=bp.id_plan  
		where br.id_hotel=@hotelId and CONVERT(DATE,bravail.Date_avail) = CONVERT(DATE,@checkInDate)
		and bravail.Flg_status='O' and bravail.No_avail > 0 and br.flg_sale='Y' 
	    and bpr.ID_plan_rate in (Select distinct bpr2.ID_plan_rate from b_plan_rate bpr2 inner join b_plan bp2 
		on bpr2.id_plan = bp2.id_plan inner join b_planstatus bps on bp2.id_plan = bps.id_plan
		where bp2.id_hotel = @hotelId and UPPER(bp2.rate_code) = 'NONE'
		and @noOfDays between bp2.no_minlos and bp2.no_maxlos and bp2.flg_del = 'N' and bp2.soft_delete='N'
		and (bp2.promo_code is null or bp2.promo_code = '') and bps.Flg_openstatus = 'O' 
		and CONVERT(DATE,bps.Date_planstatus) = CONVERT(DATE,@checkInDate) and bp2.no_advdays <= @advDays
		--and bpr2.date_startocc <= @tempCheckInDate and bpr2.date_endocc >= @checkOutDate
		and bp2.date_sellstart <= @tempCheckInDate 
		and bp2.date_sellend >= @checkOutDate and @checkInDate between bpr2.date_startocc and bpr2.date_endocc
		 ) 
	    order by amt_rspax1,amt_rspax2,amt_rspaxex ASC
	    
		set @checkInDate = DATEADD(day,1,@checkInDate)
    end
    
    set @checkInDate = @tempCheckInDate
    
    -- For Independent
    while(@checkInDate < @checkOutDate)
    begin
		INSERT INTO #temp_ind_room_rates
		(
		 curr_date,Id_room,Desc_room,text_content1,No_priority,
		 bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,amt_rspax1,amt_rspax2,amt_rspaxex,
		 Flg_avlday1,Flg_avlday2,Flg_avlday3,Flg_avlday4,Flg_avlday5,
		 Flg_avlday6,Flg_avlday7,Flg_arrday1,Flg_arrday2,Flg_arrday3,
		 Flg_arrday4,Flg_arrday5,Flg_arrday6,Flg_arrday7,id_plan,No_avail,fileloc_image1,
		 redemptionType,points
		)
				
		select convert(DATE,@checkInDate),br.Id_room,br.Desc_room, br.text_content1, br.No_priority,
		br.bed_type, br.location,br.size, bp.DepositType, bp.DepositValue, bp.CancelType, 
		bp.CancelValue,bp.CancelDays, bp.CancelTime,bp.flg_breakfast,bp.flg_wifi,bp.flg_one_major_meals,
	    bp.flg_spa_treatment,bp.flg_two_major_meals
	    ,case when bpr.amt_rspax1=0 and bp.redemptionType = 'F' then bpr.points else bpr.amt_rspax1 end as amt_rspax1
	    ,case when bpr.amt_rspax2=0 and bp.redemptionType = 'F' then bpr.points else bpr.amt_rspax2 end as amt_rspax2
	    ,bpr.amt_rspaxex,
		bp.Flg_avlday1,bp.Flg_avlday2,bp.Flg_avlday3,bp.Flg_avlday4,bp.Flg_avlday5,
		bp.Flg_avlday6,bp.Flg_avlday7,bp.Flg_arrday1,bp.Flg_arrday2,bp.Flg_arrday3,
		bp.Flg_arrday4,bp.Flg_arrday5,bp.Flg_arrday6,bp.Flg_arrday7,bp.id_plan,
		bravail.No_avail,br.fileloc_image1,bp.redemptionType,bpr.points
		from dbo.b_room br inner join dbo.b_room_avail bravail on br.Id_room=bravail.id_room
		inner join dbo.b_plan_rate bpr on br.Id_room=bpr.id_room 
		inner join dbo.b_plan bp on bpr.id_plan=bp.id_plan  
		where br.id_hotel=@hotelId and CONVERT(DATE,bravail.Date_avail) = CONVERT(DATE,@checkInDate)
		and bravail.Flg_status='O' and bravail.No_avail > 0 and br.flg_sale='Y' 
	    and bpr.ID_plan_rate in (Select distinct ID_plan_rate from b_plan_rate bpr2 inner join b_plan bp2 
		on bpr2.id_plan = bp2.id_plan inner join b_ratecategory brc on bp2.rate_code = brc.rate_code 
		and bp2.id_hotel = brc.id_hotel inner join b_ratecategory_date brd on brc.id_ratecategory = brd.id_ratecategory_date  
		and brc.id_hotel = brd.id_hotel
		inner join b_planstatus bps on bp2.id_plan = bps.id_plan and bp2.id_hotel = bps.id_hotel 
		where bp2.id_hotel = @hotelId and CONVERT(DATE,brd.Date_planstatus) = convert(DATE,@checkInDate) and brd.Flg_openstatus = 'O'
		and @noOfDays between bp2.no_minlos and bp2.no_maxlos and bp2.flg_del = 'N' and bp2.soft_delete='N'
		and (bp2.promo_code is null or bp2.promo_code = '') and bps.Flg_openstatus = 'O' 
		and CONVERT(DATE,bps.Date_planstatus) = CONVERT(DATE,@checkInDate) and bp2.no_advdays <= @advDays
		-- new 
		and ((@planCount=1 and bpr2.date_startocc <= @tempCheckInDate and bpr2.date_endocc >= @checkOutDate) or @planCount>1)
		-- end
		) 
	    order by amt_rspax1,amt_rspax2,amt_rspaxex ASC
	    --end
		set @checkInDate = DATEADD(day,1,@checkInDate)
    end
    
    
    set @checkInDate = @tempCheckInDate
    declare @YFlag varchar(1) = 'Y' 
    declare @columnStr varchar(300)=''
    declare @sql nvarchar(2000)
    declare @depSql nvarchar(2000)
	declare @daystr varchar(20)=''
	declare @arrDayStr varchar(20)=''
	declare @arrDayCol varchar(50)=''
	-- below variables to calculate rate for depedent plans
	declare @amtRsPax1 numeric(18,2)
	declare @amtRsPax2 numeric(18,2)
	declare @amountPax1 numeric(18,2)
	declare @amountPax2 numeric(18,2)
	declare @rowCount int -- variable to store the count of dependent plans
	declare @DiscountSign varchar(1)
	declare @DiscountValue numeric(18,2)
	declare @DiscountType varchar(1)
	declare @roomId numeric(18,0)
	declare @planId numeric(18,0)
	declare @indPlanId numeric(18,0) -- variable to select independent plan id (In case of season: Select checkInDate plan)
	set @arrDayStr = DATENAME(DW,@checkInDate)
	
	
	Select @indPlanId = id_plan from b_plan bp inner join b_ratecategory brc on bp.rate_code=brc.rate_code 
	and bp.id_hotel=brc.id_hotel inner join b_ratecategory_date brd on brc.id_ratecategory=brd.id_ratecategory_date
	and brc.id_hotel=brd.id_hotel where bp.id_hotel=@hotelId and bp.Flg_del='N' and bp.soft_delete='N'
	and brd.Flg_openstatus='O' and brd.Date_planstatus=@checkInDate
	
		if(@arrDayStr = 'Monday')
		begin 
		  set @arrDayCol = 'Flg_arrday1='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Tuesday')
		begin 
		  set @arrDayCol = 'Flg_arrday2='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Wednesday')
		begin 
		  set @arrDayCol = 'Flg_arrday3='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Thursday')
		begin 
		  set @arrDayCol = 'Flg_arrday4='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Friday')
		begin  
		  set @arrDayCol = 'Flg_arrday5='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Saturday')
		begin 
		  set @arrDayCol = 'Flg_arrday6='''+@YFlag+''''
		end
		else if(@arrDayStr = 'Sunday')
		begin 
		  set @arrDayCol = 'Flg_arrday7='''+@YFlag+''''
		end
    
    while(@checkInDate < CONVERT(DATE,@tempCheckOutDate))
    begin
		set @daystr = DATENAME(DW,@checkInDate)
		
		if(@columnStr != '')
		begin
			set @columnStr = @columnStr + ' and '
		end
		if(@daystr = 'Monday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday1='''+@YFlag+''''
		end
		else if(@daystr = 'Tuesday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday2='''+@YFlag+''''
		end
		else if(@daystr = 'Wednesday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday3='''+@YFlag+''''
		end
		else if(@daystr = 'Thursday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday4='''+@YFlag+''''
		end
		else if(@daystr = 'Friday')
		begin  
		  set @columnStr = @columnStr + 'Flg_avlday5='''+@YFlag+''''
		end
		else if(@daystr = 'Saturday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday6='''+@YFlag+''''
		end
		else if(@daystr = 'Sunday')
		begin 
		  set @columnStr = @columnStr + 'Flg_avlday7='''+@YFlag+''''
		end
		
		set @checkInDate = DATEADD(day,1,@checkInDate)
		 
    end
        -- Filtering dependent plans with distinct of id_plan and id_room and also based on available,arrival days
        set @depSql = 'Select distinct id_plan,id_room,DiscountSign,DiscountValue,DiscountType from #temp_dependent_plans where ' +@columnStr+' and '
		+@arrDayCol
		
		CREATE TABLE #temp_final_dependent_plans
        (
         id_plan numeric(18,0),id_room numeric(18,0),DiscountSign varchar(1),DiscountValue numeric(18,2),DiscountType varchar(1)
        )
        INSERT INTO #temp_final_dependent_plans
        execute sp_executesql @depSql
        
        -- To insert row number 
        CREATE TABLE #temp_dependent_row
        (
         num int, id_plan numeric(18,0),id_room numeric(18,0),DiscountSign varchar(1),DiscountValue numeric(18,2),DiscountType varchar(1)
        )
        INSERT INTO #temp_dependent_row
        Select ROW_NUMBER() OVER(ORDER BY id_plan),id_plan,id_room,DiscountSign,DiscountValue,DiscountType from #temp_final_dependent_plans
        
        
         -- Filtering Plans(category NONE) based on available and arrivalday
		 set @sql = 'select amt_rspax1,amt_rspax2,amt_rspaxex,id_room,curr_date,Desc_room,text_content1,
		 No_priority,bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,id_plan,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,No_avail,fileloc_image1,redemptionType,points 
	     from #temp_room_rates where ' +@columnStr+' and '
		 +@arrDayCol
		
	     create table #temp_min_rate_by_dates
	    (amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),amt_rspaxex numeric(18,2),id_room numeric(18,0),
	     curr_date varchar(20),Desc_room varchar(50),text_content1 varchar(8000),No_priority int,
		 bed_type varchar(50),location varchar(100),size varchar(50),DepositType char(1),DepositValue int,CancelType char(1),
		 CancelValue int,CancelDays int,CancelTime varchar(5),id_plan numeric(18,0),flg_breakfast char(1),flg_wifi char(1),flg_one_major_meals char(1),
	     flg_spa_treatment char(1),flg_two_major_meals char(1),No_avail int,fileloc_image1 varchar(200),
	     redemptionType char(1),points numeric(18,0) 
	    )
		
		INSERT INTO #temp_min_rate_by_dates
		(amt_rspax1,amt_rspax2,amt_rspaxex,id_room,curr_date,Desc_room,text_content1,No_priority,
		 bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,id_plan,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,No_avail,fileloc_image1,redemptionType,points) 
	    
	    execute sp_executesql @sql
	    
	    create table #temp_avg_rate_by_room_plan
	    (amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),id_room numeric(18,0),id_plan numeric(18,0)
	    )
		
		INSERT INTO #temp_avg_rate_by_room_plan
		(amt_rspax1,amt_rspax2,id_room,id_plan)
	    Select avg(amt_rspax1),avg(amt_rspax2),id_room,id_plan from #temp_min_rate_by_dates group by id_room,id_plan 
	    
	    --For Independent--
	    declare @indSql nvarchar(4000)
	    set @indSql = 'select amt_rspax1,amt_rspax2,amt_rspaxex,id_room,curr_date,Desc_room,text_content1,
		 No_priority,bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,id_plan,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,No_avail,fileloc_image1,redemptionType,points 
	     from #temp_ind_room_rates where ' +@columnStr+' and '
		+@arrDayCol
		
	    create table #temp_ind_min_rate_by_dates
	    (amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),amt_rspaxex numeric(18,2),id_room numeric(18,0),
	     curr_date varchar(20),Desc_room varchar(50),text_content1 varchar(8000),No_priority int,
		 bed_type varchar(50),location varchar(100),size varchar(50),DepositType char(1),DepositValue int,CancelType char(1),
		 CancelValue int,CancelDays int,CancelTime varchar(5),id_plan numeric(18,0),flg_breakfast char(1),flg_wifi char(1),flg_one_major_meals char(1),
	     flg_spa_treatment char(1),flg_two_major_meals char(1),No_avail int,fileloc_image1 varchar(200),
	     redemptionType char(1),points numeric(18,0) 
	    )
		
		INSERT INTO #temp_ind_min_rate_by_dates
		(amt_rspax1,amt_rspax2,amt_rspaxex,id_room,curr_date,Desc_room,text_content1,No_priority,
		 bed_type,location,size,DepositType,DepositValue,CancelType,
		 CancelValue,CancelDays,CancelTime,id_plan,flg_breakfast,flg_wifi,flg_one_major_meals,
	     flg_spa_treatment,flg_two_major_meals,No_avail,fileloc_image1,redemptionType,points) 
	    
	    execute sp_executesql @indSql
	    
	    Create table #temp_ind_avg_rate_by_room
	    (amt_rspax1 numeric(18,2),amt_rspax2 numeric(18,2),id_room numeric(18,0))
	    
	    INSERT INTO #temp_ind_avg_rate_by_room
		(amt_rspax1,amt_rspax2,id_room)
		Select avg(amt_rspax1),avg(amt_rspax2),id_room from #temp_ind_min_rate_by_dates group by id_room
		 
		Select @rowCount=count(*) from #temp_dependent_row
	    Declare @tempCount int = 1
	    
	    while(@tempCount <= @rowCount)
	    begin
	         Select @DiscountSign=DiscountSign,@DiscountValue=DiscountValue,@DiscountType=DiscountType,@roomId=id_room,
	         @planId=id_plan from #temp_dependent_row where num = @tempCount
	         
	         Select @amtRsPax1=amt_rspax1,@amtRsPax2=amt_rspax2 from #temp_ind_avg_rate_by_room where id_room = @roomId 
	         
	         -- Calculating discount plan rates 
	          IF(@DiscountType = 'P')
				BEGIN
					IF(@DiscountSign = '-')
					begin
						SET @amountPax1 = @amtRsPax1 - (@DiscountValue/100)*@amtRsPax1
						SET @amountPax2 = @amtRsPax2 - (@DiscountValue/100)*@amtRsPax2
						
					END
					ELSE
					BEGIN
						SET @amountPax1 = @amtRsPax1 + (@DiscountValue/100)*@amtRsPax1
						SET @amountPax2 = @amtRsPax2 + (@DiscountValue/100)*@amtRsPax2
						
					END
				END
				ELSE
				BEGIN
					IF(@DiscountSign = '-')
					begin
						SET @amountPax1 = @amtRsPax1 - @DiscountValue
						SET @amountPax2 = @amtRsPax2 - @DiscountValue
						
					END
					ELSE
					BEGIN
						SET @amountPax1 = @amtRsPax1 + @DiscountValue
						SET @amountPax2 = @amtRsPax2 + @DiscountValue
						
					END
				END 
				
			    INSERT INTO #temp_avg_rate_by_room_plan
				(amt_rspax1,amt_rspax2,id_plan,id_room) VALUES				   
		        (@amountPax1,@amountPax2,@planId,@roomId)
		        
	         set @tempCount = @tempCount + 1  
	    end 
	    
	    INSERT INTO #temp_avg_rate_by_room_plan
	    (amt_rspax1,amt_rspax2,id_room)  
	    Select * from #temp_ind_avg_rate_by_room
	    
	    Update #temp_avg_rate_by_room_plan set id_plan=@indPlanId where id_plan is null
	    
	    Select ta.id_room,convert(dec(10,0),round(ta.amt_rspax1,0),0) as amt_rspax1,convert(dec(10,0),round(ta.amt_rspax2,0),0) as amt_rspax2,
	    ta.amt_rspax2 as amt_rspaxex,
	    Desc_room,br.text_content1,br.No_priority,bed_type,location,size,DepositType,DepositValue,CancelType,
		CancelValue,CancelDays,CancelTime,bp.id_plan,flg_breakfast,flg_wifi,flg_one_major_meals,
	    flg_spa_treatment,flg_two_major_meals,bavail.No_avail,fileloc_image1,redemptionType
	    from #temp_avg_rate_by_room_plan ta inner join b_room br on ta.id_room=br.id_room 
	    inner join b_room_avail bavail on br.id_room=bavail.id_room and br.id_hotel=bavail.id_hotel
	    inner join b_plan bp on ta.id_plan=bp.id_plan where bp.id_hotel=@hotelId and bavail.Date_avail between 
	    @planCheckInDate and @planCheckOutDate and bavail.Flg_status='O' order by ta.amt_rspax1 ASC
		
END



GO


