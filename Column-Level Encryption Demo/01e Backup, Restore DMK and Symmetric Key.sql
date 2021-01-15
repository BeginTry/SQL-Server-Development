USE DaveTest;

/*
	The Database Master Key, all certificates, and all symmetric (and asymmetric) keys reside
	within the database. All of the objects are included with a database backup.

	The Database Master Key and certificates can be backed up separately.
*/

OPEN MASTER KEY 
DECRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';

BACKUP MASTER KEY
TO FILE = 'C:\Backup\DaveTest.key'
ENCRYPTION BY PASSWORD = 'cis$\jdV=Acw|*GsSNPp6Rf"X3X59EwUt*vFVgY*';
GO

CLOSE MASTER KEY;

BACKUP CERTIFICATE CustomerData
TO FILE = 'C:\Backup\CustomerData.key';
GO

--Summetric keys cannot be backed up directly (but there are workarounds).

/*
	If the database master key, certificates, or symmetric keys are every dropped,
	there is a risk of losing the encrypted data.
*/

--Dependencies will prevent some objects from being dropped.
DROP MASTER KEY; 
DROP CERTIFICATE CustomerData;

--Done in the correct order, there is nothing to stop objects from being dropped.
DROP SYMMETRIC KEY CustomerSmtpKey;
DROP CERTIFICATE CustomerData;
DROP MASTER KEY 
GO
