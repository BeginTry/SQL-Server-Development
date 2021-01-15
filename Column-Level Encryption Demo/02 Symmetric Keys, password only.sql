/*
	Scenario #2

	If you want to force the requirement that passwords are always used for encryption/decryption operations,
	neither a database master key nor certificates are needed, reducing complexity.

	One or more symmetric keys can be created with encryption by password. To ensure symmetric keys can be regenerated
	in the event they are accidentally (or maliciously) dropped, specify the IDENTITY_VALUE and KEY_SOURCE parameters.
	The values for those params (along with the password) must be guarded and secure.

	Much like in scenario #1, if attackers acquire your database backup, to decrypt the data they would have to 
	successfully perform a brute force attack on each symmetric key.

	Lastly, we will use multiple symmetric keys. Each key will be used to encrypt/decrypt different rows in the same
	table. This shows one approach for isolating data in a multi-tenant environment.
*/

USE DaveTest;

--Verify there is no database master key or certificates. (Drop and recreate the database, if desired.)
SELECT * FROM sys.symmetric_keys;
SELECT * FROM sys.certificates;

--Specify IDENTITY_VALUE and KEY_SOURCE so the keys can be recreated, if necessary.
CREATE SYMMETRIC KEY CustomerABC_Key 
WITH 
	--IDENTITY_VALUE must be unique per database.
	--sys.symmetric_keys(key_guid) is derived from this value.
	IDENTITY_VALUE = 'Enter a key description', 

	KEY_SOURCE = 'Enter a key phrase here (keep very secret)',
	ALGORITHM = AES_256

    ENCRYPTION BY PASSWORD = 'XCnzoE~J$4G76NQ:.Zc!1;!wY0N/%E$\O?F?^\.j';  
GO

CREATE SYMMETRIC KEY CustomerXYZ_Key 
WITH 
	ALGORITHM = AES_256, 

	--These two optional params allow a symmetric key to be regenerated.
	IDENTITY_VALUE = 'Another a key description',
	KEY_SOURCE = 'Another key phrase here (keep very secret)'
 
    ENCRYPTION BY PASSWORD = '3p`2cRl`+QHU758ov=JmO2z+\etL4e:*JC!O=iwl';  
GO

TRUNCATE TABLE dbo.Smtp;

OPEN SYMMETRIC KEY CustomerABC_Key  
DECRYPTION BY PASSWORD = 'XCnzoE~J$4G76NQ:.Zc!1;!wY0N/%E$\O?F?^\.j';

OPEN SYMMETRIC KEY CustomerXYZ_Key  
DECRYPTION BY PASSWORD = '3p`2cRl`+QHU758ov=JmO2z+\etL4e:*JC!O=iwl'; 

INSERT INTO dbo.Smtp (CustomerID, UserID, SmtpServerAddress, SmtpUserName, SmtpPassword)
VALUES 
	--Row encrypted by CustomerABC_Key.
	(1, 1, EncryptByKey(Key_GUID('CustomerABC_Key'), 'smtp.gmail.com'),
	EncryptByKey(Key_GUID('CustomerABC_Key'), 'Hall@gmail.com'),
	EncryptByKey(Key_GUID('CustomerABC_Key'), 'No can do') ),

	--Row encrypted by different key.
	(1, 2, EncryptByKey(Key_GUID('CustomerXYZ_Key'), 'smtp.gmail.com'),
	EncryptByKey(Key_GUID('CustomerXYZ_Key'), 'Oates@gmail.com'),
	EncryptByKey(Key_GUID('CustomerXYZ_Key'), 'Private eyes') )
GO

CLOSE SYMMETRIC KEY CustomerABC_Key;
CLOSE SYMMETRIC KEY CustomerXYZ_Key;

SELECT * FROM dbo.Smtp

--Open the key for customer ABC.
OPEN SYMMETRIC KEY CustomerABC_Key  
DECRYPTION BY PASSWORD = 'XCnzoE~J$4G76NQ:.Zc!1;!wY0N/%E$\O?F?^\.j';

--Even though both keys have the same password, 
--we should only "see" the data from one row.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

--Open the key for customer XYZ.
--With both keys open, we can "see" data for both rows.
OPEN SYMMETRIC KEY CustomerXYZ_Key  
DECRYPTION BY PASSWORD = '3p`2cRl`+QHU758ov=JmO2z+\etL4e:*JC!O=iwl';

SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

CLOSE SYMMETRIC KEY CustomerABC_Key;
CLOSE SYMMETRIC KEY CustomerXYZ_Key;

/******************************************************************/

DROP SYMMETRIC KEY CustomerABC_Key;
DROP SYMMETRIC KEY CustomerXYZ_Key;

--Previously encrypted data is still in the table.
SELECT * FROM dbo.Smtp;

--Recreate symmetric keys, specifying IDENTITY_VALUE and KEY_SOURCE.
CREATE SYMMETRIC KEY CustomerABC_Key 
WITH 
	ALGORITHM = AES_256, 

	--These two params allow a symmetric key to be regenerated.
	IDENTITY_VALUE = 'Enter a key description',
	KEY_SOURCE = 'Enter a key phrase here (keep very secret)'
 
    ENCRYPTION BY PASSWORD = 'XCnzoE~J$4G76NQ:.Zc!1;!wY0N/%E$\O?F?^\.j';  
GO

CREATE SYMMETRIC KEY CustomerXYZ_Key 
WITH 
	ALGORITHM = AES_256, 

	--These two params allow a symmetric key to be regenerated.
	IDENTITY_VALUE = 'Another a key description',
	KEY_SOURCE = 'Another key phrase here (keep very secret)'
 
    ENCRYPTION BY PASSWORD = '3p`2cRl`+QHU758ov=JmO2z+\etL4e:*JC!O=iwl';  
GO

OPEN SYMMETRIC KEY CustomerABC_Key  
DECRYPTION BY PASSWORD = 'XCnzoE~J$4G76NQ:.Zc!1;!wY0N/%E$\O?F?^\.j';

OPEN SYMMETRIC KEY CustomerXYZ_Key  
DECRYPTION BY PASSWORD = '3p`2cRl`+QHU758ov=JmO2z+\etL4e:*JC!O=iwl'; 

--Recreated keys should be identical and can
--successfully decrypt previously encrypted data.
SELECT CustomerID, UserID, 
	CONVERT(varchar, DecryptByKey(SmtpServerAddress)) DecryptedServerAddress,
	CONVERT(varchar, DecryptByKey(SmtpUserName)) DecryptedUserName,
	CONVERT(varchar, DecryptByKey(SmtpPassword)) DecryptedPassword
FROM dbo.Smtp 

CLOSE SYMMETRIC KEY CustomerABC_Key;
CLOSE SYMMETRIC KEY CustomerXYZ_Key;
