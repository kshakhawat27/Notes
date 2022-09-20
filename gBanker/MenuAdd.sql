
DECLARE @ParentId INT=0;
--Mapping forms
SET @ParentId=(SELECT TOP 1 AspNetSecurityModuleId FROM [dbo].[AspNetSecurityModule] WHERE LinkText='Mapping')

IF NOT Exists(SELECT *FROM [dbo].[AspNetSecurityModule] WHERE LinkText='POMIS3 Employment Report')
BEGIN
	INSERT INTO [dbo].[AspNetSecurityModule]
	SELECT  'OLRS-EMPM','POMIS3 Employment Report','GroupwiseReport','POMIS3_Employment',	@ParentId,1,1,8 ,3 
END