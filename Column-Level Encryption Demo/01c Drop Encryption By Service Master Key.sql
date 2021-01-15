USE DaveTest;
GO

--Original Server
--As before, we can open the symmetric without a password.
OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

CLOSE SYMMETRIC KEY CustomerSmtpKey;

/*********************************************************/
--Disable the automatic decryption of the database master key.
ALTER MASTER KEY DROP ENCRYPTION BY SERVICE MASTER KEY; 

--The symmetric key fails to open.
OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

/*
	Password now required to open/decrypt the database master key.
*/

--Password required to open DMK.
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';

OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

CLOSE SYMMETRIC KEY CustomerSmtpKey;

CLOSE MASTER KEY;
