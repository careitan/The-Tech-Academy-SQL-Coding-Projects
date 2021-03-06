/* The Tech Academy - SQL Library System project All-in-One Build
/  Author:  Allan Reitan
/  Based on combination of seperate TSQL Scripts to automate the Build, Insert, and SPROCS
/  For use with MS SQL Server version 2014 or newer
/ -------------------------------------------------------
/
/	BUILD DB AND TABLE STRUCTURE
/
/ -------------------------------------------------------*/

USE master
IF EXISTS(select * from sys.databases where name='db_Library')
DROP DATABASE db_Library

CREATE DATABASE db_Library;
GO

USE [db_Library]

IF OBJECT_ID('dbo.BOOK_LOANS', 'U') IS NOT NULL
	DROP TABLE BOOK_LOANS, BOOK_COPIES, BORROWER, LIBRARY_BRANCH, BOOK_AUTHORS, BOOKS, PUBLISHER;
GO

CREATE TABLE PUBLISHER
(
	PublisherName varchar(128) PRIMARY KEY NOT NULL
	,Address varchar(128) NOT NULL
	,Phone varchar(24) NOT NULL
);

CREATE TABLE BOOKS
(
	BookID INT PRIMARY KEY NOT NULL IDENTITY(1000,1)
	,Title varchar(250) NOT NULL
	,PublisherName varchar(128) NOT NULL CONSTRAINT fk_Publisher_Books FOREIGN KEY REFERENCES PUBLISHER(PublisherName) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE BOOK_AUTHORS
(
	BookID INT CONSTRAINT fk_Books_BookAuthors FOREIGN KEY REFERENCES BOOKS(BookID) ON UPDATE CASCADE ON DELETE CASCADE
	,AuthorName varchar(64) NOT NULL
);

CREATE TABLE LIBRARY_BRANCH
(
	BranchID INT PRIMARY KEY NOT NULL IDENTITY(5000,1)
	,BranchName varchar(128) NOT NULL
	,Address varchar(128) NOT NULL
);

CREATE TABLE BORROWER
(
	CardNo INT PRIMARY KEY NOT NULL IDENTITY(1,1)
	,Name varchar(128) NOT NULL
	,Address varchar(128) NOT NULL
	,Phone varchar(24) NOT NULL
);

CREATE TABLE BOOK_COPIES
(
	BookID INT NOT NULL CONSTRAINT fk_Books_BookCopies FOREIGN KEY REFERENCES BOOKS(BookID) ON UPDATE CASCADE ON DELETE CASCADE
	,BranchID INT NOT NULL CONSTRAINT fk_LibraryBranch_BookCopies FOREIGN KEY REFERENCES LIBRARY_BRANCH(BranchID) ON UPDATE CASCADE ON DELETE CASCADE
	,Number_Of_Copies INT NOT NULL DEFAULT((ABS(CHECKSUM(NEWID()))%6 + 2))
	,CONSTRAINT ck_UnsignedIntCopies CHECK (Number_Of_Copies >= 0)
	,CONSTRAINT uk_BooksBranch UNIQUE(BookID, BranchID)
);

CREATE TABLE BOOK_LOANS
(
	BookID INT NOT NULL CONSTRAINT fk_Books_BookLoans FOREIGN KEY REFERENCES BOOKS(BookID) ON UPDATE CASCADE ON DELETE CASCADE
	,BranchID INT NOT NULL CONSTRAINT fk_LibraryBranch_BookLoans FOREIGN KEY REFERENCES LIBRARY_BRANCH(BranchID) ON UPDATE CASCADE ON DELETE CASCADE
	,CardNo INT NOT NULL CONSTRAINT fk_Borrower_BookLoans FOREIGN KEY REFERENCES BORROWER(CardNo) ON UPDATE CASCADE ON DELETE CASCADE
	,DateOut DATE NOT NULL DEFAULT(GETDATE())
	,DateDue DATE NOT NULL DEFAULT(DATEADD(d,30,GETDATE()))
	,CONSTRAINT ck_Valid_DueDate CHECK(DateDue > DateOut)
);

PRINT 'db_Library has been built';
GO

/* -------------------------------------------------------
/
/	INSERT and POPULATE Data for the exercise questions
/
/ -------------------------------------------------------*/

USE [db_Library]
GO

/* Baseline population of the Publisher Table */

INSERT INTO [dbo].PUBLISHER
(
	PublisherName, Address, Phone
)
SELECT 	'MIT Press'	,	'1776 Liberty Road	'	,	'(212)-555-1234	'	UNION
SELECT 	'Harvard Press'	,	'1680 Puritanical Blvd	'	,	'(212)-555-1235	'	UNION
SELECT 	'Simon and Schuster'	,	'666 New World Order Tower	'	,	'(212)-555-1236	'	UNION
SELECT 	'Penguin Books'	,	'32 Below Antartica	'	,	'(212)-555-1237	'	UNION
SELECT 	'Bantam Books'	,	'12 Round Drive	'	,	'(212)-555-1238	'	UNION
SELECT 	'Windsor Publishing'	,	'1066 Hastings Way	'	,	'(212)-555-1239	'	UNION
SELECT 	'Oxford Publishers'	,	'1562 Elizabeth Ave	'	,	'(212)-555-1240	'	UNION
SELECT 	'Dark Winds Press'	,	'1313 Elm St	'	,	'(212)-555-1241	';

/* Baseline population of the Borrower table by using the Cross Join method of randomizing names. */

WITH A (fname, lname) AS
(
	SELECT 'John', 'Beattle' UNION
	SELECT 'Paul', 'Tuttle' UNION
	SELECT 'George', 'Anderson' UNION
	SELECT 'Ringo', 'Davis' UNION
	SELECT 'Tina', 'Jefferson' UNION
	SELECT 'Lahua', 'Smith' UNION
	SELECT 'Kawai', 'Jones' UNION
	SELECT 'Cindy', 'Ruiz' UNION
	SELECT 'Bethany', 'Dalton'
)
INSERT INTO [dbo].BORROWER
( Name, [Address], Phone)
SELECT 
	A.fname + ' ' + B.lname
	,CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Somewhere Road'
	,CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%900 + 100)) + '-' + CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%900+100)) + '-' + CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%9000+1000))
FROM A CROSS JOIN A B;

/* Baseline population of the Branch locations with randomly generated addresses */

WITH A (Branch, Addr) AS
(
	SELECT 'Central', CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Cityville Avenue' UNION
	SELECT 'Belltown', CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Cityville Avenue' UNION
	SELECT 'Eastside', CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Cityville Avenue' UNION
	SELECT 'Sharpstown', CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Cityville Avenue' UNION
	SELECT 'Uptown', CONVERT(varchar(max),(ABS(CHECKSUM(NEWID()))%5000 + 1)) + ' Cityville Avenue'
)
INSERT INTO LIBRARY_BRANCH
( BranchName, [Address] )
SELECT Branch, Addr FROM A;

/* Baseline population of the books table */

INSERT INTO BOOKS
( Title, PublisherName )
SELECT 	'The Lost Tribe'	,	'MIT Press'	UNION
SELECT 	'The Green Mile'	,	'Simon and Schuster'	UNION
SELECT 	'The Shawshank Redemption'	,	'Simon and Schuster'	UNION
SELECT 	'Old Man and the Sea'	,	'Harvard Press'	UNION
SELECT 	'To Kill a Mockingbird'	,	'Harvard Press'	UNION
SELECT 	'The Hunger Games'	,	'Harvard Press'	UNION
SELECT 	'Three Musketeers'	,	'Harvard Press'	UNION
SELECT 	'The Inferno'	,	'Penguin Books'	UNION
SELECT 	'The Lord of the Rings'	,	'Penguin Books'	UNION
SELECT 	'Fahrenheit 451'	,	'Penguin Books'	UNION
SELECT 	'Animal Farm'	,	'Penguin Books'	UNION
SELECT 	'Lord of the Flies'	,	'Windsor Publishing'	UNION
SELECT 	'A Tale of Two Cities'	,	'Windsor Publishing'	UNION
SELECT 	'Tom Sawyer'	,	'MIT Press'	UNION
SELECT 	'Hamlet'	,	'Oxford Publishers'	UNION
SELECT 	'MacBeth'	,	'Oxford Publishers'	UNION
SELECT 	'The Phantom of the Opera'	,	'Oxford Publishers'	UNION
SELECT 	'The Legend of Sleepy Hollow'	,	'Dark Winds Press'	UNION
SELECT 	'War and Peace'	,	'Dark Winds Press'	UNION
SELECT 	'Night'	,	'Dark Winds Press'	UNION
SELECT 	'The Picture of Dorian Gray'	,	'Dark Winds Press';
GO
/* Baseline Population of the Authors table by matching them up to the corresponding row in the Books table */

WITH A (Title,Author) AS
(
	SELECT 'A Tale of Two Cities','Charles Dickens' UNION
	SELECT 'Animal Farm','George Orwell' UNION
	SELECT 'Fahrenheit 451','Ray Bradbury' UNION
	SELECT 'Hamlet','William Shakespeare' UNION
	SELECT 'Lord of the Flies','William Golding' UNION
	SELECT 'MacBeth','William Shakespeare' UNION
	SELECT 'Night','Elie Wiesel' UNION
	SELECT 'Old Man and the Sea','Ernest Hemingway' UNION
	SELECT 'The Green Mile','Stephen King' UNION
	SELECT 'The Hunger Games','Suzanne Collins' UNION
	SELECT 'The Inferno','Dante' UNION
	SELECT 'The Legend of Sleepy Hollow','Washington Irving' UNION
	SELECT 'The Lord of the Rings','J.R.R. Tolkien' UNION
	SELECT 'The Lost Tribe','Rohen Rale' UNION
	SELECT 'The Phantom of the Opera','Gaston LeRoux' UNION
	SELECT 'The Picture of Dorian Gray','Oscar Wilde' UNION
	SELECT 'The Shawshank Redemption','Stephen King' UNION
	SELECT 'Three Musketeers','Alexandre Dumas' UNION
	SELECT 'To Kill a Mockingbird','Harper Lee' UNION
	SELECT 'Tom Sawyer','Mark Twain' UNION
	SELECT 'War and Peace','Leo Tolstoy'
)
INSERT INTO BOOK_AUTHORS
( BookID, AuthorName )
SELECT 
	B.BookID
	,A.Author
FROM A INNER JOIN [db_Library].[dbo].[BOOKS] B ON
	A.Title = B.[Title];
GO

/* Baseline Population of the Copies Table by randomly generating 12 BookIDs to populate at a location */

WITH A (BookID) AS
(
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000)
)
INSERT INTO BOOK_COPIES
( BranchID, BookID)
SELECT 5000, BookID FROM A UNION
SELECT 5001, BookID FROM A UNION
SELECT 5002, BookID FROM A UNION
SELECT 5003, BookID FROM A UNION
SELECT 5004, BookID FROM A;

/* Ensure that certain books are populated specifically at locations per the testing requirements. */
/* "The Lost Tribe" is at least located at the "Sharpstown" Branch */

-- Create a temporary table to hold the updated or inserted values 
-- from the OUTPUT clause.
BEGIN TRY
	CREATE TABLE #MyTempTable  
		(ExistingCode nchar(3),  
		 ExistingName nvarchar(50),  
		 ExistingDate datetime,  
		 ActionTaken nvarchar(10),  
		 NewCode nchar(3),  
		 NewName nvarchar(50),  
		 NewDate datetime  
		)
END TRY
BEGIN CATCH
END CATCH;

MERGE BOOK_COPIES AS TARGET
USING 
(
	SELECT B.BookID, LB.BranchID FROM BOOKS B INNER JOIN BOOK_LOANS BL ON
		B.BookID = BL.BookID INNER JOIN LIBRARY_BRANCH LB ON
		BL.BranchID = LB.BranchID
	WHERE (B.Title = 'The Lost Tribe' AND LB.BranchName = 'Sharpstown')
) AS SOURCE
ON (target.BookID = source.BookID AND target.BranchID = source.BranchID)
WHEN NOT MATCHED BY TARGET THEN
INSERT ( BookID, BranchID )
VALUES (source.BookID, source.BranchID)
OUTPUT deleted.*, $action, inserted.* INTO #MyTempTable;
--SELECT * FROM #MyTempTable;

/* Put at least two books written by Stephen King at the Central Branch */
DECLARE @BranchID INT;
SELECT @BranchID = BranchID FROM LIBRARY_BRANCH WHERE BranchName = 'Central';

INSERT INTO BOOK_COPIES
( BookID, BranchID )
SELECT 
B.BookID
,@BranchID [BranchID]
FROM BOOK_AUTHORS BA INNER JOIN BOOKS B ON
	BA.BookID = B.BookID
WHERE BA.AuthorName = 'Stephen King' AND B.BookID NOT IN 
	(SELECT BookID FROM BOOK_COPIES WHERE BranchID = @BranchID);

/* Cleanup Temporary Created Artifact for work */
DROP TABLE #MyTempTable;

/* Final Population of the Book Loans Table */

DECLARE @BranchRNG INT, @BookRNG INT, @BorrowRNG INT;
SELECT @BranchRNG = MAX(BranchID) - MIN(BranchID) FROM LIBRARY_BRANCH; 
SELECT @BookRNG = MAX(BookID) - MIN(BookID) FROM BOOKS;
SELECT @BorrowRNG = MAX(CardNo) - MIN(CardNo) FROM BORROWER;

WITH nums AS
(
   SELECT 1 AS value
    UNION ALL
    SELECT value + 1 AS value
    FROM nums
    WHERE nums.value <= 20
)
INSERT INTO BOOK_LOANS
( BookID, BranchID, CardNo, DateOut )
SELECT 
(ABS(CHECKSUM(NEWID()))%@BookRNG + 1000) [BookID]
,(ABS(CHECKSUM(NEWID()))%@BranchRNG + 5000) [BranchID]
,(ABS(CHECKSUM(NEWID()))%@BorrowRNG + 1) [CardNo]
,CONVERT(date, DATEADD(d,-1*(ABS(CHECKSUM(NEWID()))%40),GETDATE())) [DateOut]
FROM nums CROSS JOIN nums n1;

/* -----------------------------------------------------------------------
/	ADJUST the DateDue to now be within 30 days of checkout
/ ------------------------------------------------------------------------*/

UPDATE BOOK_LOANS SET DateDue = DATEADD(d,30, DateOut);

/* -------------------------------------------------------
/
/	CREATE VIEWS to Support the SPROCS for the exercise questions
/
/ -------------------------------------------------------*/
BEGIN TRY

DECLARE @sql VARCHAR(MAX) = '', @crlf VARCHAR(2) = CHAR(13) + CHAR(10);
SELECT @sql = @sql + 'DROP VIEW ' + QUOTENAME(v.TABLE_SCHEMA) + '.' + QUOTENAME(v.TABLE_NAME) +';' + @crlf
	FROM [db_Library].[INFORMATION_SCHEMA].[VIEWS] v
	WHERE TABLE_CATALOG = 'db_Library';

PRINT @sql;
EXEC(@sql);

END TRY
BEGIN CATCH
END CATCH
GO

CREATE VIEW v_BooksByBranch AS
SELECT
	B.BookID 
	,B.Title
	,BA.AuthorName
	,LB.BranchName
	,BC.Number_Of_Copies
FROM BOOKS B FULL JOIN BOOK_COPIES BC ON B.BookID = BC.BookID 
	INNER JOIN LIBRARY_BRANCH LB ON BC.BranchID = LB.BranchID 
	INNER JOIN BOOK_AUTHORS BA ON B.BookID = BA.BookID;
GO

CREATE VIEW v_BorrowerNames AS
SELECT B.CardNo
	,B.Name
	,B.Address
	,B.Phone
	,COUNT(BL.BookID)OVER(PARTITION BY BL.CardNo) [NumBooksLoaned]
	FROM BORROWER B INNER JOIN BOOK_LOANS BL ON B.CardNo = BL.CardNo;
GO

CREATE VIEW v_BooksLoaned AS
SELECT 
	LB.BranchName
	,BL.BookID
	,B.Title
	,BL.DateOut
	,BL.DateDue
	,BR.CardNo
	,BR.Name
	,BR.Address
	,BR.Phone
FROM BOOKS B LEFT JOIN BOOK_LOANS BL ON B.BookID = BL.BookID 
	FULL JOIN LIBRARY_BRANCH LB ON BL.BranchID = LB.BranchID
	RIGHT JOIN BORROWER BR ON BL.CardNo = BR.CardNo
GO

CREATE VIEW v_AuthorLocations AS
SELECT 
	LB.BranchName
	,B.BookID
	,B.Title
	,BA.AuthorName
FROM BOOKS B INNER JOIN BOOK_COPIES BC ON B.BookID = BC.BookID 
	INNER JOIN LIBRARY_BRANCH LB ON BC.BookID = LB.BranchID
	INNER JOIN BOOK_AUTHORS BA ON B.BookID = BA.BookID;
GO

/* -------------------------------------------------------
/
/	CREATE SPROCS for the exercise questions
/
/ -------------------------------------------------------*/
	declare @procName varchar(500)
	declare cur cursor 

	for SELECT [ROUTINE_NAME] FROM [db_Library].[INFORMATION_SCHEMA].[ROUTINES] WHERE [ROUTINE_CATALOG] = 'db_Library';
	open cur
	fetch next from cur into @procName
	while @@fetch_status = 0
	begin
		exec('drop procedure [' + @procName + ']')
		fetch next from cur into @procName
	end
	close cur
	deallocate cur
GO

CREATE PROC usp_SEARCH_CountOfCopiesOfBooks
	@Title varchar(250) = '%'
	,@Branch varchar(128) = '%'
AS
	SELECT
		BBB.Number_Of_Copies [Copies]
		,BBB.Title
		,BBB.BranchName
	FROM v_BooksByBranch BBB
	WHERE BBB.Title LIKE ISNULL(@Title,'%') AND BBB.BranchName LIKE ISNULL(@Branch,'%');
GO

CREATE PROC usp_ClearedBorrowsList
AS
	SELECT
	[CardNo]
      ,[Name]
  FROM [db_Library].[dbo].[v_BooksLoaned]
  WHERE BookID IS NULL;
GO

CREATE PROC usp_BooksDueToday
	@Branch varchar(128) = '%'
AS
	SELECT
	[BranchName]
      ,[Title]
      ,[Name]
      ,[Address]
  FROM [db_Library].[dbo].[v_BooksLoaned]
  WHERE DateDue = CAST(GETDATE() AS DATE) AND BranchName LIKE ISNULL(@Branch,'%')
  ORDER BY BranchName, Title, Name;
GO

CREATE PROC usp_CountBooksLoanedOut
	@Branch varchar(128) = '%'
AS
	SELECT DISTINCT
	[BranchName]
      ,COUNT(BookID)OVER(PARTITION BY BranchName) [Count of Books Loaned]
  FROM [db_Library].[dbo].[v_BooksLoaned]
  WHERE BranchName LIKE ISNULL(@Branch,'%');
GO

CREATE PROC usp_CountBooksLoanedOutByPerson
	@QtyLoanedOut INT = 0
AS
	WITH A
	AS
	(
		SELECT
			Name
			,Address
			,[NumBooksLoaned] = COUNT(BookID)OVER(PARTITION BY CardNo) 
	  FROM [db_Library].[dbo].[v_BooksLoaned]
	)
	SELECT Name, Address, NumBooksLoaned [Count of Books Loaned] FROM A
	WHERE [NumBooksLoaned] >= ISNULL(@QtyLoanedOut,0)
	GROUP BY Name, Address, [NumBooksLoaned];
GO

CREATE PROC usp_SEARCH_AuthorBranch
	@Branch varchar(128) = '%'
	,@Author varchar(64) = '%'
AS
	SELECT [BookID]
		  ,[Title]
		  ,[AuthorName]
		  ,[BranchName]
		  ,[Number_Of_Copies]
	  FROM [db_Library].[dbo].[v_BooksByBranch]
	  WHERE BranchName LIKE ISNULL(@Branch,'%') AND
		AuthorName LIKE ISNULL(@Author, '%');
GO

DECLARE	@return_value int;
SELECT '1.) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?' [Question];
EXEC	@return_value = [dbo].[usp_SEARCH_CountOfCopiesOfBooks]
		@Title = 'The Lost Tribe',
		@Branch = 'SharpsTown';

SELECT '2.) How many copies of the book titled "The Lost Tribe" are owned by each library branch?' [Question];
EXEC	@return_value = [dbo].[usp_SEARCH_CountOfCopiesOfBooks]
		@Title = 'The Lost Tribe',
		@Branch = NULL;

SELECT '3.) Retrieve the names of all borrowers who do not have any books checked out.' [Question];
EXEC	@return_value = [dbo].[usp_ClearedBorrowsList];

SELECT '4.) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is today, retrieve the book title, the borrower''s name, and the borrower''s address.' [Question];
EXEC	@return_value = [dbo].[usp_BooksDueToday]
		@Branch = 'Sharpstown';

SELECT '5.) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.' [Question];
EXEC	@return_value = [dbo].[usp_BooksDueToday]
		@Branch = NULL;

SELECT '6.) Retrieve the names, addresses, and the number of books checked out for all borrowers who have more than five books checked out.' [Question];
EXEC	@return_value = [dbo].[usp_CountBooksLoanedOutByPerson]
		@QtyLoanedOut = 5;

SELECT '7.) For each book authored (or co-authored) by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".' [Question];
EXEC	@return_value = [dbo].[usp_SEARCH_AuthorBranch]
		@Branch = 'Central',
		@Author = 'Stephen King';
GO