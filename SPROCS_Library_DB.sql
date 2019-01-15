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
  WHERE DateDue = CAST(GETDATE() AS DATE) AND BranchName LIKE ISNULL(@Branch,'%');
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