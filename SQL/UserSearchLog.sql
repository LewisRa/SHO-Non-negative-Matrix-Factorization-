SELECT s.logtime ,
       s.search ,
       s.resultCount,
       q.SearchText QuickSearchText
  FROM
       ui_searchLog s INNER JOIN ui_VHALogins l
       ON s.LoginGUID = l.loginGUID
                      INNER JOIN ui_Users u
       ON u.ID = l.UserID
       left outer join ui_QSHistory q on q.SearchGUID = s.SearchGUID
  WHERE u.ID = 3803 -- assign user ID