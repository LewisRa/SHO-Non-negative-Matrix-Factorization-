DECLARE
   @userId int ,
   @startDate datetime ,
   @endDate datetime;
  
-- assing userID, startdate, endDate
SELECT @userId = 3803 ,
       @startDate = '2015/6/1' ,
       @endDate = '2015/7/1';
 
SELECT loginDate ,
       loginCount ,
       searchCount ,
       SUM( ISNULL( viewCount , 0 ))viewCount
  FROM
       (
         SELECT CONVERT( varchar( 10 ) , loginTime , 101 )loginDate ,
                COUNT( DISTINCT ui_vhalogins.loginGUID )LoginCount ,
                COUNT( DISTINCT ui_searchLog.searchGUID )searchCount
           FROM
                ui_vhalogins LEFT OUTER JOIN ui_searchLog
                ON ui_vhaLogins.loginGUID = ui_searchLog.loginGUID
           WHERE ui_vhalogins.userID = @userId
             AND logintime >= @startDate
             AND logintime < @endDate
           GROUP BY CONVERT( varchar( 10 ) , loginTime , 101 ))a LEFT OUTER JOIN(
                                                                                  SELECT COUNT( DISTINCT testimonyID )viewCount ,
                                                                                         CONVERT( varchar( 10 ) , logTime , 101 )logDate ,
                                                                                         loginguid
                                                                                    FROM ui_searchHistory
                                                                                    WHERE ui_searchHistory.userID = @userId
                                                                                      AND ui_searchHistory.logtime >= @startDate
                                                                                      AND ui_searchHistory.logtime < @endDate
                                                                                    GROUP BY CONVERT( varchar( 10 ) , logTime , 101 ) ,
                                                                                             loginguid )views
       ON loginDate = logDate
  GROUP BY loginDate ,
           loginCount ,
           searchCount;