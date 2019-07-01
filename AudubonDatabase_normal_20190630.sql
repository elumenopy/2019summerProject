/*
 * 6/28-29/2019   Audubon data file
 * 6/30/2019      Create BULK INSERT files: data_Birds.txt
 *                                          data_ConservationStatuses.txt 
 *                                          data_DigitalFileTypes.txt
 *                                          data_Families.txt
 *                                          data_Habitats.txt
 *                                          data_Orders.txt
 *                                          data_ResidencyStatuses.txt 
 *                DDL CREATE TABLES: Birders
 *                                   Sightings
 *                                   Orders
 *                                   Families
 *                                   Birds
 *                                   ConservationStatuses
 *                                   ResidencyStatuses
 *                                   BirdResidencies   /* need junction for birds with >1 residency */
 *                                   DigitalFileTypes
 *                                   DigitalFiles      /* need junction for multiple media files of same type */
 *                                   Habitats
 *                DML BULK INSERT: ConservationStatuses
 *                                 ResidencyStatuses
 *                                 DigitalFileTypes
 *                                 Orders
 *                                 Families
 *                                 Birds
 *                                 BirdResidencies
 *                                 Habitats
 *                DML INSERT INTO: Birders
 *                                 Sightings
 *                DML SELECT QUERIES: View birds of prey
 *                                    View ducks, geese and waterfowl
 *                                    View birds referred to as a "duck"
 *                                    View hummingbirds
 *                                    View threatened species
 *                                    View all sightings
 *                                    View media files for a sighting
 *                                    View all migratory birds
 *                                    View all sightings of migratory birds
 *                                    View each table
 */



/************************************
 * DLL: Database and table creation
 ************************************/

USE master;
GO

CREATE DATABASE WashingtonBirds_normal;
GO

USE WashingtonBirds_normal;
GO

CREATE TABLE Birders
(
	BirderId int IDENTITY NOT NULL CONSTRAINT PK_Birders PRIMARY KEY,
	FirstName nvarchar(50) NOT NULL, -- !NOTE: first/last names allow international characters
	LastName nvarchar(50) NOT NULL,
	Email varchar(50) NULL,
	Phone char(10) NULL
);
GO

CREATE TABLE ConservationStatuses
(
	StatusShort char(2) NOT NULL CONSTRAINT PK_ConservationStatuses PRIMARY KEY,
	StatusLong varchar(50) NOT NULL,
	Category varchar(50) NOT NULL,
	[Description] varchar(255) NOT NULL
);
GO

CREATE TABLE ResidencyStatuses
(
	StatusShort varchar(2) NOT NULL CONSTRAINT PK_ResidencyStatuses PRIMARY KEY,
	StatusLong varchar(30) NOT NULL,
	[Description] varchar(255) NOT NULL
);
GO

CREATE TABLE DigitalFileTypes
(
	FileType varchar(10) NOT NULL CONSTRAINT PK_DigitalFileTypes PRIMARY KEY
);
GO

CREATE TABLE DigitalFiles
(
	FileId int IDENTITY NOT NULL CONSTRAINT PK_DigitalFiles PRIMARY KEY,
	FileType varchar(10) NOT NULL CONSTRAINT FK_DigitalFiles_DigitalFileTypes FOREIGN KEY REFERENCES DigitalFileTypes,
	FileBinary VARBINARY(MAX) NOT NULL,
	FileSize int NOT NULL,
	Citation nvarchar(1000) NOT NULL,      -- using NVARCHAR b/c encountered many citations using international characters
	[Description] nvarchar(1000) NOT NULL, -- using NVARCHAR b/c to allow for international characters
	-- !IMPORTANT:  add SightingId foreign key field after CREATING Sightings table
	-- SightingId int NULL CONSTRAINT FK_DigitalFiles_Sightings FOREIGN KEY REFERENCES Sightings
);
GO

CREATE TABLE Orders
(
	OrderId int IDENTITY NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
	[Order] varchar(50) NOT NULL
);
GO

CREATE TABLE Families
(
	FamilyId int IDENTITY NOT NULL CONSTRAINT PK_Families PRIMARY KEY,
	Family varchar(50) NOT NULL,
	CommonName varchar(100) NOT NULL,
	NavigationName varchar(100) NOT NULL,
	[Description] varchar(4000) NOT NULL,
	OrderId int NOT NULL CONSTRAINT FK_Families_Orders FOREIGN KEY REFERENCES Orders
);
GO

CREATE TABLE Birds
(
	BirdId int IDENTITY NOT NULL CONSTRAINT PK_Birds PRIMARY KEY,
	-- SCIENTIFIC NAME
	FamilyId int NOT NULL CONSTRAINT FK_Birds_Families FOREIGN KEY REFERENCES Families,
	Genus varchar(50) NOT NULL,
	Species varchar(50) NOT NULL,
	CommonName varchar(50) NOT NULL,
	-- RESIDENCY
	ResidencyNotes varchar(5000) NULL,
	-- CONSERVATION STATUS
	ConservationStatus char(2) NULL
	                   CONSTRAINT FK_Birds_ConservationStatuses FOREIGN KEY REFERENCES ConservationStatuses,
	ConservationStatusNotes varchar(3000) NULL,
	-- DESCRIPTIONS
	Identification varchar(5000) NULL,
	Voice varchar(5000) NULL,
	is_WashingtonBird bit NOT NULL,
	Habitat varchar(5000) NULL,
	where_Found varchar(5000) NULL,
	Behavior varchar(5000) NULL,
	Diet varchar(5000) NULL,
	Breeding varchar(5000) NULL,
	Nesting varchar(5000) NULL,
	Migration varchar(5000) NULL,
	-- SEATTLE AUDUBON SOCIETY WEBSITE
	url_Name varchar(150) NOT NULL, -- !IMPORTANT: append to end of www.seattleaudubon.org/birdweb/bird/
	AlphaCode char(4) NULL,
	-- DIGITAL FILES
	-- !IMPORTANT: only one file allowed for each of the following, so stitch together files when showing differences between male/female
	FileIdAudio int NULL CONSTRAINT FK_Birds_DigitalFiles_audio FOREIGN KEY REFERENCES DigitalFiles, -- audio files .wav, .mp3, .aiff
	FileIdImage int NULL CONSTRAINT FK_Birds_DigitalFiles_image FOREIGN KEY REFERENCES DigitalFiles, -- image files .gif, .jpg, .jpeg, .png, .tif, .tiff
	FileIdVideo int NULL CONSTRAINT FK_Birds_DigitalFiles_video FOREIGN KEY REFERENCES DigitalFiles, -- video files .mp4, .mov, .wmv
 );
 GO

 CREATE TABLE BirdResidencies
(
	BirdId int NOT NULL CONSTRAINT FK_BirdResidencies_Birds FOREIGN KEY REFERENCES Birds,
	BirdResidency varchar(2) NOT NULL CONSTRAINT FK_BirdResidencies_ResidencyStatuses FOREIGN KEY REFERENCES ResidencyStatuses
);
GO

CREATE TABLE Habitats
(
	HabitatId int IDENTITY NOT NULL CONSTRAINT PK_Habitats PRIMARY KEY,
	[Type] varchar(50) NOT NULL CONSTRAINT CK_Habitats_Type CHECK([Type] IN ('Terrestrial','Freshwater','Marine')),
	Classification varchar(50) NOT NULL
	-- !NOTE:  The terrestrial vegetation type may be forest, steppe, grassland, semi-arid or desert.
	--         Fresh water habitats include marshes, streams, rivers, lakes, and ponds.
	--         Marine habitats include salt marshes, the coast, the intertidal zone, estuaries, reefs, bays, the open sea, the sea bed, deep water and submarine vents.
);
GO

CREATE TABLE Sightings
(
	SightingId int IDENTITY NOT NULL CONSTRAINT PK_Sightings PRIMARY KEY,
	BirderId int NOT NULL CONSTRAINT FK_Sightings_Birders FOREIGN KEY REFERENCES Birders,
	BirdId int NOT NULL CONSTRAINT FK_Sightings_Birds FOREIGN KEY REFERENCES Birds,
	HabitatId int NOT NULL CONSTRAINT FK_Sighting_Habitats FOREIGN KEY REFERENCES Habitats,
	NumberOfBirds int NOT NULL,
	DistanceFromBirds int NOT NULL, -- !ALERT: Metric or Imperial? Pick one and convert in application.
	[Date] date NOT NULL,
	[Time] time NULL,
	PlaceName varchar(50) NOT NULL, -- examples: Capitol State Forest, Nisqually National Wildlife Refuge 
	City varchar(50) NOT NULL,      -- !IMPORTANT: City/County/State may not apply to open water habitats
	County varchar(50) NOT NULL,
	[State] char(2) NOT NULL,
	GeoLatitude decimal(9,6) NULL,   -- WA latitude = 47.751076 (scale of 5 accurate to 1m, 6 is 10cm)
	GeoLongitude decimal(10,6) NULL, -- WA longitude = -120.740135
	ObservationNotes varchar(255) NOT NULL
	-- VerifiedByWOS bit NULL        -- sighting validated by outside source
);
GO

-- add Sightings foreign key field to DigitalFiles table
ALTER TABLE DigitalFiles
ADD SightingId int NULL CONSTRAINT FK_DigitalFiles_Sightings FOREIGN KEY REFERENCES Sightings;
GO



/************************************
 * DML: Data entry
 ************************************/

USE master;
GO

USE WashingtonBirds_normal;
GO

BULK INSERT Orders
	FROM 'C:\Users\August\Downloads\data_Orders.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT Families
	FROM 'C:\Users\August\Downloads\data_Families.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT ConservationStatuses
	FROM 'C:\Users\August\Downloads\data_ConservationStatuses.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT ResidencyStatuses
	FROM 'C:\Users\August\Downloads\data_ResidencyStatuses.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT DigitalFileTypes
	FROM 'C:\Users\August\Downloads\data_DigitalFileTypes.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT Habitats
	FROM 'C:\Users\August\Downloads\data_Habitats.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

BULK INSERT Birds
	FROM 'C:\Users\August\Downloads\data_Birds.txt' -- !IMPORTANT: change filepath
	WITH (FIELDTERMINATOR = '\t',ROWTERMINATOR = '\n');
GO

-- birders
INSERT INTO Birders(FirstName, LastName, Email, Phone)
VALUES ('Ace','Ventura','ace.ventura@petdetective.com','7862021994'),
       ('Dr. John','Dolittle','doctor.dolittle@scientist.com','4156261998'),
	   ('Corky','Romano','cromano@pissant.com','2121122001'),
	   ('Maya','Dolittle','maya.dolittle@veterinary.com','4153042008'),
	   ('Mary Beth Ella', 'Gertrude', 'cinderella@disney.com','2132151950'),
	   ('Dorothy','Gale','wizardofoz@disney.com','6208251939');
GO

-- sighting
INSERT INTO Sightings(BirderId, BirdId, HabitatId, NumberOfBirds, DistanceFromBirds, [Date], [Time],
                      PlaceName, City, County, [State], GeoLatitude, GeoLongitude, ObservationNotes)
VALUES (1,252,7,1,40,'6/25/2019','12:28 PM','Tumwater Falls Park','Tumwater','Thurston','WA', 47.015028, -122.904951,'Observed fishing at the base of southern most fall');
GO



/************************************
 * DML: Select Queries
 ************************************/

-- view birds of prey
SELECT 'Birds of Prey' AS BirdType, Birds.* FROM Birds WHERE FamilyId IN
	(SELECT FamilyId FROM Families WHERE OrderId IN
		(SELECT OrderId FROM Orders WHERE [Order] = 'Accipitriformes'));

-- view ducks, geese and waterfowl
SELECT 'Ducks, geese and waterfowl' AS BirdType, Birds.* FROM Birds WHERE FamilyId IN
	(SELECT FamilyId FROM Families WHERE OrderId IN
		(SELECT OrderId FROM Orders WHERE [Order] = 'Anseriformes'));

-- view birds that are commonly referred to as a "duck"
SELECT 'Ducks' AS BirdType, Birds.* FROM Birds WHERE CommonName LIKE ('%duck%');

-- view hummingbirds
SELECT 'Hummingbirds' AS BirdType, Birds.* FROM Birds WHERE FamilyId IN
	(SELECT FamilyId FROM Families WHERE CommonName = 'Hummingbirds');

-- view birds that have a Conservation Status of "threatened"
SELECT 'Threatened Species' AS ConserationStatus, Birds.* FROM Birds WHERE ConservationStatus IN
	(SELECT StatusShort FROM ConservationStatuses WHERE Category = 'Threatened');

-- view all sightings
SELECT br.FirstName + ' ' + br.LastName AS Birder,
       b.CommonName AS Bird,
	   h.Classification + ': ' + h.[Type] AS Habitat,
	   s.NumberOfBirds, s.DistanceFromBirds, s.[Date], s.[Time], s.PlaceName, s.City, s.County, s.[State], s.GeoLatitude, s.GeoLongitude, s.ObservationNotes
	FROM Sightings s, Birders br, Birds b, Habitats h
    WHERE s.BirderId = br.BirderId
	      AND s.BirdId = b.BirdId
		  AND s.HabitatId = h.HabitatId;

-- view media files for a sighting
SELECT * FROM DigitalFiles WHERE SightingId = 1;

-- view all migratory birds
SELECT * FROM Birds WHERE BirdId IN
	(SELECT BirdId FROM BirdResidencies WHERE BirdResidency = 'M'); -- returns empty table b/c no migratory birds entered in BirdResidencies

-- view all sightings of migratory birds
SELECT * FROM Sightings WHERE BirdId IN
	(SELECT BirdId FROM BirdResidencies WHERE BirdResidency = 'M'); -- returns empty table b/c no migratory birds entered in BirdResidencies

-- view all tables
SELECT * FROM Birders;
SELECT * FROM Sightings;
SELECT * FROM Habitats;
SELECT * FROM Birds;
SELECT * FROM Orders;
SELECT * FROM Families;
SELECT * FROM ResidencyStatuses;
SELECT * FROM BirdResidencies;
SELECT * FROM ConservationStatuses;
SELECT * FROM DigitalFiles;
SELECT * FROM DigitalFileTypes;