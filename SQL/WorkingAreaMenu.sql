GO
DECLARE @ParentId INT=0;
--Mapping forms
SET @ParentId=(SELECT TOP 1 AspNetSecurityModuleId FROM [dbo].[AspNetSecurityModule] WHERE LinkText='PKSF')

IF NOT Exists(SELECT *FROM [dbo].[AspNetSecurityModule] WHERE LinkText='Working Area Report')
BEGIN
	INSERT INTO [dbo].[AspNetSecurityModule]
	SELECT  'OLRS-WA','Working Area Report','GroupwiseReport','GenerateWorkingArea',	@ParentId,1,1,14 ,3 
END

GO