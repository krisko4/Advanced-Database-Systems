DROP SECURITY POLICY StudentPrivacyPolicy
GO
DROP FUNCTION dbo.fn_StudentsSecurity
GO

CREATE FUNCTION dbo.fn_StudentsSecurity(@user_id AS SMALLINT)
    RETURNS TABLE
WITH SCHEMABINDING
AS
     RETURN SELECT 1 AS fn_StudentsSecurity_Result
      WHERE @user_id=USER_ID() OR USER_ID()=1
GO

CREATE SECURITY POLICY StudentPrivacyPolicy
ADD FILTER PREDICATE
dbo.fn_StudentsSecurity(user_id) ON dbo.dormitory
WITH (STATE = ON)





