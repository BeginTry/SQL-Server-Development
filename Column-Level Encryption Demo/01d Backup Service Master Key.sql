--Original server.
/*
	If the SQL Server host is compromised, the service master key
	can be backed up to disk/file. 
	Attackers can then take the backup and restore it to another SQL instance. 
*/
BACKUP SERVICE MASTER KEY TO FILE = 'C:\Backup\Service Master.key'   
ENCRYPTION BY PASSWORD = 'Vz0J$#A@oZOJI~oORtrRF4*&ueg!Fp+\/:ci^8gU';
GO
