USE [gHRMPlus_V3_Live_GC_Latest]
GO
/****** Object:  StoredProcedure [basic].[SP_GetOfficeInfo]    Script Date: 2/8/2022 5:03:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [basic].[SP_GetOfficeInfo]
(
	@AndCondition NVARCHAR(MAX)
)
	
AS
BEGIN
	DECLARE 
	@SQL NVARCHAR(MAX),
	@ParamDefinition AS NVarchar(2000) 

SET @SQL=N'		
		SELECT CONVERT(VARCHAR(10),ROW_NUMBER() Over (Order by (SELECT 1))) AS rowSl,
				o.OfficeId,
				o.OfficeTypeId,
				ot.OfficeTypeName,
				o.OfficeCode,
				o.OfficeName,
				o.OfficeNameBn,
				o.OfficeAddress,
				o.Phone,
				CONVERT(varchar, o.OperationStartDate, 103) AS OperationStartDate
FROM Office o
INNER JOIN OfficeType ot ON o.OfficeTypeId = ot.OfficeTypeId 
WHERE o.IsActive=1'
SET @SQL = @SQL + ' ' + @AndCondition+'ORDER BY o.OfficeTypeId'

SET @ParamDefinition = ' @AndCondition NVARCHAR(2000)';	 

EXEC sp_executesql @SQL, @ParamDefinition,@AndCondition;
END

/*
exec SP_GetOfficeInfo ' AND '
*/
