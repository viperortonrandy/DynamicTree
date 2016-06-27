USE [welcomgroup]
GO

/****** Object:  StoredProcedure [hotels].[SP_InsertReservationDetails]    Script Date: 06/27/2016 20:45:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[hotels].[SP_InsertReservationDetails]') AND type in (N'P', N'PC'))
DROP PROCEDURE [hotels].[SP_InsertReservationDetails]
GO

USE [welcomgroup]
GO

/****** Object:  StoredProcedure [hotels].[SP_InsertReservationDetails]    Script Date: 06/27/2016 20:45:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Naveen
-- Description : Inserting Reservation detail and preferences details 
-- Create date: <01-07-2016>
-- =============================================
CREATE PROCEDURE [hotels].[SP_InsertReservationDetails]
@guestId bigint,
@bookingStatus varchar(50),
@hotelName varchar(50),
@hotelAddress1 varchar(100),
@hotelAddress2 varchar(100),
@hotelContact varchar(100),
@hotelId numeric(18,0),
@roomId numeric(18,0),
@roomName varchar(50),
@planId numeric(18,0),
@planName varchar(100),
@checkInDate varchar(20),
@checkOutDate varchar(20),
@durationOfStay numeric(18,0),
@noOfRooms numeric(10,0),
@noOfAdults numeric(10,0),
@noOfChildren numeric(10,0),
@ratePlanName varchar(100),
@guestTitle varchar(100),
@guestFName varchar(100),
@guestLName varchar(100),
@guestAddress1 varchar(100),
@guestAddress2 varchar(100),
@guestPhoneNumber varchar(20),
@guestEmailId varchar(50),
@totalAmount numeric(18,2),
@amountPaid numeric(18,2),
@balanceAmount numeric(18,2),
@totalPoints numeric(18,0),
@totalPointsDeducted numeric(18,0),
@luxuryTax numeric(10,2),
@serviceTax numeric(10,2),
@vat numeric(10,2),
@totalTax numeric(18,2),
@prn varchar(100),
@bid varchar(100),
@pid varchar(100),
@txnDate varchar(20),
@hotelType varchar(50),
@chainCode varchar(20),
@flightNumberArrival varchar(30),
@arrivalTime smalldatetime,
@airportNameArrival varchar(70),
@flightNumberDeparture varchar(30),
@departureTime smalldatetime,
@airportNameDeparture varchar(70),
@owsConfirmationId varchar(50),
@profileId varchar(50),
@smoking varchar(15),
@nonSmoking varchar(15),
@interConnectRooms varchar(15),
@higherFloor varchar(15),
@lowerFloor varchar(15),
@earlyArrival varchar(15),
@earlyArrTime varchar(20),
@lateArrival varchar(15),
@lateArrTime varchar(20),
@additionalRequest varchar(1000),
@hotelEmail varchar(50),
@fbHandle varchar(50),
@twHandle varchar(50),
@instaHandle varchar(50),
@guest_country varchar(50),
@guest_state varchar(50),
@guest_city varchar(50),
@guest_pincode varchar(50),
@guest_company varchar(50),
@userType varchar(20),
@hotelCode varchar(25),
@roomTypeCode varchar(25),
@ratePlanCode varchar(25),
@hotelPath varchar(500),
@amountDetails varchar(4000),
@planType varchar(20),
@cancellablePlan varchar(10),
@cancellationTime datetime,
@loginId varchar(50),
@generatedKey int output

AS
BEGIN
	Declare @tempId numeric(18,0) 
	
	
    INSERT INTO [welcomgroup].[dbo].[ReservationDetails]
           ([Guest_Id],[Booking_Status],[Hotel_Name],[Hotel_Address1],[Hotel_Address2]
           ,[Hotel_Contact],[Hotel_Id],[Room_Id] ,[Room_Name],[Plan_Id],[Plan_Name]
           ,[Checkin_Date],[Checkout_Date],[Duration_Of_Stay],[Number_Of_Rooms]
           ,[Number_Of_Adults],[Number_Of_Childrens],[Rate_Plan_Name],[Guest_Title]
           ,[Guest_First_Name],[Guest_Last_Name],[Guest_Address1],[Guest_Address2]
           ,[Guest_Phone_Number],[Guest_Email_Id],[Total_Amount],[Amount_Paid]
           ,[Balance_Amount],[Total_Points],[Total_Points_Deducted],[Luxury_Tax]
           ,[Service_Tax],[Vat],[Total_Tax],[PRN],[BID],[PID],[Txn_Date],[hotel_type],[created_time],[Flight_Number_Arrival],
           [Arrival_Time],[Airport_Name_Arrival],[Flight_Number_Departure],[Departure_Time],[Airport_Name_Departure],
		   [OWS_ConfirmationID],[OWS_Profile_ID],[hotel_email],[guest_fbhandle],[guest_twhandle],[guest_instahandle]
		   ,[guest_country],[guest_state],[guest_city],[guest_pincode],[guest_company],[User_Type],[Chain_Code],[Hotel_Code],
		   [Room_Type_Code],[Rate_Plan_Code],[hotel_Path],[is_cancelled],[AmountBreakup],[Plan_Type],[Cancellable_Plan],
		   [Cancellation_Time],[Login_Id])
     VALUES
          (@guestId,@bookingStatus,@hotelName,@hotelAddress1,@hotelAddress2,@hotelContact,@hotelId,@roomId,
           @roomName,@planId,@planName,@checkInDate,@checkOutDate,@durationOfStay,@noOfRooms,@noOfAdults,
           @noOfChildren,@ratePlanName,@guestTitle,@guestFName,@guestLName,@guestAddress1,@guestAddress2,
           @guestPhoneNumber,@guestEmailId,@totalAmount,@amountPaid,@balanceAmount,@totalPoints,@totalPointsDeducted,
           @luxuryTax,@serviceTax,@vat,@totalTax,@prn,@bid,@pid,@txnDate,@hotelType,GETDATE(),@flightNumberArrival,@arrivalTime,@airportNameArrival,
		   @flightNumberDeparture,@departureTime,@airportNameDeparture,@owsConfirmationId,@profileId,@hotelEmail,@fbHandle,
		   @twHandle,@instaHandle,@guest_country,@guest_state,@guest_city,@guest_pincode,@guest_company,@userType,@chainCode,@hotelCode,@roomTypeCode,
		   @ratePlanCode,@hotelPath,'N',@amountDetails,@planType,@cancellablePlan,@cancellationTime,@loginId)

     SET @tempId = SCOPE_IDENTITY()
        
     INSERT INTO [welcomgroup].[dbo].[r_preferences]
           ([booking_id]
           ,[smoking]
           ,[non_smoking]
           ,[inter_connect_rooms]
           ,[higher_floor]
           ,[lower_floor]
           ,[early_arrival]
           ,[early_arr_time]
           ,[late_arrival]
           ,[late_arr_time]
		   ,[Additional_Request])
     VALUES(@tempId,@smoking,@nonSmoking,@interConnectRooms,
            @higherFloor,@lowerFloor,@earlyArrival,@earlyArrTime,@lateArrival,@lateArrTime,@additionalRequest)
            
     SELECT @generatedKey = @tempId 
              
END











GO


