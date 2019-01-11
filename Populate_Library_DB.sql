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
	SELECT 'Sonja', 'Thompson' UNION
	SELECT 'Karen', 'Yeager' UNION
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
SELECT 	'A Tale if Two Cities'	,	'Windsor Publishing'	UNION
SELECT 	'Tom Sawyer'	,	'MIT Press'	UNION
SELECT 	'Hamlet'	,	'Oxford Publishers'	UNION
SELECT 	'MacBeth'	,	'Oxford Publishers'	UNION
SELECT 	'The Phantom of the Opera'	,	'Oxford Publishers'	UNION
SELECT 	'The Legend of Sleepy Hollow'	,	'Dark Winds Press'	UNION
SELECT 	'War and Peace'	,	'Dark Winds Press'	UNION
SELECT 	'Night'	,	'Dark Winds Press'	UNION
SELECT 	'The Picture of Dorian Gray'	,	'Dark Winds Press';

/* Baseline Population of the Authors table by matching them up to the corresponding row in the Books table */

INSERT INTO BOOK_AUTHORS
( BookID, AuthorName )
SELECT 	1000	,	'Rohen Rale' 	UNION
SELECT 	1001	,	'Stephen King' 	UNION
SELECT 	1002	,	'Stephen King' 	UNION
SELECT 	1003	,	'Ernest Hemingway' 	UNION
SELECT 	1004	,	'Harper Lee' 	UNION
SELECT 	1005	,	'Suzanne Collins' 	UNION
SELECT 	1006	,	'Alexandre Dumas' 	UNION
SELECT 	1007	,	'Dante' 	UNION
SELECT 	1008	,	'J.R.R. Tolkein' 	UNION
SELECT 	1009	,	'Ray Bradbury' 	UNION
SELECT 	1010	,	'George Orwell' 	UNION
SELECT 	1011	,	'William Golding' 	UNION
SELECT 	1012	,	'Charles Dickens' 	UNION
SELECT 	1013	,	'Mark Twain' 	UNION
SELECT 	1014	,	'William Shakespeare' 	UNION
SELECT 	1015	,	'William Shakespeare' 	UNION
SELECT 	1016	,	'Gaston LeRoux' 	UNION
SELECT 	1017	,	'Washington Irving' 	UNION
SELECT 	1018	,	'Leo Tolstoy' 	UNION
SELECT 	1019	,	'Elie Weisel' 	UNION
SELECT 	1020	,	'Oscar Wilde';

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
	SELECT B.BookID, LB.BranchID FROM BOOKS B INNER JOIN BOOK_COPIES BC ON
		B.BookID = BC.BookID INNER JOIN LIBRARY_BRANCH LB ON
		BC.BranchID = LB.BranchID
	WHERE (B.Title = 'The Lost Tribe' AND LB.BranchName = 'Sharpstown')
) AS SOURCE
ON (target.BookID = source.BookID AND target.BranchID = source.BranchID)
WHEN NOT MATCHED THEN
INSERT ( BookID, BranchID )
VALUES (source.BookID, source.BranchID)
OUTPUT deleted.*, $action, inserted.* INTO #MyTempTable;
SELECT * FROM #MyTempTable;

/* Put at least two books written by Stephen King at the Central Branch */
MERGE BOOK_COPIES AS TARGET
USING 
(
	SELECT B.BookID, LB.BranchID FROM BOOK_AUTHORS B INNER JOIN BOOK_COPIES BC ON
		B.BookID = BC.BookID INNER JOIN LIBRARY_BRANCH LB ON
		BC.BranchID = LB.BranchID
	WHERE B.AuthorName = 'Stephen King' AND LB.BranchName = 'Central'
) AS SOURCE
ON (target.BookID = source.BookID AND target.BranchID = source.BranchID)
WHEN NOT MATCHED THEN
INSERT ( BookID, BranchID )
VALUES (source.BookID, source.BranchID)
OUTPUT deleted.*, $action, inserted.* INTO #MyTempTable;
SELECT * FROM #MyTempTable;

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
    WHERE nums.value <= 99
)
INSERT INTO BOOK_LOANS
( BookID, BranchID, CardNo, DateOut )
SELECT 
(ABS(CHECKSUM(NEWID()))%@BookRNG + 1000) [BookID]
,(ABS(CHECKSUM(NEWID()))%@BranchRNG + 5000) [BranchID]
,(ABS(CHECKSUM(NEWID()))%@BorrowRNG + 1) [CardNo]
,CONVERT(date, DATEADD(d,-1*(ABS(CHECKSUM(NEWID()))%30),GETDATE())) [DateOut]
FROM nums;

