-- Can combine Search log and watch log and order by time, will see what videos the user watched after search

SELECT *
from (
SELECT s.logtime ,
       s.search ,
       s.resultCount,
       q.SearchText QuickSearchText,
       null testimonyid,
       null segmentnumber
  FROM
       ui_searchLog s INNER JOIN ui_VHALogins l
       ON s.LoginGUID = l.loginGUID
                      INNER JOIN ui_Users u
       ON u.ID = l.UserID
       left outer join ui_QSHistory q on q.SearchGUID = s.SearchGUID
  WHERE u.ID = 3803 -- assign user ID
union
SELECT s.LogTime ,
null search,
null resoutcount,
null quicksearchtext,
       TestimonyID ,
       segmentnumber
  FROM ui_searchhistory s , ui_VHALogins l , ui_Users u
  WHERE s.LoginGUID = l.loginGUID
    AND u.ID = l.UserID
    AND u.ID = 3803 -- assign user ID
) a
order by logtime 