/* ============================================================
   F1 SQL + POWER BI PROJECT
   SEASONS: 2022, 2023, 2024, 2025
   TABLE: F1_2022_2025_ONE_SHEET
   ============================================================ */


/* ============================================================
   1. SELECT DATABASE
   ============================================================ */

USE F1;


/* ============================================================
   2. CHECK THE DATA
   ============================================================ */

SELECT *
FROM F1_2022_2025_ONE_SHEET;


/* ============================================================
   3. CHECK ROWS, DRIVERS, TEAMS AND SEASONS
   ============================================================ */

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT season) AS total_seasons,
    COUNT(DISTINCT driver_id) AS total_drivers,
    COUNT(DISTINCT team_id) AS total_teams
FROM F1_2022_2025_ONE_SHEET;


/* ============================================================
   4. AVAILABLE SEASONS
   ============================================================ */

SELECT DISTINCT
    season
FROM F1_2022_2025_ONE_SHEET
ORDER BY season;


/* ============================================================
   5. ALL DRIVERS
   ============================================================ */

SELECT DISTINCT
    driver_id,
    driver_name,
    nationality
FROM F1_2022_2025_ONE_SHEET
ORDER BY driver_name;


/* ============================================================
   6. ALL TEAMS
   ============================================================ */

SELECT DISTINCT
    team_id,
    stable_team AS team
FROM F1_2022_2025_ONE_SHEET
ORDER BY team;


/* ============================================================
   7. TOTAL DRIVER POINTS
   ============================================================ */

SELECT
    driver_name,
    SUM(driver_season_points) AS total_points
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY total_points DESC;


/* ============================================================
   8. TOTAL POINTS BY SEASON
   ============================================================ */

SELECT
    season,
    SUM(driver_season_points) AS total_points
FROM F1_2022_2025_ONE_SHEET
GROUP BY season
ORDER BY season;


/* ============================================================
   9. DRIVER POINTS BY SEASON
   ============================================================ */

SELECT
    season,
    driver_name,
    stable_team AS team,
    driver_season_points AS points
FROM F1_2022_2025_ONE_SHEET
ORDER BY season, points DESC;


/* ============================================================
   10. DRIVER CHAMPIONS
   ============================================================ */

SELECT
    season,
    driver_name,
    stable_team AS team,
    driver_championship_position,
    driver_season_points
FROM F1_2022_2025_ONE_SHEET
WHERE driver_championship_position = 1
ORDER BY season;


/* ============================================================
   11. TOTAL RACE WINS
   ============================================================ */

SELECT
    driver_name,
    SUM(race_wins) AS total_wins
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY total_wins DESC;


/* ============================================================
   12. RACE WINS BY SEASON
   ============================================================ */

SELECT
    season,
    driver_name,
    stable_team AS team,
    race_wins
FROM F1_2022_2025_ONE_SHEET
WHERE race_wins > 0
ORDER BY season, race_wins DESC;


/* ============================================================
   13. TEAM POINTS BY SEASON
   ============================================================ */

/*
   constructor_season_points is repeated for each
   driver belonging to the same constructor.

   Therefore use MAX(), NOT SUM().
*/

SELECT
    season,
    stable_team AS team,
    MAX(constructor_season_points) AS team_points
FROM F1_2022_2025_ONE_SHEET
GROUP BY season, stable_team
ORDER BY season, team_points DESC;


/* ============================================================
   14. CONSTRUCTOR CHAMPIONS
   ============================================================ */

SELECT
    season,
    stable_team AS team,
    MAX(constructor_championship_position)
        AS championship_position,
    MAX(constructor_season_points)
        AS team_points
FROM F1_2022_2025_ONE_SHEET
WHERE constructor_championship_position = 1
GROUP BY season, stable_team
ORDER BY season;


/* ============================================================
   15. TOTAL TEAM POINTS — 2022 TO 2025
   ============================================================ */

SELECT
    stable_team AS team,
    SUM(team_points) AS total_points
FROM
(
    SELECT
        season,
        stable_team,
        MAX(constructor_season_points) AS team_points
    FROM F1_2022_2025_ONE_SHEET
    GROUP BY season, stable_team
) AS team_seasons
GROUP BY stable_team
ORDER BY total_points DESC;


/* ============================================================
   16. DRIVER + TEAM PERFORMANCE
   ============================================================ */

SELECT
    driver_name,
    stable_team AS team,
    SUM(driver_season_points) AS total_points,
    SUM(race_wins) AS total_wins
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name, stable_team
ORDER BY total_points DESC;


/* ============================================================
   17. DRIVER SEASON RECORD
   ============================================================ */

SELECT
    season,
    driver_name,
    stable_team AS team,
    driver_championship_position,
    driver_season_points,
    race_wins
FROM F1_2022_2025_ONE_SHEET
ORDER BY season, driver_championship_position;


/* ============================================================
   18. TOP 10 DRIVERS
   ============================================================ */

SELECT
    driver_name,
    SUM(driver_season_points) AS total_points
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY total_points DESC
LIMIT 10;


/* ============================================================
   19. TEAM RANKING — 2022 TO 2025
   ============================================================ */

SELECT
    stable_team AS team,
    SUM(team_points) AS total_points
FROM
(
    SELECT
        season,
        stable_team,
        MAX(constructor_season_points) AS team_points
    FROM F1_2022_2025_ONE_SHEET
    GROUP BY season, stable_team
) AS team_seasons
GROUP BY stable_team
ORDER BY total_points DESC;


/* ============================================================
   20. TEAMMATE COMPARISON
   ============================================================ */

SELECT
    season,
    stable_team AS team,
    MAX(driver_season_points) AS highest_driver_points,
    MIN(driver_season_points) AS lowest_driver_points,
    MAX(driver_season_points)
        - MIN(driver_season_points) AS teammate_gap
FROM F1_2022_2025_ONE_SHEET
GROUP BY season, stable_team
ORDER BY season, teammate_gap DESC;


/* ============================================================
   21. AVERAGE DRIVER POINTS
   ============================================================ */

SELECT
    driver_name,
    COUNT(*) AS seasons_competed,
    ROUND(
        AVG(driver_season_points),
        2
    ) AS average_points
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY average_points DESC;


/* ============================================================
   22. POINTS PER RACE
   ============================================================ */

SELECT
    driver_name,
    SUM(driver_season_points) AS total_points,
    SUM(season_races) AS total_races,
    ROUND(
        SUM(driver_season_points)
        / SUM(season_races),
        2
    ) AS points_per_race
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY points_per_race DESC;


/* ============================================================
   23. WIN RATE
   ============================================================ */

SELECT
    driver_name,
    SUM(race_wins) AS wins,
    SUM(season_races) AS races,
    ROUND(
        SUM(race_wins)
        / SUM(season_races) * 100,
        2
    ) AS win_rate_percent
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
ORDER BY win_rate_percent DESC;


/* ============================================================
   24. DRIVER CONSISTENCY
   ============================================================ */

SELECT
    driver_name,
    COUNT(*) AS seasons_competed,
    ROUND(
        AVG(driver_season_points),
        2
    ) AS average_points,
    ROUND(
        STDDEV(driver_season_points),
        2
    ) AS points_variation
FROM F1_2022_2025_ONE_SHEET
GROUP BY driver_name
HAVING COUNT(*) >= 2
ORDER BY points_variation ASC;


/* ============================================================
   25. CHAMPIONSHIP GAP
   ============================================================ */

SELECT
    f.season,
    f.driver_name AS champion,
    f.driver_season_points AS champion_points,

    (
        SELECT MAX(f2.driver_season_points)
        FROM F1_2022_2025_ONE_SHEET AS f2
        WHERE f2.season = f.season
        AND f2.driver_championship_position > 1
    ) AS second_place_points,

    f.driver_season_points -
    (
        SELECT MAX(f2.driver_season_points)
        FROM F1_2022_2025_ONE_SHEET AS f2
        WHERE f2.season = f.season
        AND f2.driver_championship_position > 1
    ) AS championship_gap

FROM F1_2022_2025_ONE_SHEET AS f
WHERE f.driver_championship_position = 1
ORDER BY championship_gap DESC;


/* ============================================================
   26. FINAL DATA CHECK
   ============================================================ */

SELECT
    season,
    COUNT(*) AS driver_records,
    COUNT(DISTINCT driver_id) AS drivers,
    COUNT(DISTINCT team_id) AS teams
FROM F1_2022_2025_ONE_SHEET
GROUP BY season
ORDER BY season;


/* ============================================================
   27. FINAL DATA FOR POWER BI
   ============================================================ */

SELECT
    season,
    driver_id,
    driver_name,
    nationality,
    stable_team,
    team_id,
    driver_championship_position,
    driver_season_points,
    constructor_championship_position,
    constructor_season_points,
    season_races,
    race_wins
FROM F1_2022_2025_ONE_SHEET
ORDER BY season, driver_championship_position;


/* ============================================================
   SQL PROJECT COMPLETE
   NEXT: POWER BI
   ============================================================ */