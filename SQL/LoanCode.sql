--select * from [pksf].[POLoanCode]

DECLARE @INIT INT =61, @COLUMN NVARCHAR(10) ='',@LOANCODE NVARCHAR(10) ='';

WHILE(@INIT<=100)
BEGIN
	SET @COLUMN=CAST(@INIT AS NVARCHAR(100));
	SET @LOANCODE=CASE WHEN LEN(@COLUMN)=2 THEN 'loan_0'+@COLUMN ELSE 'loan_'+@COLUMN END;

	EXEC (
	'INSERT INTO [pksf].[POLoanCode]
           ([LoanCode]
           ,[AssociatedLoanCode]
           ,[FunctionalitiesAndFeatures]
           ,[IsEnabled_SC_PRA_MN_IMP_COST_LN_SC]
           ,[IsEnabled_CAL_PRA_MN_IMP_COST_LN_SC]
           ,[IsEnabled_TTL_PRA_MN_IMP_COST_LN_SC]
           ,[IsEnabled_LN_CAL_PRA_MN_IMP_COST_LN_SC]
           ,[AssociatedAccCodeFA]
           ,[AssociatedAccCodeSCP]
           ,[IsActive]
           ,[CreateUser]
           ,[CreateDate]
           ,[UpdateUser]
           ,[UpdateDate])
     VALUES
           ('''+@LOANCODE+'''
           ,NULL
           ,'''+@LOANCODE+'''
           ,1
           ,0
           ,0
           ,0
           ,NULL
           ,NULL
           ,1
           ,''1''
           ,GETDATE()
           ,NULL
           ,NULL)'
	);
		
	SET @INIT=@INIT+1;
END
