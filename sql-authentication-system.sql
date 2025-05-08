USE master
GO

  IF EXISTS (SELECT * FROM sys.databases WHERE name = 'HarrysBilar')
	BEGIN 
	ALTER DATABASE HarrysBilar SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE HarrysBilar
	END
	
	CREATE DATABASE HarrysBilar   --Skapar databasen
	GO 

	USE HarrysBilar
	GO

	-- Skapar Users-tabellen, h�r har vi all information om kunden/admin. 

	CREATE TABLE Users(
	UserID INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	Email NVARCHAR(100) UNIQUE NOT NULL,
	FullName NVARCHAR(100) NOT NULL,
	Role NVARCHAR(20) DEFAULT 'Customer' NOT NULL,
	Phone VARCHAR(20) NULL,
	Address NVARCHAR(100) NULL,
	PostalCode NVARCHAR(10) NULL,
	City NVARCHAR(50) NULL,
	Country NVARCHAR(50) NULL,
	PasswordHashed VARBINARY(128) NOT NULL,
	Salt NVARCHAR(100) NOT NULL, 
	FailedLoginAttempts INT NULL,
	VerificationToken NVARCHAR(255) NULL,
	TokenExpiry DATETIME NULL,
	IsVerified BIT NULL,
	IsActive BIT DEFAULT 1 NULL,
	IsLocked BIT DEFAULT 0 NULL,
	CreatedAt DATETIME DEFAULT GETDATE()NOT NULL,
	ValidTo DATETIME NOT NULL,
	)
    
	---Skapar Log-tabellen f�r att logga alla aktiviteter.

	CREATE TABLE Log(
	LogID INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	Email NVARCHAR(100) NOT NULL,
	LogTimestamp DATETIME DEFAULT GETDATE() NOT NULL,
	Success BIT NOT NULL,
	IPAddress NVARCHAR(20) NOT NULL,
	LogMessage NVARCHAR(100) NULL,
	UserID INT FOREIGN KEY REFERENCES Users(UserID)
	)

	
	-- L�gger in v�rden i Users och Log tabellerna. Hashedpassword + salt f�r extra s�ker l�senord hantering. 
	 --NEWID() �r f�r att s�kerst�lla att vi alltid f�r ett unikt salt v�rde.

	 INSERT INTO Users
	 (Email,FullName,Role,Phone,
	 Address,PostalCode,City,Country,
	 PasswordHashed,
	 Salt,FailedLoginAttempts,
	 VerificationToken,TokenExpiry,IsVerified,IsActive,IsLocked,ValidTo)
	 VALUES
	 --ADMIN
	 ('phatsorn.vik@harrysbilar.se','Phatsorn Vik','Admin',0046704536859,
	 'Timotejgatan 4',19447,'Upplands V�sby', 'Sweden',
	 HASHBYTES('SHA2_512','44d8338ef4c8aebd7a7511dbe6b73630' + CONVERT(NVARCHAR(50), NEWID())), 
	 CONVERT(NVARCHAR(50), NEWID()), 0, 
	 NULL, NULL,1,1,0,DATEADD(YEAR, 2, GETDATE())),
	 --CUSTOMER
	 ('erik.eriksson@hotmail.com', 'Erik Eriksson','Customer', 0046706644558, 
	 'Jakobsbergsgatan 14', 11224, 'Stockholm', 'Sweden',
	 HASHBYTES('SHA2_512','687bf0f5792865fb15d6d618997c677e' + CONVERT(NVARCHAR(50), NEWID())),
	 CONVERT(NVARCHAR(50), NEWID()),0,
	 NULL, NULL, 1,1, 0, DATEADD(YEAR, 1, GETDATE())),
	 --CUSTOMER
	 ('sara.nilsson@gmail.com','Sara Nilsson','Customer', 0046734589237,
	 'Gustavstorg 5', 85185,'Sundsvall','Sweden',
	 HASHBYTES('SHA2_512','ea02ee27ac8c9eb60a29210f74b927fc' + CONVERT(NVARCHAR(50), NEWID())),
	 CONVERT(NVARCHAR(50), NEWID()), 0, 
	 NULL, NULL, 1,1, 0, DATEADD(YEAR, 1, GETDATE())),
	 --CUSTOMER
	 ('santos.rodriqes@hotmail.com','Santos Rodriqes','Customer', 0046709875147,
	 'Folkungagatan 3', 41102,'G�teborg','Sweden',
	 HASHBYTES('SHA2_512','8f2ea3d462c85487c54adc1d537e3fd5' + CONVERT(NVARCHAR(50), NEWID())),
	 CONVERT(NVARCHAR(50), NEWID()),0, 
	 NULL, NULL, 1,1, 0, DATEADD(YEAR, 1, GETDATE())),
	 --CUSTOMER
	 ('jackie.chung@hotmail.com','Jackie Chung', 'Customer', 0046763569568,
	 'M�rengatan 62', 80255,'G�vle','Sweden',
	 HASHBYTES('SHA2_512','b421e602986800c49ba92a2e8832b868' + CONVERT(NVARCHAR(50), NEWID())),
	 CONVERT(NVARCHAR(50), NEWID()),0,
	 NULL, NULL,1,1,0, DATEADD(YEAR, 1, GETDATE()))
	 
	 INSERT INTO Log
	 (UserID,Email,Success,IPAddress,LogMessage)
	 VALUES 
	 (1,'phatsorn.vik@harrysbilar.se',1,'192.168.1.1','Success: Login successful'),
	 (2,'erik.eriksson@hotmail.com',1,'193.164.1.2','Success: Login successful'),
	 (3,'sara.nilsson@gmail.com',1,'194.657.3.6','Success: Login successful'),
	 (4,'santos.rodriqes@hotmail.com',1,'195.456.3.2','Success: Login successful'),
	 (5,'jackie.chung@hotmail.com',1,'196.875.4.7','Success: Login successful')
	 
----------------------------------------------------------------------------------------------------------------------------------------------------------------

	 -- Skapar en view med cte f�r ta fram anv�ndares loginformation, senaste datum f�r lyckade 
	 -- samt misslyckade inloggninar. Anv�nder MAX() f�r att f� fram senaste datumet 
	 -- och CASE WHEN n�r lyckade inloggning Success = 1 och misslyckade inloggning Success = 0. 
	 -- H�mtar sedan email, kundnamn, senaste lyckade inloggning och senaste misslyckad inloggning.
	 GO
	 CREATE OR ALTER VIEW UsersLogInformation AS 
		WITH LatestLogStatus_CTE AS (
			SELECT 
				 UserID,
				MAX(CASE WHEN Success = 1 THEN LogTimestamp ELSE NULL END) AS LastSuccessLogin,
				MAX(CASE WHEN Success = 0 THEN LogTimestamp ELSE NULL END) AS LastFailedLogin
			FROM Log
			GROUP BY UserID
		)
			SELECT 
			u.UserID,
				u.Email,
				u.FullName,
				lls.LastSuccessLogin,
				lls.LastFailedLogin
			FROM Users u
			LEFT JOIN LatestLogStatus_CTE lls ON u.UserID = lls.UserID
	GO
		-- H�mtar alla kolumner och rader fr�n vyn.
		SELECT * FROM UsersLogInformation

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Skapar en view med en window funktion d�r jag tar fram anv�ndarens login detailjer, lyckade/misslyckade inloggningar 
	--och genomsnittligt lyckadeinloggningar per IPaddressen. 
	--Tabellen visar totala f�rs�k, lyckade och misslyckade inloggningar,
	--samt genomsnittet p� de lyckade inloggningen.
	GO
		CREATE OR ALTER VIEW UserLoginDetails AS
		SELECT UserID,
		Email,
		IPAddress,
		LogTimestamp,
		COUNT(*) OVER(PARTITION BY IPAddress ORDER BY LogTimestamp) AS TotalAttemps, 
		SUM(CASE WHEN Success = 1 THEN 1 ELSE 0 END) OVER 
			(PARTITION BY IPAddress ORDER BY LogTimestamp) AS SuccessLogin,
		SUM(CASE WHEN Success = 0 THEN 1 ELSE 0 END) OVER 
			(PARTITION BY IPAddress ORDER BY LogTimestamp) AS FailedLogin,
		AVG(CASE WHEN Success = 1 THEN 1.0 ELSE 0 END) OVER
			(PARTITION BY IPAddress ORDER BY LogTimestamp) AS AverageSuccessRate
		FROM Log 
		
	GO
	-- H�mtar alla kolumner och rader fr�n vyn. Sorterar i stigande ordning.
	SELECT* FROM UserLoginDetails
	ORDER BY LogTimestamp 

----------------------------------------------------------------------------------------------------------------------------------------------------------------

	--Skapar stored procedures f�r trylogin email,password och ipaddress.
	--Returnerar felkoder ifall det inte gick. 
	--Om man misslyckats med att logga in tre g�nger de senaste 15 minuterna kommer man 
	--inte in oavsett om man skriver r�tt l�senord eller inte.
    --Allt lagras i loggtabellen och loggar sparas �ven i en tempor�r tabell, 
	--som kan anv�ndas f�r testning.
	GO
		CREATE OR ALTER PROCEDURE GetTryLogin 
			@Email NVARCHAR(255),
			@Password NVARCHAR(255),
			 @IPAddress NVARCHAR(255)
	AS
	BEGIN 
		SET NOCOUNT ON; -- F�rhindrar att SQL Server retunerar extra statusmeddelande, vilket g�r det mer effektivt.

    -- Skapa en tempor�r tabell 
		 CREATE TABLE #LogTable (
			LogID INT IDENTITY(1,1),
			Email NVARCHAR(255),
			LogTimestamp DATETIME,
			IPAddress NVARCHAR(50),
			LogMessage NVARCHAR(255)
    )
		--Deklarerar variabler
		DECLARE @UserID INT
		DECLARE @StoredPassword VARBINARY(128)
		DECLARE @Salt NVARCHAR(255)
		DECLARE @FailedAttempts INT
		DECLARE @IsLocked BIT
		DECLARE @InputPassword VARBINARY(128)
		DECLARE @LogMessage NVARCHAR(255)

    -- H�mta information
		SELECT @UserID = u.UserID,
           @StoredPassword = u.PasswordHashed,
           @Salt = u.Salt,
           @FailedAttempts = u.FailedLoginAttempts,
           @IsLocked = u.IsLocked
		FROM Users u
		WHERE u.Email = @Email

    -- Kontrollera om anv�ndaren finns. Om inte anv�ndaren finns loggas felmeddelandet och returnerar felkod 1. 
	-- Sparas i #LogTable och Log-tabellen.
    IF @UserID IS NULL
    BEGIN 
        SET @LogMessage = 'ERROR: User not found.'

        INSERT INTO #LogTable (Email, LogTimestamp, IPAddress, LogMessage)
        VALUES (@Email, GETDATE(), @IPAddress, @LogMessage)

        INSERT INTO Log (UserID, Email, IPAddress, LogTimestamp, Success, LogMessage)
        VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @LogMessage)

        PRINT @LogMessage
		-- H�mtar datan fr�n #LogTable innan RETURN, annars syns den inte eftersom att tempor�ra tabeller
		-- raderas automatiskt efter att proceduren avslutas.
        SELECT * FROM #LogTable
		--slutar exekveringen av proceduren
        RETURN 1
    END

    -- Kontrollera om kontot �r l�st. Skriv ut felmeddelandet och retunerar felkod 2.
	-- Sparas i #LogTable och Log-tabellen.
    IF @IsLocked = 1
    BEGIN
        SET @LogMessage = 'ERROR: User is locked due to multiple failed attempts.'

        INSERT INTO #LogTable (Email, LogTimestamp, IPAddress, LogMessage)
        VALUES (@Email, GETDATE(), @IPAddress, @LogMessage)

        INSERT INTO Log (UserID, Email, IPAddress, LogTimestamp, Success, LogMessage)
        VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @LogMessage)

        PRINT @LogMessage
        SELECT * FROM #LogTable
        RETURN 2
    END

    -- R�kna misslyckade inloggningsf�rs�k under de senaste 15 minuterna.
    SELECT @FailedAttempts = COUNT(*)
    FROM Log
    WHERE UserID = @UserID 
          AND Success = 0 
          AND LogTimestamp >= DATEADD(MINUTE, -15, GETDATE())

    -- Om fler �n 3 misslyckade f�rs�k -> l�s kontot. Skriver ut felmeddelandet och returnerar felkod 3.
	-- Sparas i #LogTable och Log-tabellen.
    IF @FailedAttempts >= 3
    BEGIN
        SET @LogMessage = 'ERROR: Too many failed attempts. User account is locked. 
		Please contact admin phatsorn.vik@harrysbilar.se'

        INSERT INTO #LogTable (Email, LogTimestamp, IPAddress, LogMessage)
        VALUES (@Email, GETDATE(), @IPAddress, @LogMessage)

        INSERT INTO Log (UserID, Email, IPAddress, LogTimestamp, Success, LogMessage)
        VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @LogMessage)
        
        UPDATE Users SET IsLocked = 1 WHERE UserID = @UserID

		-- Anv�ndaren �r l�ngre inte activ.
		UPDATE Users SET IsActive = 0 WHERE UserID = @UserID

        PRINT @LogMessage

        SELECT * FROM #LogTable
        RETURN 3
    END

    -- Hasha inmatat l�senord
    SET @InputPassword = HASHBYTES('SHA2_512', @Password + @Salt)

    -- Om l�senordet �r fel, skriver ut felmeddelandet och returnerar felkod 4.
	-- Sparas i #LogTable och Log-tabellen.
    IF @InputPassword != @StoredPassword
    BEGIN
        SET @LogMessage = 'ERROR: Incorrect password'

        INSERT INTO #LogTable (Email, LogTimestamp, IPAddress, LogMessage)
        VALUES (@Email, GETDATE(), @IPAddress, @LogMessage)

        INSERT INTO Log (UserID, Email, IPAddress, LogTimestamp, Success, LogMessage)
        VALUES (@UserID, @Email, @IPAddress, GETDATE(), 0, @LogMessage)

        -- �ka misslyckade f�rs�k
        UPDATE Users 
		SET FailedLoginAttempts = FailedLoginAttempts + 1 
		WHERE UserID = @UserID

        PRINT @LogMessage
        SELECT * FROM #LogTable
        RETURN 4
    END

    -- Lyckad inloggning, skriver ut en lyckad meddelande och returnerar 0.
	-- Sparas i #LogTable och Log-tabellen.
    SET @LogMessage = 'Success: Login successful'

    INSERT INTO #LogTable (Email, LogTimestamp, IPAddress, LogMessage)
    VALUES (@Email, GETDATE(), @IPAddress, @LogMessage)

    INSERT INTO Log (UserID, Email, IPAddress, LogTimestamp, Success, LogMessage)
    VALUES (@UserID, @Email, @IPAddress, GETDATE(), 1, @LogMessage)

    -- �terst�ller misslyckade f�rs�k.
    UPDATE Users SET FailedLoginAttempts = 0 WHERE UserID = @UserID


    PRINT @LogMessage
	
    SELECT * FROM #LogTable
	RETURN 0

	END

	--Kallar p� procedure
	EXEC GetTryLogin 'erik.eriksson@hotmail.com', '2b5ad70b7d59f41981ece316202d8da9', '193.164.1.2' --OBS FEL L�SENORD
	EXEC GetTryLogin 'sara.nilsson@gmail.com', 'ea02ee27ac8c9eb60a29210f74b927fc', '194.657.3.6' --OBS FEL L�SENORD
	EXEC GetTryLogin 'user@example.com', 'hello1234', '194.456.3.2'--OBS USER NOT FOUND

	-- H�r kan vi kontrollerar inloggningsloggen. Samt se i Users-tabellen att FailedLoginAttemps har uppdateras.
	SELECT * FROM Log
	SELECT * FROM Users

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	-- Skapar en procedure GetForgotPassword, med en input email. Den ska skapa och lagra token.
	GO
		CREATE OR ALTER PROCEDURE GetForgotPassword
			@Email NVARCHAR(100)
	
	AS
	BEGIN 
		
		SET NOCOUNT ON -- F�rhindrar att SQL Server returnerar extra statusmeddelande, vilket g�r det mer effektivt.

		-- Deklarera variabler f�r att kontrollera om e-posten finns i databasen, om det finns ett befintligt token, 
		--skapar en unik kod f�r @NewToken och ber�knar tokenets utg�ngstid, som ska vara giltig i 24 timmar.
	
		DECLARE @UserID INT, @ExistingToken NVARCHAR(100), @CurrentTime DATETIME = GETDATE()
		DECLARE @NewToken NVARCHAR(100) = CONVERT(NVARCHAR(100), NEWID())
		DECLARE @TokenExpiry DATETIME = DATEADD(HOUR, 24, @CurrentTime)

		 --H�mtar information
		SELECT @UserID = UserID, 
				@ExistingToken = VerificationToken
		FROM Users
		WHERE Email = @Email

	IF @UserID IS NULL -- Om anv�ndaren inte finns, skriv ett meddelande och returnera felkod 1.
	BEGIN 
		PRINT 'ERROR: User not found!'
		RETURN 1
	END
	 -- Kontrollerar om det finns ett aktivt token och att den inte har g�tt ut. Om det finns returnera felkod 2.
	IF @ExistingToken IS NOT NULL AND @TokenExpiry > @CurrentTime
	BEGIN
		PRINT 'ERROR: Password reset already requested. Try again later.'
		RETURN 2
	END

	ELSE
	BEGIN
	    -- Skapar nytt token och lagrar det. Uppdaterar anv�ndarens 
		--VerificationToken med @NewToken, s�tter TokenExpiry till 24 timmar fr�n och med nu. 
		-- Skriver ut en bekr�ftelse och returnerar 0.
		UPDATE Users
		SET VerificationToken = @NewToken,
			TokenExpiry = @TokenExpiry
		WHERE UserID = @UserID

		PRINT 'Success! Password reset token generated .'
		RETURN 0
	END
	END
	--Kallar p� proceduren f�r en anv�ndaren erik.eriksson@homtail.com och token har generats.
	
	EXEC GetForgotPassword @Email = 'erik.eriksson@hotmail.com'

	--H�r ser vi att Erik Eriksson har blivit tilldelad en verficationtoken och expirytoken.
	SELECT * FROM Users

-----------------------------------------------------------------------------------------------------------------------------------------------------------

    --Skapar en procedure f�r att �terst�lla ett gl�mt l�senord. 
	--Den ska verifiera att den givna verifieringstoken �r korrekt och giltigt innan den uppdaterar l�senordet.
	GO
		CREATE OR ALTER PROCEDURE GetSetForgottenPassword	
			@Email NVARCHAR(100),
			@NewPassword NVARCHAR(255),
			@Token NVARCHAR(50)
	AS
	BEGIN
		SET NOCOUNT ON-- F�rhindrar att SQL Server returnerar extra statusmeddelande, vilket g�r det mer effektivt.

		-- Deklarerar variabler  
		DECLARE @StoredToken NVARCHAR(255)
		DECLARE @TokenExpiry DATETIME
		DECLARE @UserID INT

		-- H�mtar information.
		SELECT @UserID = UserID,
				@StoredToken = VerificationToken,
				@TokenExpiry = TokenExpiry
		FROM Users
		WHERE Email = @Email

		-- Om anv�ndaren inte finns, skriver ut felmeddelande och returnera 1.
		IF @UserID IS NULL
	BEGIN
		PRINT'ERROR: Email not found.'
		RETURN 1
	END

		-- Kontrollerar om token saknas eller �r felaktig. Om token inte finns eller inte matchar returneras felkod 2.
	IF @StoredToken IS NULL OR @StoredToken <> @Token
	BEGIN
		PRINT 'ERROR: Invalid or missing token. '
		RETURN 2
	END
		-- Kontrollerar om token har g�tt ut, genom att j�mf�ra med nuvarande tid. Om Token har g�tt ut returneras felkod 3.
		IF @TokenExpiry < GETDATE()
	BEGIN
		PRINT 'ERROR: Token has expired'
		RETURN 3
	END
	ELSE
	BEGIN
		-- Skapar ett nytt salt och kombinerar det nya l�senordet med saltet och hashar det.
		DECLARE @NewSalt NVARCHAR(50) = CONVERT(NVARCHAR(50), NEWID())
		DECLARE @NewPasswordHashed VARBINARY(128) = HASHBYTES('SHA2_512', @NewPassword + @NewSalt)

		-- Uppdaterar den nya l�senordet och rensar tokenen s� att den inte �teranv�nds. 
		--Skriver ut att l�senordet har �ndrats och returnerar 0.
		UPDATE Users
		SET PasswordHashed = @NewPasswordHashed,
		Salt = @NewSalt,
		VerificationToken = NULL,
		TokenExpiry = NULL
		WHERE UserID = @UserID

		PRINT 'Sucess! Password has been reset'
		RETURN 0
	END
	END
		--Kallar p� proceduren f�r anv�ndaren erik.eriksson@hotmail.com, nya l�senordet och verifieringstoken.
		--OBS!!--F�r testning, byt ut r�tt verifieringstoken.
	EXEC GetSetForgottenPassword 'erik.eriksson@hotmail.com', '2b5ad70b7d59f41981ece316202d8da9', '16C89476-49C8-44CF-BAE5-7FF0F20E1CA4'

	-- H�r kan vi se att Erik Eriksson verfieringstoken �r nu NULL.
	SELECT * FROM Users
	WHERE Email = 'erik.eriksson@hotmail.com'

----------------------------------------------OPTIMERING------------------------------------------------------
	
	SET STATISTICS IO, TIME ON
	SELECT * 
	FROM Users u
	LEFT JOIN Log l ON u.UserID = l.UserID
	WHERE u.email = 'erik.eriksson@hotmail.com' AND IPAddress = '195.456.3.2'
	SET STATISTICS TIME OFF
	
	CREATE NONCLUSTERED INDEX Index_UsersIPAddress
    ON Log (IPAddress)

	CREATE NONCLUSTERED INDEX Index_UsersEmail
    ON Users (Email)

	