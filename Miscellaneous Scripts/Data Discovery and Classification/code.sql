/*
	This script uses procedure sp_foreachdb (credit @AaronBertrand) to 
	find data classification recommendations for each database.
*/
CREATE TABLE #DataDiscoveryAndClassification (
	DdacId INT IDENTITY PRIMARY KEY,
	DatabaseName SYSNAME,
	SchemaName SYSNAME,
	TableName SYSNAME,
	ColumnName SYSNAME,
	InformationTypeId UNIQUEIDENTIFIER,
	InformationTypeName VARCHAR(16),
	SensitivityLabelId UNIQUEIDENTIFIER,
    SensitivityLabelName VARCHAR(32),
    SensitivityLabelRank VARCHAR(16),
    IsDismissed BIT
)
GO

/*
	The bulk of this command was obtained from an Extended Events session for the "rpc_completed" event.
	The session was started, followed by using the "Data Discovery and Classification" feature in 
	SSMS ("Classify Data" task).
	Many thanks to @PatrickKeisler for helping me identify TSQL within my Extended Events session.
*/
DECLARE @cmd NVARCHAR(MAX) = N'
USE ?;

INSERT INTO #DataDiscoveryAndClassification
EXEC sp_executesql N''
IF OBJECT_ID(''''tempdb.dbo.#FullSchema'''', ''''U'''') IS NOT NULL DROP TABLE #FullSchema;

SELECT
    C.Name AS ColumnName,
    C.column_id AS ColumnId,
    S.Name AS SchemaName,
    T.Name AS TableName,
    T.object_id AS TableId,
    TYPE.name AS TypeName,
    CAST (COALESCE(DISMISSED.value, 0) AS BIT) AS IsDismissed
INTO #FullSchema
    FROM
     sys.schemas S
     INNER JOIN sys.tables T ON S.schema_id = T.schema_id  AND T.is_memory_optimized = 0 AND T.temporal_type <> 1
     INNER JOIN (SELECT name as [Name],
                    object_id,
                    column_id,
                    system_type_id, 
                    columnproperty(sys.columns.object_id, sys.columns.name, ''''charmaxlen'''') as charmaxlen 
                 FROM sys.columns where is_computed = 0) C ON T.object_id = C.object_id 
     INNER JOIN sys.types TYPE ON TYPE.system_type_id = TYPE.user_type_id AND C.system_type_id = TYPE.system_type_id AND TYPE.name IN (''''bigint'''',''''numeric'''',''''decimal'''',''''int'''',''''char'''',''''varchar'''',''''text'''',''''nchar'''',''''nvarchar'''',''''ntext'''',''''xml'''',''''smallint'''',''''smallmoney'''',''''money'''',''''float'''',''''real'''',''''date'''',''''datetime2'''',''''smalldatetime'''',''''datetime'''',''''binary'''',''''varbinary'''',''''image'''',''''sql_variant'''') 
            LEFT JOIN sys.extended_properties DISMISSED ON C.object_id = DISMISSED.major_id 
                AND C.column_id = DISMISSED.minor_id AND DISMISSED.name = ''''sys_data_classification_recommendation_disabled''''
            WHERE (DISMISSED.value IS NULL OR DISMISSED.value = 0)
            AND (C.charmaxlen IS NULL OR C.charmaxlen < 0 OR C.charmaxlen >= 4)

IF OBJECT_ID(''''tempdb.dbo.#MatchingColumns'''', ''''U'''') IS NOT NULL DROP TABLE #MatchingColumns;
WITH Keywords AS (SELECT * FROM (VALUES (@k1,0,@ti1,0),(@k2,0,@ti1,1),(@k3,0,@ti1,1),(@k4,0,@ti1,1),(@k5,0,@ti2,1),(@k6,0,@ti2,1),(@k7,0,@ti2,1),(@k8,0,@ti2,1),(@k9,0,@ti2,1),(@k10,1,@ti2,1),(@k11,1,@ti2,1),(@k12,1,@ti2,1),(@k13,1,@ti2,1),(@k14,1,@ti2,1),(@k15,1,@ti3,1),(@k16,1,@ti3,1),(@k17,1,@ti3,1),(@k18,1,@ti3,1),(@k19,1,@ti3,1),(@k20,1,@ti3,1),(@k21,1,@ti4,1),(@k22,1,@ti4,1),(@k23,1,@ti4,1),(@k24,1,@ti4,1),(@k25,1,@ti4,1),(@k26,1,@ti4,1),(@k27,1,@ti4,1),(@k28,1,@ti4,1),(@k29,1,@ti4,1),(@k30,1,@ti4,1),(@k31,1,@ti4,1),(@k32,1,@ti4,1),(@k33,1,@ti4,1),(@k34,1,@ti4,1),(@k35,1,@ti4,1),(@k36,1,@ti4,1),(@k37,1,@ti4,1),(@k38,1,@ti4,1),(@k39,1,@ti4,1),(@k40,1,@ti4,1),(@k41,1,@ti4,1),(@k42,1,@ti4,1),(@k43,1,@ti4,1),(@k44,1,@ti4,1),(@k45,1,@ti4,1),(@k46,1,@ti4,1),(@k47,1,@ti4,1),(@k48,1,@ti4,1),(@k49,1,@ti4,1),(@k50,1,@ti4,1),(@k51,1,@ti4,1),(@k52,1,@ti4,1),(@k53,1,@ti4,1),(@k54,1,@ti4,1),(@k55,1,@ti4,1),(@k56,1,@ti4,1),(@k57,1,@ti4,1),(@k58,1,@ti4,1),(@k59,1,@ti4,1),(@k60,1,@ti4,1),(@k61,1,@ti4,1),(@k62,1,@ti4,1),(@k63,1,@ti4,1),(@k64,1,@ti4,1),(@k65,1,@ti4,1),(@k66,1,@ti4,1),(@k67,1,@ti4,1),(@k68,1,@ti4,1),(@k69,1,@ti4,1),(@k70,1,@ti4,1),(@k71,1,@ti4,1),(@k72,1,@ti4,1),(@k73,1,@ti4,1),(@k74,1,@ti4,1),(@k75,1,@ti4,1),(@k76,1,@ti4,1),(@k77,1,@ti4,1),(@k78,1,@ti4,1),(@k79,1,@ti4,1),(@k80,1,@ti4,1),(@k81,1,@ti4,1),(@k82,1,@ti4,1),(@k83,1,@ti4,1),(@k84,1,@ti4,1),(@k85,1,@ti4,1),(@k86,1,@ti4,1),(@k87,1,@ti4,1),(@k88,1,@ti4,1),(@k89,1,@ti4,1),(@k90,1,@ti4,1),(@k91,1,@ti4,1),(@k92,1,@ti4,1),(@k93,1,@ti4,1),(@k94,1,@ti4,1),(@k95,1,@ti4,1),(@k96,1,@ti4,1),(@k97,1,@ti4,1),(@k98,1,@ti4,1),(@k99,1,@ti4,0),(@k100,1,@ti4,1),(@k101,1,@ti4,1),(@k102,1,@ti4,1),(@k103,1,@ti4,1),(@k104,1,@ti4,1),(@k105,1,@ti4,1),(@k106,1,@ti4,1),(@k107,1,@ti4,1),(@k108,1,@ti4,1),(@k109,1,@ti4,1),(@k110,1,@ti4,1),(@k111,1,@ti4,1),(@k112,1,@ti4,1),(@k113,1,@ti4,1),(@k114,1,@ti4,1),(@k115,1,@ti4,1),(@k116,1,@ti4,1),(@k117,1,@ti4,1),(@k118,1,@ti4,1),(@k119,1,@ti4,1),(@k120,1,@ti4,1),(@k121,1,@ti4,1),(@k122,1,@ti4,1),(@k123,1,@ti4,1),(@k124,1,@ti4,1),(@k125,1,@ti4,1),(@k126,1,@ti4,1),(@k127,1,@ti4,1),(@k128,1,@ti4,1),(@k129,1,@ti4,1),(@k130,1,@ti4,1),(@k131,1,@ti4,1),(@k132,1,@ti4,1),(@k133,1,@ti4,1),(@k134,1,@ti4,1),(@k135,1,@ti4,1),(@k136,1,@ti4,1),(@k137,1,@ti4,1),(@k138,1,@ti4,1),(@k139,1,@ti4,1),(@k140,1,@ti4,1),(@k141,1,@ti4,1),(@k142,1,@ti4,1),(@k143,1,@ti4,1),(@k144,1,@ti4,1),(@k145,1,@ti4,1),(@k146,1,@ti4,1),(@k147,1,@ti4,1),(@k148,1,@ti4,1),(@k149,1,@ti4,1),(@k150,1,@ti4,1),(@k151,1,@ti4,1),(@k152,1,@ti4,1),(@k153,1,@ti4,1),(@k154,1,@ti4,1),(@k155,1,@ti4,1),(@k156,1,@ti4,1),(@k157,1,@ti4,1),(@k158,1,@ti4,1),(@k159,1,@ti4,1),(@k160,1,@ti4,1),(@k161,1,@ti4,1),(@k162,1,@ti4,1),(@k163,1,@ti4,1),(@k164,1,@ti4,1),(@k165,1,@ti4,1),(@k166,1,@ti4,1),(@k167,1,@ti4,1),(@k168,1,@ti4,0),(@k169,1,@ti4,1),(@k170,1,@ti4,1),(@k171,1,@ti4,1),(@k172,1,@ti4,1),(@k173,1,@ti4,1),(@k174,1,@ti4,1),(@k175,1,@ti4,1),(@k176,1,@ti4,1),(@k177,1,@ti4,1),(@k178,1,@ti4,1),(@k179,1,@ti4,1),(@k180,1,@ti4,1),(@k181,1,@ti4,1),(@k182,1,@ti4,1),(@k183,1,@ti4,1),(@k184,1,@ti4,1),(@k185,1,@ti4,1),(@k186,1,@ti4,1),(@k187,1,@ti4,1),(@k188,1,@ti4,1),(@k189,1,@ti4,1),(@k190,1,@ti4,1),(@k191,1,@ti4,1),(@k192,1,@ti4,1),(@k193,1,@ti4,1),(@k194,1,@ti4,1),(@k195,1,@ti4,1),(@k196,1,@ti4,1),(@k197,1,@ti4,1),(@k198,1,@ti4,1),(@k199,1,@ti4,1),(@k200,1,@ti4,1),(@k201,1,@ti4,1),(@k202,1,@ti4,1),(@k203,1,@ti4,1),(@k204,1,@ti4,1),(@k205,1,@ti4,1),(@k206,1,@ti4,1),(@k207,1,@ti4,1),(@k208,1,@ti4,1),(@k209,1,@ti4,1),(@k210,1,@ti4,1),(@k211,1,@ti4,1),(@k212,1,@ti4,1),(@k213,1,@ti4,1),(@k214,1,@ti4,1),(@k215,1,@ti4,1),(@k216,1,@ti4,1),(@k217,1,@ti4,1),(@k218,1,@ti4,1),(@k219,1,@ti4,1),(@k220,1,@ti4,1),(@k221,1,@ti4,1),(@k222,1,@ti4,1),(@k223,1,@ti4,1),(@k224,1,@ti4,1),(@k225,1,@ti4,1),(@k226,1,@ti4,1),(@k227,1,@ti4,1),(@k228,1,@ti4,1),(@k229,1,@ti4,1),(@k230,1,@ti4,1),(@k231,1,@ti4,1),(@k232,1,@ti4,1),(@k233,1,@ti4,1),(@k234,1,@ti4,1),(@k235,1,@ti4,1),(@k236,1,@ti4,1),(@k237,1,@ti4,1),(@k238,1,@ti4,1),(@k239,1,@ti4,1),(@k240,1,@ti4,1),(@k241,1,@ti4,1),(@k242,1,@ti4,1),(@k243,1,@ti4,1),(@k244,1,@ti4,1),(@k245,1,@ti4,1),(@k246,1,@ti4,1),(@k247,1,@ti4,1),(@k248,1,@ti4,1),(@k249,1,@ti4,1),(@k250,1,@ti4,1),(@k251,1,@ti4,1),(@k252,1,@ti4,1),(@k253,1,@ti4,1),(@k254,1,@ti4,1),(@k255,1,@ti4,1),(@k256,1,@ti4,1),(@k257,1,@ti4,1),(@k258,1,@ti4,1),(@k259,1,@ti4,1),(@k260,1,@ti4,1),(@k261,1,@ti4,1),(@k262,1,@ti4,1),(@k263,1,@ti4,1),(@k264,1,@ti4,1),(@k265,1,@ti4,1),(@k266,1,@ti4,1),(@k267,1,@ti4,1),(@k268,1,@ti4,1),(@k269,1,@ti4,1),(@k270,1,@ti4,1),(@k271,1,@ti4,1),(@k272,0,@ti5,1),(@k273,0,@ti5,1),(@k274,1,@ti5,1),(@k275,1,@ti5,1),(@k276,1,@ti5,1),(@k277,1,@ti5,1),(@k278,1,@ti5,0),(@k279,1,@ti5,1),(@k280,1,@ti5,0),(@k281,1,@ti5,1),(@k282,1,@ti5,1),(@k283,1,@ti5,1),(@k284,1,@ti5,1),(@k285,1,@ti5,1),(@k286,1,@ti5,1),(@k287,1,@ti5,1),(@k288,1,@ti5,1),(@k289,1,@ti5,1),(@k290,1,@ti5,1),(@k291,1,@ti5,1),(@k292,1,@ti6,1),(@k293,1,@ti6,1),(@k294,1,@ti6,1),(@k295,1,@ti6,1),(@k296,1,@ti6,1),(@k297,1,@ti6,1),(@k298,1,@ti6,1),(@k299,1,@ti6,1),(@k300,1,@ti6,1),(@k301,1,@ti6,1),(@k302,1,@ti6,1),(@k303,1,@ti7,1),(@k304,1,@ti7,1),(@k305,0,@ti8,1),(@k306,0,@ti8,1),(@k307,0,@ti8,1),(@k308,0,@ti8,1),(@k309,0,@ti8,1),(@k310,1,@ti9,1),(@k311,1,@ti9,1),(@k312,1,@ti9,1),(@k313,1,@ti9,0),(@k314,1,@ti9,1),(@k315,1,@ti9,1),(@k316,1,@ti9,1),(@k317,1,@ti9,1),(@k318,1,@ti9,1),(@k319,1,@ti9,1),(@k320,1,@ti9,1),(@k321,1,@ti9,1),(@k322,1,@ti9,1),(@k323,1,@ti9,1),(@k324,1,@ti9,1),(@k325,1,@ti9,1),(@k326,1,@ti9,1),(@k327,1,@ti9,1),(@k328,1,@ti9,1),(@k329,1,@ti9,1),(@k330,1,@ti9,1),(@k331,1,@ti9,1),(@k332,1,@ti9,1),(@k333,1,@ti9,1),(@k334,1,@ti9,1),(@k335,1,@ti9,1),(@k336,1,@ti9,1),(@k337,1,@ti9,1),(@k338,1,@ti9,1),(@k339,1,@ti10,0),(@k340,1,@ti10,1),(@k341,1,@ti10,1),(@k342,1,@ti10,0),(@k343,1,@ti10,1),(@k344,1,@ti10,1),(@k345,1,@ti10,1),(@k346,1,@ti10,0),(@k347,1,@ti10,1),(@k348,1,@ti10,1),(@k349,1,@ti10,1),(@k350,1,@ti10,1),(@k351,1,@ti10,1),(@k352,1,@ti10,1),(@k353,1,@ti10,1),(@k354,1,@ti10,1),(@k355,1,@ti11,1),(@k356,1,@ti11,1),(@k357,1,@ti11,1),(@k358,1,@ti11,1),(@k359,1,@ti11,1),(@k360,1,@ti11,1),(@k361,1,@ti11,1),(@k362,1,@ti11,1),(@k363,1,@ti12,1),(@k364,1,@ti12,1),(@k365,1,@ti12,1),(@k366,1,@ti12,0)) AS a (KeywordName, CanBeNumeric, InfoTypeId, ShouldLike))
SELECT DISTINCT name, CanBeNumeric, InfoTypeId
INTO #MatchingColumns
FROM (SELECT DISTINCT LOWER(ColumnName) AS name FROM #FullSchema) AS Columns INNER JOIN Keywords
ON (ShouldLike = 0 AND name COLLATE Latin1_GENERAL_BIN = KeywordName COLLATE Latin1_GENERAL_BIN) OR
   (ShouldLike = 1 AND name COLLATE Latin1_GENERAL_BIN LIKE KeywordName COLLATE Latin1_GENERAL_BIN);

WITH 
    SensitivityLabels AS (SELECT * FROM (VALUES (@li1,@ln1,100,@r1),(@li2,@ln2,200,@r2),(@li3,@ln3,300,@r3),(@li4,@ln4,400,@r3),(@li5,@ln5,500,@r4),(@li6,@ln6,600,@r4)) AS a (LabelId, LabelName, LabelOrder, LabelRank)),
    InformationTypes AS (SELECT * FROM (VALUES (@ti1,@tn1,100, @li3),(@ti2,@tn2,200, @li3),(@ti3,@tn3,300, @li3),(@ti4,@tn4,700, @li3),(@ti5,@tn5,800, @li3),(@ti6,@tn6,900, @li3),(@ti7,@tn7,1200, @li3),(@ti8,@tn8,400, @li4),(@ti9,@tn9,500, @li4),(@ti10,@tn10,600, @li4),(@ti11,@tn11,1000, @li4),(@ti12,@tn12,1100, @li4)) AS a (InfoTypeId, InfoTypeName, InfoTypeOrder, RecommendedLabelId)),
    IntermediateResults AS (
        SELECT DISTINCT
            FS.SchemaName,
            FS.TableName,
            FS.ColumnName,
            INFOTYPES.InfoTypeId AS InfoTypeId,
            INFOTYPES.InfoTypeName AS InfoTypeName,
            INFOTYPES.InfoTypeOrder AS InfoTypeOrder,
            INFOTYPES.RecommendedLabelId AS LabelId,
            SENSITIVITYLABLES.LabelName AS LabelName,
            SENSITIVITYLABLES.LabelOrder AS LabelOrder,
            SENSITIVITYLABLES.LabelRank AS LabelRank,
            FS.IsDismissed
        FROM
            #FullSchema AS FS
            INNER JOIN #MatchingColumns MC ON
                LOWER(FS.ColumnName) = MC.name AND -- No need to convert MC.name to lower case, as it was already done.
                NOT (MC.CanBeNumeric = 0 AND FS.TypeName IN (''''bigint'''',''''bit'''',''''decimal'''',''''float'''',''''int'''',''''money'''',''''numeric'''',''''smallint'''',''''smallmoney'''',''''tinyint'''',''''real''''))
            INNER JOIN InformationTypes INFOTYPES ON MC.InfoTypeId = INFOTYPES.InfoTypeId
            LEFT JOIN SensitivityLabels SENSITIVITYLABLES ON INFOTYPES.RecommendedLabelId = SENSITIVITYLABLES.LabelId
    )
SELECT DISTINCT
	DB_NAME() AS DatabaseName,
    IR.SchemaName AS SchemaName,
    IR.TableName AS TableName,
    IR.ColumnName AS ColumnName,
    IR.InfoTypeId AS InformationTypeId,
    IR.InfoTypeName AS InformationTypeName,
    IR.LabelId AS SensitivityLabelId,
    IR.LabelName AS SensitivityLabelName,
    IR.LabelRank AS SensitivityLabelRank,
    IR.IsDismissed AS IsDismissed
FROM IntermediateResults IR
    INNER JOIN (SELECT SchemaName, TableName, ColumnName, MIN(InfoTypeOrder) AS MinOrder
                FROM IntermediateResults
                GROUP BY SchemaName, TableName, ColumnName) MR
    ON IR.SchemaName = MR.SchemaName AND IR.TableName = MR.TableName
    AND IR.ColumnName = MR.ColumnName AND IR.InfoTypeOrder = MR.MinOrder
ORDER BY SchemaName, TableName, ColumnName;

IF OBJECT_ID(''''tempdb.dbo.#MatchingColumns'''', ''''U'''') IS NOT NULL DROP TABLE #MatchingColumns;


IF OBJECT_ID(''''tempdb.dbo.#FullSchema'''', ''''U'''') IS NOT NULL DROP TABLE #FullSchema;'',N''@r1 nvarchar(4),@li1 uniqueidentifier,@ln1 nvarchar(6),@r2 nvarchar(3),@li2 uniqueidentifier,@ln2 nvarchar(7),@r3 nvarchar(6),@li3 uniqueidentifier,@ln3 nvarchar(12),@li4 uniqueidentifier,@ln4 nvarchar(19),@r4 nvarchar(4),@li5 uniqueidentifier,@ln5 nvarchar(19),@li6 uniqueidentifier,@ln6 nvarchar(26),@ti1 uniqueidentifier,@tn1 nvarchar(10),@ti2 uniqueidentifier,@tn2 nvarchar(12),@ti3 uniqueidentifier,@tn3 nvarchar(11),@ti4 uniqueidentifier,@tn4 nvarchar(11),@ti5 uniqueidentifier,@tn5 nvarchar(7),@ti6 uniqueidentifier,@tn6 nvarchar(9),@ti7 uniqueidentifier,@tn7 nvarchar(5),@ti8 uniqueidentifier,@tn8 nvarchar(4),@ti9 uniqueidentifier,@tn9 nvarchar(11),@ti10 uniqueidentifier,@tn10 nvarchar(3),@ti11 uniqueidentifier,@tn11 nvarchar(6),@ti12 uniqueidentifier,@tn12 nvarchar(13),@k1 nvarchar(2),@k2 nvarchar(16),@k3 nvarchar(11),@k4 nvarchar(13),@k5 nvarchar(7),@k6 nvarchar(8),@k7 nvarchar(6),@k8 nvarchar(8),@k9 nvarchar(6),@k10 nvarchar(7),@k11 nvarchar(8),@k12 nvarchar(11),@k13 nvarchar(8),@k14 nvarchar(5),@k15 nvarchar(10),@k16 nvarchar(5),@k17 nvarchar(10),@k18 nvarchar(12),@k19 nvarchar(6),@k20 nvarchar(10),@k21 nvarchar(8),@k22 nvarchar(6),@k23 nvarchar(5),@k24 nvarchar(7),@k25 nvarchar(6),@k26 nvarchar(12),@k27 nvarchar(5),@k28 nvarchar(6),@k29 nvarchar(6),@k30 nvarchar(10),@k31 nvarchar(18),@k32 nvarchar(17),@k33 nvarchar(20),@k34 nvarchar(6),@k35 nvarchar(10),@k36 nvarchar(11),@k37 nvarchar(11),@k38 nvarchar(9),@k39 nvarchar(10),@k40 nvarchar(16),@k41 nvarchar(12),@k42 nvarchar(12),@k43 nvarchar(11),@k44 nvarchar(11),@k45 nvarchar(13),@k46 nvarchar(10),@k47 nvarchar(11),@k48 nvarchar(18),@k49 nvarchar(14),@k50 nvarchar(15),@k51 nvarchar(18),@k52 nvarchar(19),@k53 nvarchar(19),@k54 nvarchar(18),@k55 nvarchar(18),@k56 nvarchar(8),@k57 nvarchar(15),@k58 nvarchar(13),@k59 nvarchar(17),@k60 nvarchar(17),@k61 nvarchar(18),@k62 nvarchar(14),@k63 nvarchar(19),@k64 nvarchar(19),@k65 nvarchar(18),@k66 nvarchar(18),@k67 nvarchar(12),@k68 nvarchar(13),@k69 nvarchar(12),@k70 nvarchar(20),@k71 nvarchar(15),@k72 nvarchar(13),@k73 nvarchar(13),@k74 nvarchar(12),@k75 nvarchar(19),@k76 nvarchar(13),@k77 nvarchar(10),@k78 nvarchar(15),@k79 nvarchar(19),@k80 nvarchar(16),@k81 nvarchar(21),@k82 nvarchar(13),@k83 nvarchar(14),@k84 nvarchar(12),@k85 nvarchar(22),@k86 nvarchar(21),@k87 nvarchar(5),@k88 nvarchar(7),@k89 nvarchar(11),@k90 nvarchar(13),@k91 nvarchar(13),@k92 nvarchar(7),@k93 nvarchar(15),@k94 nvarchar(10),@k95 nvarchar(14),@k96 nvarchar(13),@k97 nvarchar(9),@k98 nvarchar(17),@k99 nvarchar(2),@k100 nvarchar(13),@k101 nvarchar(9),@k102 nvarchar(10),@k103 nvarchar(15),@k104 nvarchar(14),@k105 nvarchar(14),@k106 nvarchar(16),@k107 nvarchar(15),@k108 nvarchar(15),@k109 nvarchar(10),@k110 nvarchar(11),@k111 nvarchar(18),@k112 nvarchar(14),@k113 nvarchar(18),@k114 nvarchar(18),@k115 nvarchar(18),@k116 nvarchar(19),@k117 nvarchar(20),@k118 nvarchar(17),@k119 nvarchar(18),@k120 nvarchar(18),@k121 nvarchar(18),@k122 nvarchar(17),@k123 nvarchar(10),@k124 nvarchar(13),@k125 nvarchar(16),@k126 nvarchar(15),@k127 nvarchar(14),@k128 nvarchar(14),@k129 nvarchar(15),@k130 nvarchar(20),@k131 nvarchar(18),@k132 nvarchar(19),@k133 nvarchar(18),@k134 nvarchar(21),@k135 nvarchar(23),@k136 nvarchar(23),@k137 nvarchar(20),@k138 nvarchar(21),@k139 nvarchar(18),@k140 nvarchar(16),@k141 nvarchar(23),@k142 nvarchar(21),@k143 nvarchar(18),@k144 nvarchar(16),@k145 nvarchar(20),@k146 nvarchar(11),@k147 nvarchar(6),@k148 nvarchar(20),@k149 nvarchar(20),@k150 nvarchar(8),@k151 nvarchar(13),@k152 nvarchar(17),@k153 nvarchar(16),@k154 nvarchar(20),@k155 nvarchar(19),@k156 nvarchar(16),@k157 nvarchar(12),@k158 nvarchar(17),@k159 nvarchar(19),@k160 nvarchar(33),@k161 nvarchar(7),@k162 nvarchar(20),@k163 nvarchar(15),@k164 nvarchar(7),@k165 nvarchar(28),@k166 nvarchar(19),@k167 nvarchar(19),@k168 nvarchar(3),@k169 nvarchar(9),@k170 nvarchar(15),@k171 nvarchar(15),@k172 nvarchar(15),@k173 nvarchar(10),@k174 nvarchar(16),@k175 nvarchar(16),@k176 nvarchar(16),@k177 nvarchar(21),@k178 nvarchar(21),@k179 nvarchar(8),@k180 nvarchar(21),@k181 nvarchar(21),@k182 nvarchar(14),@k183 nvarchar(12),@k184 nvarchar(14),@k185 nvarchar(5),@k186 nvarchar(5),@k187 nvarchar(6),@k188 nvarchar(5),@k189 nvarchar(15),@k190 nvarchar(15),@k191 nvarchar(16),@k192 nvarchar(16),@k193 nvarchar(8),@k194 nvarchar(21),@k195 nvarchar(21),@k196 nvarchar(19),@k197 nvarchar(14),@k198 nvarchar(10),@k199 nvarchar(14),@k200 nvarchar(26),@k201 nvarchar(24),@k202 nvarchar(24),@k203 nvarchar(15),@k204 nvarchar(19),@k205 nvarchar(18),@k206 nvarchar(20),@k207 nvarchar(23),@k208 nvarchar(22),@k209 nvarchar(40),@k210 nvarchar(15),@k211 nvarchar(23),@k212 nvarchar(20),@k213 nvarchar(19),@k214 nvarchar(23),@k215 nvarchar(17),@k216 nvarchar(11),@k217 nvarchar(12),@k218 nvarchar(12),@k219 nvarchar(15),@k220 nvarchar(13),@k221 nvarchar(17),@k222 nvarchar(18),@k223 nvarchar(17),@k224 nvarchar(19),@k225 nvarchar(11),@k226 nvarchar(15),@k227 nvarchar(19),@k228 nvarchar(17),@k229 nvarchar(19),@k230 nvarchar(14),@k231 nvarchar(8),@k232 nvarchar(19),@k233 nvarchar(19),@k234 nvarchar(14),@k235 nvarchar(13),@k236 nvarchar(18),@k237 nvarchar(20),@k238 nvarchar(11),@k239 nvarchar(15),@k240 nvarchar(18),@k241 nvarchar(14),@k242 nvarchar(11),@k243 nvarchar(15),@k244 nvarchar(8),@k245 nvarchar(8),@k246 nvarchar(10),@k247 nvarchar(11),@k248 nvarchar(12),@k249 nvarchar(8),@k250 nvarchar(9),@k251 nvarchar(8),@k252 nvarchar(21),@k253 nvarchar(15),@k254 nvarchar(12),@k255 nvarchar(18),@k256 nvarchar(12),@k257 nvarchar(18),@k258 nvarchar(10),@k259 nvarchar(9),@k260 nvarchar(10),@k261 nvarchar(14),@k262 nvarchar(7),@k263 nvarchar(6),@k264 nvarchar(12),@k265 nvarchar(13),@k266 nvarchar(10),@k267 nvarchar(11),@k268 nvarchar(13),@k269 nvarchar(5),@k270 nvarchar(14),@k271 nvarchar(17),@k272 nvarchar(11),@k273 nvarchar(10),@k274 nvarchar(9),@k275 nvarchar(12),@k276 nvarchar(13),@k277 nvarchar(11),@k278 nvarchar(4),@k279 nvarchar(16),@k280 nvarchar(3),@k281 nvarchar(13),@k282 nvarchar(14),@k283 nvarchar(12),@k284 nvarchar(15),@k285 nvarchar(11),@k286 nvarchar(10),@k287 nvarchar(9),@k288 nvarchar(10),@k289 nvarchar(10),@k290 nvarchar(9),@k291 nvarchar(10),@k292 nvarchar(9),@k293 nvarchar(5),@k294 nvarchar(8),@k295 nvarchar(9),@k296 nvarchar(11),@k297 nvarchar(5),@k298 nvarchar(8),@k299 nvarchar(5),@k300 nvarchar(14),@k301 nvarchar(10),@k302 nvarchar(9),@k303 nvarchar(10),@k304 nvarchar(10),@k305 nvarchar(11),@k306 nvarchar(12),@k307 nvarchar(9),@k308 nvarchar(13),@k309 nvarchar(11),@k310 nvarchar(10),@k311 nvarchar(11),@k312 nvarchar(8),@k313 nvarchar(4),@k314 nvarchar(8),@k315 nvarchar(16),@k316 nvarchar(23),@k317 nvarchar(16),@k318 nvarchar(11),@k319 nvarchar(13),@k320 nvarchar(15),@k321 nvarchar(14),@k322 nvarchar(14),@k323 nvarchar(15),@k324 nvarchar(17),@k325 nvarchar(13),@k326 nvarchar(14),@k327 nvarchar(17),@k328 nvarchar(13),@k329 nvarchar(14),@k330 nvarchar(38),@k331 nvarchar(20),@k332 nvarchar(11),@k333 nvarchar(11),@k334 nvarchar(17),@k335 nvarchar(24),@k336 nvarchar(9),@k337 nvarchar(16),@k338 nvarchar(18),@k339 nvarchar(3),@k340 nvarchar(8),@k341 nvarchar(7),@k342 nvarchar(3),@k343 nvarchar(13),@k344 nvarchar(17),@k345 nvarchar(9),@k346 nvarchar(4),@k347 nvarchar(7),@k348 nvarchar(18),@k349 nvarchar(18),@k350 nvarchar(28),@k351 nvarchar(32),@k352 nvarchar(28),@k353 nvarchar(16),@k354 nvarchar(11),@k355 nvarchar(9),@k356 nvarchar(8),@k357 nvarchar(9),@k358 nvarchar(11),@k359 nvarchar(17),@k360 nvarchar(12),@k361 nvarchar(8),@k362 nvarchar(14),@k363 nvarchar(10),@k364 nvarchar(15),@k365 nvarchar(12),@k366 nvarchar(3)'',@r1=N''None'',@li1=''1866CA45-1973-4C28-9D12-04D407F147AD'',@ln1=N''Public'',@r2=N''Low'',@li2=''684A0DB2-D514-49D8-8C0C-DF84A7B083EB'',@ln2=N''General'',@r3=N''Medium'',@li3=''331F0B13-76B5-2F1B-A77B-DEF5A73C73C2'',@ln3=N''Confidential'',@li4=''989ADC05-3F3F-0588-A635-F475B994915B'',@ln4=N''Confidential - GDPR'',@r4=N''High'',@li5=''B82CE05B-60A9-4CF3-8A8A-D6A0BB76E903'',@ln5=N''Highly Confidential'',@li6=''3302AE7F-B8AC-46BC-97F8-378828781EFD'',@ln6=N''Highly Confidential - GDPR'',@ti1=''B40AD280-0F6A-6CA8-11BA-2F1A08651FCF'',@tn1=N''Networking'',@ti2=''5C503E21-22C6-81FA-620B-F369B8EC38D1'',@tn2=N''Contact Info'',@ti3=''C64ABA7B-3A3E-95B6-535D-3BC535DA5A59'',@tn3=N''Credentials'',@ti4=''D22FA6E9-5EE4-3BDE-4C2B-A409604C4646'',@tn4=N''Credit Card'',@ti5=''8A462631-4130-0A31-9A52-C6A9CA125F92'',@tn5=N''Banking'',@ti6=''C44193E1-0E58-4B2A-9001-F7D6E7BC1373'',@tn6=N''Financial'',@ti7=''9C5B4809-0CCC-0637-6547-91A6F8BB609D'',@tn7=N''Other'',@ti8=''57845286-7598-22F5-9659-15B24AEB125E'',@tn8=N''Name'',@ti9=''6F5A11A7-08B1-19C3-59E5-8C89CF4F8444'',@tn9=N''National ID'',@ti10=''D936EC2C-04A4-9CF7-44C2-378A96456C61'',@tn10=N''SSN'',@ti11=''6E2C5B18-97CF-3073-27AB-F12F87493DA7'',@tn11=N''Health'',@ti12=''3DE7CC52-710D-4E96-7E20-4D5188D2590C'',@tn12=N''Date Of Birth'',@k1=N''ip'',@k2=N''%[^h]ip%address%'',@k3=N''ip%address%'',@k4=N''%mac%address%'',@k5=N''%email%'',@k6=N''%e-mail%'',@k7=N''%addr%'',@k8=N''%street%'',@k9=N''%city%'',@k10=N''%phone%'',@k11=N''%mobile%'',@k12=N''%area%code%'',@k13=N''%postal%'',@k14=N''%zip%'',@k15=N''%username%'',@k16=N''%pwd%'',@k17=N''%password%'',@k18=N''%reset%code%'',@k19=N''%pass%'',@k20=N''%user%acc%'',@k21=N''%credit%'',@k22=N''%card%'',@k23=N''%ccn%'',@k24=N''%debit%'',@k25=N''%visa%'',@k26=N''%mastercard%'',@k27=N''%cvv%'',@k28=N''%expy%'',@k29=N''%expm%'',@k30=N''%atmkaart%'',@k31=N''%american%express%'',@k32=N''%americanexpress%'',@k33=N''%americano%espresso%'',@k34=N''%amex%'',@k35=N''%atm%card%'',@k36=N''%atm%cards%'',@k37=N''%atm%kaart%'',@k38=N''%atmcard%'',@k39=N''%atmcards%'',@k40=N''%carte%bancaire%'',@k41=N''%atmkaarten%'',@k42=N''%bancontact%'',@k43=N''%bank%card%'',@k44=N''%bankkaart%'',@k45=N''%card%holder%'',@k46=N''%card%num%'',@k47=N''%card%type%'',@k48=N''%cardano%numerico%'',@k49=N''%carta%bianca%'',@k50=N''%carta%credito%'',@k51=N''%carta%di%credito%'',@k52=N''%cartao%de%credito%'',@k53=N''%cartao%de%crédito%'',@k54=N''%cartao%de%debito%'',@k55=N''%cartao%de%débito%'',@k56=N''%cirrus%'',@k57=N''%carte%blanche%'',@k58=N''%carte%bleue%'',@k59=N''%carte%de%credit%'',@k60=N''%carte%de%crédit%'',@k61=N''%carte%di%credito%'',@k62=N''%carteblanche%'',@k63=N''%cartão%de%credito%'',@k64=N''%cartão%de%crédito%'',@k65=N''%cartão%de%debito%'',@k66=N''%cartão%de%débito%'',@k67=N''%check%card%'',@k68=N''%chequekaart%'',@k69=N''%hoofdkaart%'',@k70=N''%cirrus-edc-maestro%'',@k71=N''%controlekaart%'',@k72=N''%credit%card%'',@k73=N''%debet%kaart%'',@k74=N''%debit%card%'',@k75=N''%debito%automatico%'',@k76=N''%diners%club%'',@k77=N''%discover%'',@k78=N''%discover%card%'',@k79=N''%débito%automático%'',@k80=N''%eigentümername%'',@k81=N''%european%debit%card%'',@k82=N''%master%card%'',@k83=N''%hoofdkaarten%'',@k84=N''%in%viaggio%'',@k85=N''%japanese%card%bureau%'',@k86=N''%japanse%kaartdienst%'',@k87=N''%jcb%'',@k88=N''%kaart%'',@k89=N''%kaart%num%'',@k90=N''%kaartaantal%'',@k91=N''%kaarthouder%'',@k92=N''%karte%'',@k93=N''%karteninhaber%'',@k94=N''%kartennr%'',@k95=N''%kartennummer%'',@k96=N''%kreditkarte%'',@k97=N''%maestro%'',@k98=N''%numero%de%carte%'',@k99=N''mc'',@k100=N''%mister%cash%'',@k101=N''%n%carta%'',@k102=N''%n.%carta%'',@k103=N''%no%de%tarjeta%'',@k104=N''%no%do%cartao%'',@k105=N''%no%do%cartão%'',@k106=N''%no.%de%tarjeta%'',@k107=N''%no.%do%cartao%'',@k108=N''%no.%do%cartão%'',@k109=N''%nr%carta%'',@k110=N''%nr.%carta%'',@k111=N''%numeri%di%scheda%'',@k112=N''%numero%carta%'',@k113=N''%numero%de%cartao%'',@k114=N''%número%de%cartao%'',@k115=N''%numero%de%cartão%'',@k116=N''%numero%de%tarjeta%'',@k117=N''%numero%della%carta%'',@k118=N''%numero%di%carta%'',@k119=N''%numero%di%scheda%'',@k120=N''%numero%do%cartao%'',@k121=N''%numero%do%cartão%'',@k122=N''%numéro%de%carte%'',@k123=N''%nº%carta%'',@k124=N''%nº%de%carte%'',@k125=N''%nº%de%la%carte%'',@k126=N''%nº%de%tarjeta%'',@k127=N''%nº%do%cartao%'',@k128=N''%nº%do%cartão%'',@k129=N''%nº.%do%cartão%'',@k130=N''%scoprono%le%schede%'',@k131=N''%número%de%cartão%'',@k132=N''%número%de%tarjeta%'',@k133=N''%número%do%cartao%'',@k134=N''%scheda%dell''''assegno%'',@k135=N''%scheda%dell''''atmosfera%'',@k136=N''%scheda%dell''''atmosfera%'',@k137=N''%scheda%della%banca%'',@k138=N''%scheda%di%controllo%'',@k139=N''%scheda%di%debito%'',@k140=N''%scheda%matrice%'',@k141=N''%schede%dell''''atmosfera%'',@k142=N''%schede%di%controllo%'',@k143=N''%schede%di%debito%'',@k144=N''%schede%matrici%'',@k145=N''%scoprono%la%scheda%'',@k146=N''%visa%plus%'',@k147=N''%solo%'',@k148=N''%supporti%di%scheda%'',@k149=N''%supporto%di%scheda%'',@k150=N''%switch%'',@k151=N''%tarjeta%atm%'',@k152=N''%tarjeta%credito%'',@k153=N''%tarjeta%de%atm%'',@k154=N''%tarjeta%de%credito%'',@k155=N''%tarjeta%de%debito%'',@k156=N''%tarjeta%debito%'',@k157=N''%tarjeta%no%'',@k158=N''%tarjetahabiente%'',@k159=N''%tipo%della%scheda%'',@k160=N''%ufficio%giapponese%della%scheda%'',@k161=N''%v%pay%'',@k162=N''%codice%di%verifica%'',@k163=N''%visa%electron%'',@k164=N''%visto%'',@k165=N''%card%identification%number%'',@k166=N''%card%verification%'',@k167=N''%cardi%la%verifica%'',@k168=N''cid'',@k169=N''%cod%seg%'',@k170=N''%cod%seguranca%'',@k171=N''%cod%segurança%'',@k172=N''%cod%sicurezza%'',@k173=N''%cod.%seg%'',@k174=N''%cod.%seguranca%'',@k175=N''%cod.%segurança%'',@k176=N''%cod.%sicurezza%'',@k177=N''%codice%di%sicurezza%'',@k178=N''%código%de%seguranca%'',@k179=N''%codigo%'',@k180=N''%codigo%de%seguranca%'',@k181=N''%codigo%de%segurança%'',@k182=N''%crittogramma%'',@k183=N''%cryptogram%'',@k184=N''%cryptogramme%'',@k185=N''%cv2%'',@k186=N''%cvc%'',@k187=N''%cvc2%'',@k188=N''%cvn%'',@k189=N''%cód%seguranca%'',@k190=N''%cód%segurança%'',@k191=N''%cód.%seguranca%'',@k192=N''%cód.%segurança%'',@k193=N''%código%'',@k194=N''%numero%di%sicurezza%'',@k195=N''%código%de%segurança%'',@k196=N''%de%kaart%controle%'',@k197=N''%geeft%nr%uit%'',@k198=N''%issue%no%'',@k199=N''%issue%number%'',@k200=N''%kaartidentificatienummer%'',@k201=N''%kreditkartenprufnummer%'',@k202=N''%kreditkartenprüfnummer%'',@k203=N''%kwestieaantal%'',@k204=N''%no.%dell''''edizione%'',@k205=N''%no.%di%sicurezza%'',@k206=N''%numero%de%securite%'',@k207=N''%numero%de%verificacao%'',@k208=N''%numero%dell''''edizione%'',@k209=N''%numero%di%identificazione%della%scheda%'',@k210=N''%veiligheid%nr%'',@k211=N''%numero%van%veiligheid%'',@k212=N''%numéro%de%sécurité%'',@k213=N''%nº%autorizzazione%'',@k214=N''%número%de%verificação%'',@k215=N''%perno%il%blocco%'',@k216=N''%pin%block%'',@k217=N''%prufziffer%'',@k218=N''%prüfziffer%'',@k219=N''%security%code%'',@k220=N''%security%no%'',@k221=N''%security%number%'',@k222=N''%sicherheits%kode%'',@k223=N''%sicherheitscode%'',@k224=N''%sicherheitsnummer%'',@k225=N''%speldblok%'',@k226=N''%datum%van%exp%'',@k227=N''%veiligheidsaantal%'',@k228=N''%veiligheidscode%'',@k229=N''%veiligheidsnummer%'',@k230=N''%verfalldatum%'',@k231=N''%ablauf%'',@k232=N''%data%de%expiracao%'',@k233=N''%data%de%expiração%'',@k234=N''%data%del%exp%'',@k235=N''%data%di%exp%'',@k236=N''%data%di%scadenza%'',@k237=N''%data%em%que%expira%'',@k238=N''%data%scad%'',@k239=N''%data%scadenza%'',@k240=N''%date%de%validité%'',@k241=N''%datum%afloop%'',@k242=N''%de%afloop%'',@k243=N''%datum%van%exp%'',@k244=N''%espira%'',@k245=N''%espira%'',@k246=N''%exp%date%'',@k247=N''%exp%datum%'',@k248=N''%expiration%'',@k249=N''%expire%'',@k250=N''%expires%'',@k251=N''%expiry%'',@k252=N''%fecha%de%expiracion%'',@k253=N''%fecha%de%venc%'',@k254=N''%gultig%bis%'',@k255=N''%gultigkeitsdatum%'',@k256=N''%gültig%bis%'',@k257=N''%gültigkeitsdatum%'',@k258=N''%scadenza%'',@k259=N''%valable%'',@k260=N''%validade%'',@k261=N''%valido%hasta%'',@k262=N''%valor%'',@k263=N''%venc%'',@k264=N''%vencimento%'',@k265=N''%vencimiento%'',@k266=N''%verloopt%'',@k267=N''%vervaldag%'',@k268=N''%vervaldatum%'',@k269=N''%vto%'',@k270=N''%válido%hasta%'',@k271=N''%tarjeta%crédito%'',@k272=N''%iban%code%'',@k273=N''%iban%num%'',@k274=N''%banking%'',@k275=N''%routing%no%'',@k276=N''%savings%acc%'',@k277=N''%debit%acc%'',@k278=N''iban'',@k279=N''%routing%number%'',@k280=N''aba'',@k281=N''%aba%routing%'',@k282=N''%bank%routing%'',@k283=N''%swift%code%'',@k284=N''%swift%routing%'',@k285=N''%swift%num%'',@k286=N''%bic%code%'',@k287=N''%bic%num%'',@k288=N''%acct%nbr%'',@k289=N''%acct%num%'',@k290=N''%acct%no%'',@k291=N''%bank%acc%'',@k292=N''%account%'',@k293=N''%tax%'',@k294=N''%paypal%'',@k295=N''%payment%'',@k296=N''%insurance%'',@k297=N''%pmt%'',@k298=N''%amount%'',@k299=N''%amt%'',@k300=N''%compensation%'',@k301=N''%currency%'',@k302=N''%invoice%'',@k303=N''%security%'',@k304=N''%personal%'',@k305=N''%last%name%'',@k306=N''%first%name%'',@k307=N''%surname%'',@k308=N''%maiden%name%'',@k309=N''%full%name%'',@k310=N''%passport%'',@k311=N''%pasaporte%'',@k312=N''%tax%id%'',@k313=N''itin'',@k314=N''%driver%'',@k315=N''%identification%'',@k316=N''%identificación%fiscal%'',@k317=N''%identification%'',@k318=N''%id%number%'',@k319=N''%national%id%'',@k320=N''%fuehrerschein%'',@k321=N''%führerschein%'',@k322=N''%fuhrerschein%'',@k323=N''%fuehrerschein%'',@k324=N''%numéro%identité%'',@k325=N''%no%identité%'',@k326=N''%no.%identité%'',@k327=N''%numero%identite%'',@k328=N''%no%identite%'',@k329=N''%no.%identite%'',@k330=N''%le%numéro%d''''identification%nationale%'',@k331=N''%identité%nationale%'',@k332=N''%reisepass%'',@k333=N''%passeport%'',@k334=N''%personalausweis%'',@k335=N''%identifizierungsnummer%'',@k336=N''%ausweis%'',@k337=N''%identifikation%'',@k338=N''%patente%di%guida%'',@k339=N''ssn'',@k340=N''%ss_num%'',@k341=N''%ssnum%'',@k342=N''sin'',@k343=N''%employeessn%'',@k344=N''%social%security%'',@k345=N''%soc%sec%'',@k346=N''ssid'',@k347=N''%insee%'',@k348=N''%securité%sociale%'',@k349=N''%securite%sociale%'',@k350=N''%numéro%de%sécurité%sociale%'',@k351=N''%le%code%de%la%sécurité%sociale%'',@k352=N''%numéro%d''''assurance%sociale%'',@k353=N''%numéro%de%sécu%'',@k354=N''%code%sécu%'',@k355=N''%patient%'',@k356=N''%clinic%'',@k357=N''%medical%'',@k358=N''%treatment%'',@k359=N''%healthcondition%'',@k360=N''%medication%'',@k361=N''%health%'',@k362=N''%prescription%'',@k363=N''%birthday%'',@k364=N''%date%of%birth%'',@k365=N''%birth%date%'',@k366=N''dob''


';

EXEC sp_foreachdb @command = @cmd;

SELECT *
FROM #DataDiscoveryAndClassification
