--- Author        : Rashmi Gupta
--- Description   : Get due date in appropriate format according to given report type 
--- Created Date  : 22-05-2024
--- Modified Date : 23-05-2024

CREATE FUNCTION [dbo].[GetDueDate] 
(
     @DueDateTemp VARCHAR(10)
    ,@ReportType INT 
    ,@DueMonth INT
    ,@DueYr INT
)
RETURNS VARCHAR(50)
AS
BEGIN
    /*
        SELECT DBO.GetDueDate('THURSDAY', 1) A
        SELECT DBO.GetDueDate('01', 4, 9, 2024) A
        SELECT DBO.ISEMPTY('01')
    */
    DECLARE @DueDate VARCHAR(50) = '';
    DECLARE @DateFormat VARCHAR(10) = 'dd-MMM-yyyy';
    DECLARE @DefualtDate VARCHAR(50) = FORMAT(DATEFROMPARTS(@DueYr, @DueMonth, 01), @DateFormat);

    DECLARE @FebLstDay INT = IIF((@DueYr % 4 = 0 AND @DueYr % 100 != 0) OR (@DueYr % 400 = 0), 29, 28);

    SET @DueDateTemp = UPPER(TRIM(@DueDateTemp));

    IF DBO.IsEmpty(@DueDateTemp) = 1
        RETURN @DefualtDate;
    
    IF @ReportType = 1  -- Weekly
    BEGIN            
        SET @DueDate = 'Every ' + LEFT(UPPER(TRIM(@DueDateTemp)), 1) + SUBSTRING(LOWER(TRIM(@DueDateTemp)), 2, LEN(TRIM(@DueDateTemp)) - 1);
    END
    ELSE IF ISNUMERIC(@DueDateTemp) = 1 AND @DueMonth > 0 AND @DueYr > 0
    BEGIN
        -- IF @ReportType = 2  -- Monthly
        -- BEGIN
            SET @DueDate = 
                CASE
                    WHEN CAST(@DueDateTemp AS INT) > 28 THEN
                        CASE 
                            WHEN @DueMonth = 2 THEN  -- When month is FEB and Due date is more than 28
                                FORMAT(DATEFROMPARTS(@DueYr, @DueMonth, @FebLstDay), @DateFormat)
                            ELSE
                                CASE 
                                    WHEN ISDATE(CONVERT(VARCHAR, DATEFROMPARTS(@DueYr, @DueMonth, CAST(@DueDateTemp AS INT)))) = 0 THEN 
                                        FORMAT(DATEFROMPARTS(@DueYr, @DueMonth, 30), @DateFormat)
                                    ELSE
                                        FORMAT(DATEFROMPARTS(@DueYr, @DueMonth, CAST(@DueDateTemp AS INT)), @DateFormat)
                                END
                        END
                    ELSE
                        FORMAT(DATEFROMPARTS(@DueYr, @DueMonth, CAST(@DueDateTemp AS INT)), @DateFormat)
                END;
        -- END
        -- ELSE 
        --     RETURN @DefualtDate;
    END
    RETURN @DueDate;
END
GO

