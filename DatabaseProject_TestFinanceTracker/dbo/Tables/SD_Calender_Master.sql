CREATE TABLE [dbo].[SD_Calender_Master] (
    [RecId]                  INT      IDENTITY (1, 1) NOT NULL,
    [DDate]                  DATETIME NOT NULL,
    [YYear]                  AS       (datepart(year,[DDate])),
    [MonthNo]                AS       (datepart(month,[DDate])),
    [FinancialQuarter]       AS       (case when (CONVERT([int],datepart(quarter,[DDate]),(0))-(1))=(0) then (4) else CONVERT([int],datepart(quarter,[DDate]),(0))-(1) end),
    [QuarterlyTaskAddMonth]  AS       (case when (CONVERT([int],datepart(quarter,[DDate]),(0))-(1))=(0) then '11' else (CONVERT([int],datepart(quarter,[DDate]),(0))-(2))*(3)+(2) end),
    [Quarter]                AS       (case when (CONVERT([int],datepart(quarter,[DDate]),(0))-(1))=(0) then (4) else CONVERT([int],datepart(quarter,[DDate]),(0))-(1) end),
    [FinancialHalf]          AS       (case when CONVERT([int],datepart(month,[DDate]))>(3) AND CONVERT([int],datepart(month,[DDate]))<(10) then '1' else '2' end),
    [HalfYearlyTaskAddMonth] AS       (case when CONVERT([int],datepart(month,[DDate]))>(3) AND CONVERT([int],datepart(month,[DDate]))<(10) then '8' else '2' end),
    [Half]                   AS       (case when CONVERT([int],datepart(quarter,[ddate]),(0))<(3) then '1' else '2' end),
    [AnnualTaskAddMonth]     AS       ((2)),
    [DaysNo]                 AS       (datepart(weekday,[DDate])),
    [DaysName]               AS       (datename(weekday,[DDate])),
    [MonthName]              AS       (datename(month,[DDate])),
    [WeekDaysCount]          AS       (datepart(week,[Ddate])),
    [MonthDays]              AS       (datepart(day,dateadd(day,(-1),dateadd(month,datediff(month,(-1),[DDate]),(0))))),
    [Day]                    AS       (CONVERT([varchar],datepart(day,[DDate]))),
    CONSTRAINT [PK_SD_Calender_Master] PRIMARY KEY CLUSTERED ([RecId] ASC)
);


GO

