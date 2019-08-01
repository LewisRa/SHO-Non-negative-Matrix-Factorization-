DECLARE
   @parentTermID int ,
   @path nvarchar( 256 ) ,
   @keywordID int;
 
SET @keywordID = 9646;  -- assign keywordID
SET @path = CAST( @keywordID AS nvarchar( 256 ));
SELECT TOP 1 @parentTermID = expr$1
  FROM(
        SELECT DISTINCT dbo.rpt_Thesaurus3.ParentTermID AS expr$1 ,
                        dbo.rpt_Thesaurus3.ParentPreferred AS expr$2 ,
                        dbo.rpt_Thesaurus3.ThesaurusType
          FROM dbo.rpt_Thesaurus3
          WHERE dbo.rpt_Thesaurus3.TermID = @keywordID
            AND dbo.rpt_Thesaurus3.ThesaurusType = 1
            AND dbo.rpt_Thesaurus3.ParentType = 2 )AS t
  ORDER BY ThesaurusType DESC , expr$2 DESC;
     
 
 
WHILE-1 <> @parentTermID
AND @parentTermID <> 0
    BEGIN
        SET @path = CAST( @parentTermID AS nvarchar( 10 )) + '/' + @path;
        SET @keywordID = @parentTermID;
        SELECT TOP 1 @parentTermID = expr$1
          FROM(
                SELECT DISTINCT dbo.rpt_Thesaurus3.ParentTermID AS expr$1 ,
                                dbo.rpt_Thesaurus3.ParentPreferred AS expr$2 ,
                                dbo.rpt_Thesaurus3.ThesaurusType
                  FROM dbo.rpt_Thesaurus3
                  WHERE dbo.rpt_Thesaurus3.TermID = @keywordID
                    AND dbo.rpt_Thesaurus3.ThesaurusType = 2
                    AND dbo.rpt_Thesaurus3.ParentType = 2 )AS t
          ORDER BY ThesaurusType DESC , expr$2 DESC;
    END;
   
 
SELECT @path;