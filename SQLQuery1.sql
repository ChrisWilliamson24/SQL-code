USE [Vid Game Sales]

SELECT * 
FROM [Raw Data]

-- Count number of nulls
SELECT SUM(CASE WHEN User_Score is null THEN 1 ELSE 0 END) 
AS [Number Of Null Values] 
FROM [Raw Data]

-- Missing data from genre which will be removed 
SELECT *
FROM [Raw Data]
WHERE Genre is null

DELETE FROM [Raw Data]
WHERE Genre is null

-- Find which games have year of release as 'N/A'
-- Although I could search for the year of release for each game, searching for 269 games would take a long time
SELECT *
FROM [Raw Data]
WHERE Year_of_Release = 'N/A'



-- Find duplicated names and platforms (Some names will be on multiple platforms)
-- Changed SELECT to DELETE to remove these rows (3 rows were affected)
WITH CTE AS(
SELECT *, 
		ROW_NUMBER() OVER(
		PARTITION BY CAST(Name AS NVARCHAR(100)),
				[Publisher],
				CAST(Platform AS NVARCHAR(100))
				ORDER BY CAST(Name AS NVARCHAR(100))) dupe_num
FROM [Raw Data]
)

SELECT *
FROM CTE
WHERE dupe_num > 1
ORDER BY CAST(Name AS NVARCHAR(100))

-- Top 10 critic scores 
SELECT TOP 10 Name, Platform, Year_of_Release, Critic_Score
FROM [Raw Data]
ORDER BY Critic_Score DESC 

-- Find avg score with amount of games released in that year
-- Older games recieved higher ratings but amount of games reviewed is much smaller
-- than games made in 2010's
SELECT TOP 10 Year_of_Release, ROUND(AVG(Critic_Score),2) AS avg_crit_score
, COUNT(*) AS num_games
FROM [Raw Data]
WHERE NOT (Critic_Score IS NULL AND User_Score IS NULL)
AND Year_of_Release != 'N/A'
GROUP BY Year_of_Release
ORDER BY avg_crit_score DESC 

-- We can do a similar thing with user score to see if there is a smiliar trend
SELECT TOP 10 Year_of_Release, ROUND(AVG(User_Score),2) AS avg_user_score
, COUNT(*) AS num_games
FROM [Raw Data]
WHERE NOT (Critic_Score IS NULL AND User_Score IS NULL)
AND Year_of_Release != 'N/A'
GROUP BY Year_of_Release
ORDER BY avg_user_score DESC 
 
-- Top 10 Games sold globally
SELECT TOP 10 Name, Platform, Year_of_Release, Global_Sales
FROM [Raw Data]
ORDER BY Global_Sales DESC 

-- Most popular genres by global sales
SELECT Genre, SUM(Global_Sales) AS total_sales, COUNT(*) AS num_games
FROM [Raw Data]
GROUP BY Genre
ORDER BY Total_Sales DESC

-- Delete cols that won't be used - some cols not used here may be used in Tableau

ALTER TABLE [Raw Data]
DROP COLUMN Rating, Other_Sales

SELECT * 
FROM [Raw Data]