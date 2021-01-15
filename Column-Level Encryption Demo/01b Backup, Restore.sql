/*
	Here we'll demonstrate what happens when attackers acquire your database backup.
	Backup the database and restore it on another SQL server instance (same version or higher).
*/

--From original server\instance.
BACKUP DATABASE DaveTest
TO DISK = 'C:\Backup\DaveTest.bak'
WITH INIT, FORMAT, COMPRESSION;

USE master;
--ALTER DATABASE DaveTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--From different server\instance.
RESTORE DATABASE DaveTest
FROM DISK = 'C:\Backup\DaveTest.bak'
WITH REPLACE, RECOVERY,
	MOVE 'DaveTest' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.DEV\MSSQL\DATA\DaveTest.mdf',
	MOVE 'DaveTest_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.DEV\MSSQL\DATA\DaveTest_log.ldf'
GO

USE DaveTest
GO

SELECT * FROM sys.symmetric_keys

--Can't open symmetric key on a different instance because the database master key
--is still encrypted by the service master key of the "old" SQL host\instance.
OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

--Without opening the key, encrypted columns return NULL.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

--Password required to open DMK.
--Offline/brute force attack is possible.
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'wrong password';

--Password required to open DMK.
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';

OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

--With symmetric open, decryption occurs as normal.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

CLOSE SYMMETRIC KEY CustomerSmtpKey;
CLOSE MASTER KEY;

/*
	If desired, re-enable the automatic decryption of the database master key.
	Drop database master key encryption (from the original server\instance),
	and add it back via the current service master key.
*/
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';
ALTER MASTER KEY DROP ENCRYPTION BY SERVICE MASTER KEY; 
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY;
CLOSE MASTER KEY; 

--Now the symmetric key can be opened directly without a password.
OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

CLOSE SYMMETRIC KEY CustomerSmtpKey;
