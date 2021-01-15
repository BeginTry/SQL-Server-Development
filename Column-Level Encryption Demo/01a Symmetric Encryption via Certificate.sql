/*
	Scenario #1
	This is the same as the "Encrypt a column of data" example in Microsoft's online documentation:
		https://docs.microsoft.com/en-us/sql/relational-databases/security/encryption/encrypt-a-column-of-data?view=sql-server-2017
*/

USE master;
ALTER DATABASE DaveTest SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE DaveTest;

IF DB_ID('DaveTest') IS NULL
	EXEC('CREATE DATABASE DaveTest;');
GO

USE DaveTest
GO

CREATE TABLE dbo.Smtp(
	SmtpID INT IDENTITY
		CONSTRAINT PK_Smtp PRIMARY KEY,
	CustomerID INT,
	UserID INT,
	--Encryption for the next three columns.
	SmtpServerAddress VARBINARY(128),
	SmtpUserName VARBINARY(128),
	SmtpPassword VARBINARY(128)
)
GO

--NOTE: to enable the automatic decryption of the database master key, a copy of the key is 
--encrypted by using the service master key and stored in both the database and in master.
CREATE MASTER KEY 
ENCRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';
GO

CREATE CERTIFICATE CustomerData
WITH SUBJECT = 'Customer sensitive data';
GO

CREATE SYMMETRIC KEY CustomerSmtpKey  
WITH ALGORITHM = AES_256  
ENCRYPTION BY CERTIFICATE CustomerData;  
GO 

SELECT * FROM sys.symmetric_keys
SELECT * FROM sys.certificates

--Open key (for current session only).
--No password required.
OPEN SYMMETRIC KEY CustomerSmtpKey  
DECRYPTION BY CERTIFICATE CustomerData; 

INSERT INTO dbo.Smtp (CustomerID, UserID, SmtpServerAddress, SmtpUserName, SmtpPassword)
VALUES 
	--Data for all three rows encrypted by the same symmetric key.
	(1, 1, EncryptByKey(Key_GUID('CustomerSmtpKey'), 'smtp.gmail.com'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), '4128569888254699'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), 'st00ges') ),

	(1, 2, EncryptByKey(Key_GUID('CustomerSmtpKey'), 'smtp.gmail.com'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), 'Curly@gmail.com'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), 'nyuk, nyuk, nyuk') ),

	(1, 3, EncryptByKey(Key_GUID('CustomerSmtpKey'), 'smtp.gmail.com'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), 'Moe@gmail.com'),
	EncryptByKey(Key_GUID('CustomerSmtpKey'), 'wise guys') )
GO

SELECT * FROM dbo.Smtp;

--Symmetric key is still open for decryption.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) AS DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) AS DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) AS DecryptedPassword
FROM dbo.Smtp 

--Symmetric keys are opened on a per-session basis only.
--Copy the query above, open a new session in SSMS (CTRL + N), and paste in the query.
--The query will run without errors, but the encrypted columns will be NULL.

CLOSE SYMMETRIC KEY CustomerSmtpKey;

--With the key no longer open, encrypted columns will be NULL.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

/*
	Security considerations for this security model:
	Those who can encrypt/decrypt:
		SA and members of sysadmin fixed server role.
		The login that owns the database.
		Members of fixed database role [db_owner] (explicit DENY is applicable, though).
		Database users GRANTed specific permissions (or role members with same).

	If a backup of the database is lost, or someone is able to acquire the base database files (.mdf/.ldf),
	the encrypted data will remain protected. We'll demonstrate this in the next script.
*/
