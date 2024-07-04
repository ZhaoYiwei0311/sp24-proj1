-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people
  WHERE namefirst LIKE '% %'
  ORDER BY namefirst ASC, namelast ASC 
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM people
  GROUP BY birthyear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), count(*)
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, namelast, p.playerID, h.yearid
  FROM people AS p
  LEFT JOIN halloffame as h
  ON p.playerID = h.playerID
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC, p.playerID ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT namefirst, namelast, p.playerid, s.schoolid, h.yearid
  FROM people AS p
  LEFT JOIN halloffame as h
  ON p.playerID = h.playerID
  LEFT JOIN collegeplaying AS c
  ON c.playerid = p.playerid
  LEFT JOIN schools AS s
  ON s.schoolid = c.schoolid
  WHERE h.inducted = 'Y'
	AND s.schoolstate = 'CA'
	AND s.schoolCountry = 'USA'
  ORDER BY h.yearid DESC, s.schoolid ASC, p.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT p.playerid, namefirst, namelast, s.schoolid
  FROM people AS p
  LEFT JOIN halloffame as h
  ON p.playerID = h.playerID
  LEFT JOIN collegeplaying AS c
  ON c.playerid = p.playerid
  LEFT JOIN schools AS s
  ON s.schoolid = c.schoolid
  WHERE h.inducted = 'Y'
  ORDER BY p.playerid DESC, s.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT p.playerid, namefirst, namelast, yearid, ((b.h + b.h2b + 2 * b.h3b + 3 * b.hr) * 1.0 / b.ab) AS slg
  FROM people AS p
  LEFT JOIN batting AS b
  ON p.playerid = b.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC
  LIMIT 10;
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS  
  SELECT p.playerid, namefirst, namelast,(SUM(b.h + b.h2b + 2 * b.h3b + 3 * b.hr) * 1.0 /  SUM(b.ab)) as s 
  FROM people AS p
  LEFT JOIN batting AS b
  ON p.playerid = b.playerid
  GROUP BY b.playerid
  HAVING SUM(b.ab) > 50
  ORDER BY s DESC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT namefirst, namelast,(SUM(b.h + b.h2b + 2 * b.h3b + 3 * b.hr) * 1.0 /  SUM(b.ab)) as s
  FROM people AS p
  LEFT JOIN batting AS b
  ON p.playerid = b.playerid
  GROUP BY b.playerid
  HAVING SUM(b.ab) > 50 
  AND s > 
	  (SELECT (SUM(b.h + b.h2b + 2 * b.h3b + 3 * b.hr) * 1.0 /  SUM(b.ab)) AS mw
	  FROM batting AS b
	  WHERE b.playerid = 'mayswi01')
  
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
  FROM salaries
  GROUP BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH gap(gap) AS (
  SELECT DISTINCT (
	((SELECT MAX(salary) FROM salaries WHERE yearid = 2016) -
	(SELECT MIN(salary) FROM salaries WHERE yearid = 2016)) /
	(SELECT COUNT(*) FROM binids)) + 0.1
  FROM salaries)
  

SELECT
	CAST((salary - (SELECT MIN(salary) FROM salaries WHERE yearid = 2016)) / (SELECT * FROM gap) AS INT),
	(SELECT MIN(salary) FROM salaries WHERE yearid = 2016) + CAST((salary - (SELECT MIN(salary) FROM salaries WHERE yearid = 2016)) / (SELECT * FROM gap) AS INT) * (SELECT (MAX(gap)-0.1) FROM gap),
	(SELECT MIN(salary) FROM salaries WHERE yearid = 2016) + (CAST((salary - (SELECT MIN(salary) FROM salaries WHERE yearid = 2016)) / (SELECT * FROM gap) AS INT) + 1) * (SELECT (MAX(gap)-0.1) FROM gap),
	COUNT(salary)
FROM
	salaries AS s, gap as g
WHERE s.yearid = 2016
GROUP BY 
	FLOOR((salary - (SELECT MIN(salary) FROM salaries WHERE yearid = 2016)) / (SELECT * FROM gap));



;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS  
  WITH compare(cyearid, cmin, cmax, cavg) AS (
	SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
	FROM salaries AS s
	GROUP BY s.yearid
  )
  
  SELECT s.yearid,
		MIN(salary) - (SELECT cmin FROM compare WHERE compare.cyearid = s.yearid - 1),
		MAX(salary) - (SELECT cmax FROM compare WHERE compare.cyearid = s.yearid - 1),
		AVG(salary) - (SELECT cavg FROM compare WHERE compare.cyearid = s.yearid - 1)
  FROM salaries AS s, compare AS c
  WHERE s.yearid > (SELECT MIN(yearid) FROM salaries)
  GROUP BY s.yearid;
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid 
  FROM people AS p JOIN
  salaries AS s
  ON p.playerID = s.playerID
  WHERE s.yearid = 2000 AND s.salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2000)
  
  UNION ALL
  
SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid 
  FROM people AS p JOIN
  salaries AS s
  ON p.playerID = s.playerID
  WHERE s.yearid = 2001 AND s.salary = (SELECT MAX(salary) FROM salaries WHERE yearid = 2001)
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS  
  SELECT a.teamid, MAX(salary) - MIN(salary)
  FROM allstarfull AS a
  JOIN salaries AS s
  ON a.playerid = s.playerid
  WHERE a.yearid = 2016 AND s.yearid = 2016
  GROUP BY a.teamid
;

