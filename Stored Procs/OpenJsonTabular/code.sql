USE tempdb;
GO

CREATE OR ALTER PROCEDURE dbo.OpenJsonTabular
	@Json NVARCHAR(MAX)
AS
/*
	Dynamically returns a resultset from the input JSON data.
	The JSON data is assumed to be tabular/flat, with schema
	inferred from the first "row" of JSON key/value pairs.
	The JSON data is assumed to be in the format produced by the
		FOR JSON clause with the AUTO option:

	[   
		{ "Row1Column1Name": "Row1Column1Value", "Row1Column2Name": "Row1Column2Value", ... "Row1Column(n)Name": "Row1Column(n)Value" },   
		{ "Row2Column1Name": "Row2Column1Value", "Row2Column2Name": "Row2Column2Value", ... "Row2Column(n)Name": "Row2Column(n)Value" },   
		...
		{ "Row(n)Column1Name": "Row(n)Column1Value", "Row(n)Column2Name": "Row(n)Column2Value", ... "Row(n)Column(n)Name": "RowColumn(n)Value" },   
	]

*/
BEGIN
	DECLARE @Tsql NVARCHAR(MAX) = CHAR(9);

	SELECT @Tsql = @Tsql + STRING_AGG(
		'TRY_CAST(JSON_VALUE(j.value, ''$."' + CAST(k.[key] AS VARCHAR(MAX)) + '"'') AS ' + 
		
		--Try to map the JSON type to a SQL Server type.
		CASE
			--JSON null
			WHEN k.type = 0 THEN 'VARCHAR(MAX)'

			--JSON string (double-quoted Unicode with backslash escaping)
			WHEN k.type = 1 THEN 
				CASE 
					WHEN TRY_CAST(k.[value] AS DATETIME) IS NOT NULL AND k.[value] <> '' THEN 'DATETIME'	
					ELSE 'VARCHAR(MAX)'	
				END

			----JSON number (double- precision floating-point format in JavaScript)
			WHEN k.type = 2 THEN 
				CASE
					WHEN k.[value] LIKE '%.%' THEN 'NUMERIC(38, 5)'
					WHEN k.[value] LIKE '%,%' THEN 'NUMERIC(38, 5)'
					ELSE 'BIGINT'
				END

			--JSON boolean ("true" or "false")
			WHEN k.type = 3 THEN 'BIT'
			
			--JSON array (ordered sequence of values)
			WHEN k.type = 4 THEN 'VARCHAR(MAX)'

			--JSON object (an unordered collection of key:value pairs)
			WHEN k.type = 5 THEN 'VARCHAR(MAX)'

			ELSE 'VARCHAR(MAX)'		--null
		END + ') AS ' + QUOTENAME(k.[key]), ', ' + CHAR(13) + CHAR(10) + CHAR(9) )

	FROM OPENJSON(@Json) j
	CROSS APPLY OPENJSON(j.value) k
	WHERE j.[key] = 0

	SELECT @Tsql = 'SELECT ' + CHAR(13) + CHAR(10) +
		@Tsql + CHAR(13) + CHAR(10) +
	'FROM OPENJSON(''' + 
		--Ugh. This is awkward...replace each quote with two quotes.
		REPLACE(@Json, CHAR(39), CHAR(39) + CHAR(39)) + 
		''') j';

	--SELECT @Tsql;
	EXEC (@Tsql);
END

/*
	--Examples:

	DECLARE @Json NVARCHAR(MAX) =
	(
		SELECT * 
		FROM [AdventureWorks].[Production].[ProductListPriceHistory]
		FOR JSON AUTO
	)
	EXEC tempdb.dbo.OpenJsonTabular @Json;


	DECLARE @Json NVARCHAR(MAX) =
	(
		SELECT * 
		FROM [msdb].[sys].[objects]
		FOR JSON AUTO
	)
	EXEC tempdb.dbo.OpenJsonTabular @Json;
*/
