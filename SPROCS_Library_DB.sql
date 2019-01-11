USE [db_Library]
GO

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
SELECT B.Title, LB.BranchName, BC.Number_Of_Copies
FROM BOOKS B INNER JOIN BOOK_COPIES BC ON B.BookID = BC.BookID INNER JOIN
	LIBRARY_BRANCH LB ON BC.BranchID = LB.BranchID;
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
FROM BOOKS B INNER JOIN BOOK_LOANS BL ON B.BookID = BL.BookID 
	INNER JOIN LIBRARY_BRANCH LB ON BL.BookID = LB.BranchID
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
/	CREATE SPROCS and EXEC for the exercise questions
/
/ -------------------------------------------------------*/

