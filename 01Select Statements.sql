USE BUDT703_Project_0507_08

--Who are the top 10 weakest opponents against UMD?
SELECT *
FROM OpponentWinRate 
ORDER BY [Win Rate Against Opponent] DESC, [Games Played Against] DESC;

--Who are the top 10 strongest opponents against UMD?
SELECT *
FROM OpponentWinRate 
ORDER BY [Win Rate Against Opponent] ASC, [Games Played Against] DESC;

--What is the win rate of the UMD team with and without home field advantage?
SELECT *
FROM LocationWiseScore
ORDER BY [Win Rate] DESC;

--What is the longest winning streak?
WITH RankedGames AS (
    SELECT
        g.gmeId, g.gmeDate, g.gmeScore, g.trnName,
        ROW_NUMBER() OVER (ORDER BY gmeDate DESC) -
        ROW_NUMBER() OVER 
		(PARTITION BY YEAR(gmeDate), CASE WHEN SUBSTRING(g.gmeScore, 2, 1) > SUBSTRING(g.gmeScore, 4, 1) THEN 'W' ELSE 'L' END 
		ORDER BY gmeDate DESC) AS GroupNum
    FROM
        [Moneyball.Game] g
)
, ConsecutiveWinGroups AS (
    SELECT
        YEAR(gmeDate) AS GameYear,
        GroupNum,
        COUNT(*) AS ConsecutiveGamesWon
    FROM
        RankedGames
    WHERE
        CASE WHEN SUBSTRING(gmeScore, 2, 1) > SUBSTRING(gmeScore, 4, 1) THEN 'W' ELSE 'L' END = 'W'
    GROUP BY YEAR(gmeDate), GroupNum
)
, LongestWinStreaks AS (
    SELECT
        GameYear,
        MAX(ConsecutiveGamesWon) AS LongestWinStreak
    FROM ConsecutiveWinGroups
    GROUP BY GameYear
)
SELECT GameYear AS 'Year', LongestWinStreak AS 'Longest Winning Streak'
FROM LongestWinStreaks
ORDER BY 'Year' DESC;


--What is the longest losing streak?
WITH RankedGames AS (
    SELECT
        gmeId, gmeDate, gmeScore, trnName,
        ROW_NUMBER() OVER (ORDER BY g.gmeDate DESC) -
        ROW_NUMBER() OVER 
		(PARTITION BY YEAR(g.gmeDate), CASE WHEN SUBSTRING(g.gmeScore, 2, 1) > SUBSTRING(g.gmeScore, 4, 1) THEN 'W' ELSE 'L' END 
		ORDER BY g.gmeDate DESC) AS GroupNum
    FROM
        [Moneyball.Game] g
)
, ConsecutiveLossGroups AS (
    SELECT
        YEAR(r.gmeDate) AS GameYear,
        r.GroupNum,
        COUNT(*) AS ConsecutiveGamesLost
    FROM
        RankedGames r
    WHERE
        CASE WHEN SUBSTRING(r.gmeScore, 2, 1) < SUBSTRING(r.gmeScore, 4, 1) THEN 'L' ELSE 'W' END = 'L'
    GROUP BY
        YEAR(r.gmeDate),
        r.GroupNum
)
, LongestLossStreaks AS (
    SELECT
        GameYear,
        MAX(ConsecutiveGamesLost) AS LongestLossStreak
    FROM
        ConsecutiveLossGroups
    GROUP BY
        GameYear
)
SELECT GameYear AS 'Year', LongestLossStreak AS 'Longest Losing Streak'
FROM LongestLossStreaks
ORDER BY 'Year' DESC;


--What time of day does the UMD softball team perform best?
SELECT
    gmeTimeOfDay AS 'Time of Day',
    SUM(CASE
        WHEN CAST(SUBSTRING(gmeScore, 1, CHARINDEX('-', gmeScore) - 1) AS INT) >
             CAST(SUBSTRING(gmeScore, CHARINDEX('-', gmeScore) + 1, LEN(gmeScore)) AS INT) THEN 1
        ELSE 0
    END) * 1.0 / COUNT(*) AS 'Win Rate'
FROM
    [Moneyball.Game]
WHERE 
	gmeTimeOfDay IS NOT NULL
GROUP BY
    gmeTimeOfDay
ORDER BY
    'Win Rate' DESC;

--What tournaments did the UMD softball team perform best in?
SELECT *
FROM TournamentWinRate 
ORDER BY [Tournament Win Rate] DESC, [Games Played Against] DESC;




