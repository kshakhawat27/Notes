GO
/****** Object:  StoredProcedure [dbo].[LoanSummary_Get_Employment_List_By_Filter]    Script Date: 1/9/2023 4:50:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec LoanSummary_Get_Employment_List_By_Filter 67,94,'01 Sep 2022','30 Sep 2022'
-- =============================================
-- Author:		Kazi Shakhawat Hossain
-- Create date: 05-Sep-2022
-- Description:	Get Employments
-- EXEC [dbo].[LoanSummary_Get_Employment_List_By_Filter]  29,39,'01-Jul-2022' , '31-Aug-2022'
-- =============================================
ALTER PROCEDURE [dbo].[LoanSummary_Get_Employment_List_By_Filter] 
    @OfficeId Nvarchar(50),
	@OrgId bigInt,
	@FromDate DATE,
	@ToDate DATE
AS
BEGIN


	SET NOCOUNT ON; 

	DECLARE @OrgName NVARCHAR(150), @OfficeName NVARCHAR(150) ,@OrgLogo varbinary(MAX),@OfficeLevel int,@OfficeCode varchar(10);
	Declare @Office Table(OfficeId int)
	select @OfficeLevel=OfficeLevel ,@OfficeCode=OfficeCode from Office where OfficeID=@OfficeId

	if(@OfficeLevel=1)
	Begin
		Insert into @Office
		Select OfficeID from Office where OfficeLevel=4
	End
	else if(@OfficeLevel=2)
	Begin
		Insert into @Office
		Select OfficeID from Office where OfficeLevel=4 and SecondLevel=@OfficeCode
	End
		else if(@OfficeLevel=3)
	Begin
		Insert into @Office
		Select OfficeID from Office where OfficeLevel=4 and ThirdLevel=@OfficeCode
	End
	else
	Begin
		Insert into @Office
		Select OfficeID from Office where OfficeLevel=4 and OfficeID=@OfficeId
	end
	--GET ORG INFO
	BEGIN
		SELECT 
			@OrgName= OrganizationName,
			@OrgLogo=OrgLOGO
		FROM dbo.Organization where OrgID=@OrgId; 
	END;

	--GET OFFICE INFO
	BEGIN
		SELECT 
			@OfficeName= OfficeName
		FROM dbo.Office where OfficeID=@OfficeId; 
	END;

	drop table if exists #TmpEmployment;
	
	create table #TmpEmployment
	(		
		Report_Type nvarchar(20),
		Report_Type_Name nvarchar(MAX),
		Component nvarchar(10),
		Loan_Products_Name nvarchar(200),
		No_Of_Loanee INT,

		--Self empoyeement full time
		SEmpMaleFullTimeP1 numeric(18,2)  null default 0 ,
		SEmpFeMaleFullTimeP1 numeric(18,2)  null default 0 , 

		--Self empoyeement part time
		SEmpMalePartTimeP1  numeric(18,2)  null default 0 ,
		SEmpFeMalePartTimeP1  numeric(18,2)  null default 0 ,

		--Wage Based Full
		WEmpMaleFullTimeP3  numeric(18,2)  null default 0 ,
		WEmpFeMaleFullTimeP3  numeric(18,2)  null default 0 ,

		--Wage Based Parttime
		WEmpMalePartTimeP3 numeric(18,2)  null default 0 ,
		WEmpFeMalePartTimeP3 numeric(18,2)  null default 0 ,

		--Total
		Total_FullTime numeric(18,2)  null default 0 ,
		Total_PartTime numeric(18,2)  null default 0 
	);

	--------------------------Report Type: Part A ---------------------------------------

	--get result using agrosor, jagoron, buniad
	BEGIN
		--current loan before from date
		insert into #TmpEmployment
		SELECT 
		'A' AS Report_Type,
		'Total Employment In Past Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		pm.EmploymentProductName AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		inner join dbo.ProductXEmploymentProductMapping pm on pm.MainProductCode=pt.MainProductCode
		where ls.LoanStatus=1 and (ls.DisburseDate < @FromDate) 
		and ls.OfficeID in(select OfficeId from @Office)
		AND pm.EmploymentProductName IN ('Agrosor','Jagoron','Buniad') 
		group by pm.EmploymentProductName	
		order by pm.EmploymentProductName	

		--current loan after from date
		insert into #TmpEmployment
		SELECT 
		'A' AS Report_Type,
		'Total Employment In Past Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		pm.EmploymentProductName AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		inner join dbo.ProductXEmploymentProductMapping pm on pm.MainProductCode=pt.MainProductCode
		where ls.LoanStatus=0 and (ls.DisburseDate < @FromDate) 
		and ls.OfficeID in(select OfficeId from @Office)
		and (ls.LoanCloseDate BETWEEN @FromDate and @ToDate)
		AND pm.EmploymentProductName IN ('Agrosor','Jagoron','Buniad') 
		group by pm.EmploymentProductName	
		order by pm.EmploymentProductName
	END;

	--get result using Except agrosor, jagoron, buniad
	BEGIN
		--current loan before from date
		insert into #TmpEmployment
		SELECT 
		'A' AS Report_Type,
		'Total Employment In Past Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		'Others' AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		where ls.LoanStatus=1 and (ls.DisburseDate < @FromDate) and ls.OfficeID in(select OfficeId from @Office)
		AND pt.MainProductCode NOT IN (SELECT pm.MainProductCode FROM dbo.ProductXEmploymentProductMapping pm) 
		

		--current loan after from date
		insert into #TmpEmployment
		SELECT 
		'A' AS Report_Type,
		'Total Employment In Past Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		'Others' AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,		

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		where ls.LoanStatus=0 and (ls.DisburseDate < @FromDate) 
		and ls.OfficeID  in(select OfficeId from @Office)
		and (ls.LoanCloseDate BETWEEN @FromDate and @ToDate)
		AND pt.MainProductCode NOT IN (SELECT pm.MainProductCode FROM dbo.ProductXEmploymentProductMapping pm)

	END;

	--------------------------Report Type: Part B ---------------------------------------
	--get result using agrosor, jagoron, buniad
	BEGIN
		--current loan before from date
		insert into #TmpEmployment
		SELECT 
		'B' AS Report_Type,
		'Continues Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		pm.EmploymentProductName AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		inner join dbo.ProductXEmploymentProductMapping pm on pm.MainProductCode=pt.MainProductCode
		where ls.LoanStatus=1 and (ls.DisburseDate < @FromDate)		
		and ls.OfficeID in (select OfficeId from @Office)
		AND pm.EmploymentProductName IN ('Agrosor','Jagoron','Buniad') 
		group by pm.EmploymentProductName	
		order by pm.EmploymentProductName	
	END;

	--get result using Except agrosor, jagoron, buniad
	BEGIN
		--current loan before from date
		insert into #TmpEmployment
		SELECT 
		'B' AS Report_Type,
		'Continues Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		'Others' AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID 
		and ls.OfficeID  in(select OfficeId from @Office)
		where ls.LoanStatus=1 and (ls.DisburseDate < @FromDate)
		AND pt.MainProductCode NOT IN (SELECT pm.MainProductCode FROM dbo.ProductXEmploymentProductMapping pm) 
		
	END;

	--------------------------Report Type: Part C ---------------------------------------
	BEGIN
		--disburse in this duration for jagoron buniad agrosor
		insert into #TmpEmployment
		SELECT 
		'C' AS Report_Type,
		'New Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		pm.EmploymentProductName AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		inner join dbo.ProductXEmploymentProductMapping pm on pm.MainProductCode=pt.MainProductCode
		where ls.LoanStatus=1 and (ls.DisburseDate BETWEEN @FromDate and @ToDate)
		and ls.OfficeID  in(select OfficeId from @Office)
		AND pm.EmploymentProductName IN ('Agrosor','Jagoron','Buniad') 
		group by pm.EmploymentProductName	
		order by pm.EmploymentProductName
		
		--disburse in this duration except jagoron buniad agrosor
		insert into #TmpEmployment
		SELECT 
		'C' AS Report_Type,
		'New Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		'Others' AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		where ls.LoanStatus=1 and (ls.DisburseDate BETWEEN @FromDate and @ToDate) 
		and ls.OfficeID  in(select OfficeId from @Office)		
		AND pt.MainProductCode NOT IN (SELECT pm.MainProductCode FROM dbo.ProductXEmploymentProductMapping pm)	
	END;

	--------------------------Report Type: Part D ---------------------------------------
	BEGIN
		--disburse in this duration for jagoron buniad agrosor
		insert into #TmpEmployment
		SELECT 
		'D' AS Report_Type,
		'Total Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		pm.EmploymentProductName AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID
		inner join dbo.ProductXEmploymentProductMapping pm on pm.MainProductCode=pt.MainProductCode
		where ls.LoanStatus=1 and (ls.DisburseDate is not null)	and ls.OfficeID in(select OfficeId	from @Office)
		AND pm.EmploymentProductName IN ('Agrosor','Jagoron','Buniad') 
		group by pm.EmploymentProductName	
		order by pm.EmploymentProductName
		
		--disburse in this duration except jagoron buniad agrosor
		insert into #TmpEmployment
		SELECT 
		'D' AS Report_Type,
		'Total Employment In Present Half Year' AS Report_Type_Name,
		'PKSF' AS Component,
		'Others' AS Loan_Products_Name,
		COUNT(Distinct ls.MemberID) AS No_Of_Loanee,

		--Self empoyeement full time
		SUM(ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) AS SEmpMaleFullTimeP1,
		SUM(ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) AS SEmpFeMaleFullTimeP1, 

		--Self empoyeement part time
		SUM(ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) AS SEmpMalePartTimeP1,
		SUM(ISNULL(ed.SEmpFeMalePartTimeP1,0)+ ISNULL(ed.FEmpFeMalePartTimeP2,0)) AS SEmpFeMalePartTimeP1,

		--Wage Based Full
		SUM(ISNULL(ed.WEmpMaleFullTimeP3,0)) AS WEmpMaleFullTimeP3,
		SUM(ISNULL(ed.WEmpFeMaleFullTimeP3,0)) AS WEmpFeMaleFullTimeP3,

		--Wage Based Parttime
		SUM(ISNULL(ed.WEmpMalePartTimeP3,0)),
		SUM(ISNULL(ed.WEmpFeMalePartTimeP3,0)),

		--Total
		SUM((ISNULL(ed.SEmpMaleFullTimeP1,0)+ISNULL(ed.FEmpMaleFullTimeP2,0)) + (ISNULL(ed.SEmpFeMaleFullTimeP1,0)+ISNULL(ed.FEmpFeMaleFullTimeP2,0)) + (ISNULL(ed.WEmpMaleFullTimeP3,0) + ISNULL(ed.WEmpFeMaleFullTimeP3,0))) AS Total_FullTime,
		SUM((ISNULL(ed.SEmpMalePartTimeP1,0) + ISNULL(ed.FEmpMalePartTimeP2,0)) + (ISNULL(ed.SEmpFeMalePartTimeP1,0) + ISNULL(ed.FEmpFeMalePartTimeP2,0)) + (ISNULL(ed.WEmpMalePartTimeP3,0)+ ISNULL(ed.WEmpFeMalePartTimeP3,0))) AS Total_PartTime

		from dbo.LoanSummary ls 
		inner join dbo.Product pt on pt.ProductID=ls.ProductID
		inner join dbo.EmploymentDetails ed on ed.LoanSummaryID=ls.LoanSummaryID 
		and ls.OfficeID  in(select OfficeId from @Office)
		where ls.LoanStatus=1 and (ls.DisburseDate is not null)		
		AND pt.MainProductCode NOT IN (SELECT pm.MainProductCode FROM dbo.ProductXEmploymentProductMapping pm)	
	END;
	
	BEGIN
		SELECT
			@OrgName AS OrgName,
			@OrgLogo as OrgLogo,
			@OfficeName  AS OfficeName,
			Report_Type,
			Report_Type_Name,
			Component ,
			Loan_Products_Name ,
			SUM(isnull(No_Of_Loanee,0)) AS No_Of_Loanee,
			--Self empoyeement full time
			SUM(isnull(SEmpMaleFullTimeP1,0)) SEmpMaleFullTimeP1 ,
			SUM(isnull(SEmpFeMaleFullTimeP1,0)) SEmpFeMaleFullTimeP1, 

			--Self empoyeement part time
			sum(isnull(SEmpMalePartTimeP1,0) ) SEmpMalePartTimeP1,
			sum(SEmpFeMalePartTimeP1)  SEmpFeMalePartTimeP1,

			--Wage Based Full
			sum(isnull(WEmpMaleFullTimeP3,0) ) WEmpMaleFullTimeP3,
			sum(isnull(WEmpFeMaleFullTimeP3,0))  WEmpFeMaleFullTimeP3,

			--Wage Based Parttime
			sum(isnull(WEmpMalePartTimeP3,0))  WEmpMalePartTimeP3,
			sum(isnull(WEmpFeMalePartTimeP3,0)) WEmpFeMalePartTimeP3,

			--Total
			SUM(isnull(Total_FullTime,0)) Total_FullTime,
			SUM(isnull(Total_PartTime,0)) Total_PartTime
		FROM #TmpEmployment temp
		LEFT JOIN dbo.ProductXEmploymentProductMapping pm on temp.Loan_Products_Name=pm.EmploymentProductName 
		GROUP BY Report_Type,Report_Type_Name,Component,Loan_Products_Name,pm.DisplayOrder
		order by Pm.DisplayOrder


	END;

END
