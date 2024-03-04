CREATE TABLE [dbo].[SD_Calender_Master] (
    [RecId]         INT      IDENTITY (1, 1) NOT NULL,
    [DDate]         DATETIME NOT NULL,
    [YYear]         AS       (datepart(year,[DDate])),
    [MonthNo]       AS       (datepart(month,[DDate])),
    [DaysNo]        AS       (datepart(weekday,[DDate])),
    [DaysName]      AS       (datename(weekday,[DDate])),
    [MonthName]     AS       (datename(month,[DDate])),
    [WeekDaysCount] AS       (datepart(week,[Ddate])),
    [Quarter]       AS       (CONVERT([int],datepart(quarter,[DDate]),(0))),
    [Half]          AS       (case when CONVERT([int],datepart(quarter,[ddate]),(0))=(1) then '1' when CONVERT([int],datepart(quarter,[ddate]),(0))=(2) then '1' when CONVERT([int],datepart(quarter,[ddate]),(0))=(3) then '2' when CONVERT([int],datepart(quarter,[ddate]),(0))=(4) then '2'  end),
    [MonthDays]     AS       (datepart(day,dateadd(day,(-1),dateadd(month,datediff(month,(-1),[DDate]),(0))))),
    [Day]           AS       (CONVERT([varchar],datepart(day,[DDate]))),
    CONSTRAINT [PK_SD_Calender_Master] PRIMARY KEY CLUSTERED ([RecId] ASC)
);


GO

