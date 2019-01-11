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
	SELECT 'Karen', 'Yeager'
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

WITH A (BookID, NumCopies) AS
(
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2) UNION
	SELECT (ABS(CHECKSUM(NEWID()))%21 + 1000), (ABS(CHECKSUM(NEWID()))%6 + 2)
)
INSERT INTO BOOK_COPIES
( BranchID, BookID, Number_Of_Copies)
SELECT 5000, BookID, NumCopies FROM A UNION
SELECT 5001, BookID, NumCopies FROM A UNION
SELECT 5002, BookID, NumCopies FROM A UNION
SELECT 5003, BookID, NumCopies FROM A UNION
SELECT 5004, BookID, NumCopies FROM A;

/* Ensure that certain books are populated specifically at locations per the testing requirements. */
/* "The Lost Tribe" is at least located at the "Sharpstown" Branch */

INSERT INTO BOOK_COPIES
( BookID, BranchID, Number_Of_Copies )


/* Final Population of the Book Loans Table */


