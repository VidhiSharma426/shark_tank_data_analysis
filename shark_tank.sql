-- 1 You Team have to  promote shark Tank India  season 4, The senior come up with the idea to show highest funding domain wise  
-- and you were assigned the task to  show the same.
select max(funding),Industry from (
select Total_Deal_Amount_in_lakhs as funding , Industry from sharktank order by funding desc ) t group by Industry;

-- 2 You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
select Industry,(female / male )* 100 as ratio from (
select Industry, sum(Female_Presenters) as 'female' , sum(Male_Presenters) as 'male'  from sharktank group by Industry having sum(Female_Presenters)>0 and
sum(Male_Presenters)>0 
)t
where (female / male )* 100 > 70;

-- 3 You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per year sale pitch made, pitches who received 
-- offer and pitches that were converted. Also show the percentage of pitches converted and percentage of pitches received.

-- 4 As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show,
-- how would you determine the season with the
-- highest average monthly sales and identify the top 5 industries with the highest average monthly sales during 
-- that season to optimize investment decisions?
WITH cte AS (
    SELECT MAX(Season_Number) AS max_season 
    FROM sharktank
)
SELECT Industry, AVG(Monthly_Sales_in_lakhs) AS avg_monthly_sales
FROM sharktank
WHERE Season_Number = (SELECT max_season FROM cte)
GROUP BY Industry order by avg_monthly_sales desc limit 5 ;



-- 5.As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with 
-- consistent increases in funds raised over 
-- multiple seasons. This requires focusing on industries where data is available across all three years.
--  Once these industries are pinpointed, your task is to delve into the specifics, analyzing the number of pitches made, offers received, and offers 
-- converted per season within each industry.

WITH ValidIndustries AS 
(SELECT industry, 
        MAX(CASE WHEN season_number = 1 THEN total_deal_amount_in_lakhs END) AS season_1,
        MAX(CASE WHEN season_number = 2 THEN total_deal_amount_in_lakhs END) AS season_2,
        MAX(CASE WHEN season_number = 3 THEN total_deal_amount_in_lakhs END) AS season_3
    FROM sharktank 
    GROUP BY industry 
    HAVING season_3 > season_2 AND season_2 > season_1 AND season_1 != 0
) 
-- select * from validindustries
select * from sharktank as t  inner join validindustries as v on t.industry= v.industry ; 
SELECT 
    t.season_number,
    t.industry,
    COUNT(t.startup_Name) AS Total,
    COUNT(CASE WHEN t.received_offer = 'Yes' THEN t.startup_Name END) AS Received,
    COUNT(CASE WHEN t.accepted_offer = 'Yes' THEN t.startup_Name END) AS Accepted
FROM sharktank AS t
JOIN ValidIndustries AS v ON t.industry = v.industry
GROUP BY t.season_number, t.industry;   

-- 6. Every shark want to  know in how much year their investment will be returned, so you have to create a system for them , 
-- where shark will enter the name of the 
-- startup's  and the based on the total deal and equity given in how many years their principal amount will be returned.

delimiter //
create procedure ROI( in startup varchar(100))
begin
   case 
      when (select Accepted_offer ='No' from sharktank where startup_name = startup)
	        then  select 'Turn Over time cannot be calculated';
	 when (select Accepted_offer ='yes' and Yearly_Revenue_in_lakhs = 0 from sharktank where startup_name= startup)
           then select 'Previous data is not available';
	 else
         select `startup_name`,`Yearly_Revenue_in_lakhs`,`Total_Deal_Amount_in_lakhs`,`Total_Deal_Equity_percent`, 
         `Total_Deal_Amount_in_lakhs`/((`Total_Deal_Equity_percent`/100)*`Total_Deal_Amount_in_lakhs`) as 'years'
		 from sharktank where Startup_Name= startup;
	
    end case;
end
//
DELIMITER ;

call ROI('TagzFoods');

-- 7. In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put 
-- the most money into each
-- deal on average. This comparison helps us see who's the most generous with their investments and 
-- easure up against their fellow investors.
select sharkname, round(avg(investment),2)  as 'average' from
(
SELECT `Namita_Investment_Amount_in_lakhs` AS investment, 'Namita' AS sharkname FROM sharktank WHERE `Namita_Investment_Amount_in_lakhs` > 0
union all
SELECT `Vineeta_Investment_Amount_in_lakhs` AS investment, 'Vineeta' AS sharkname FROM sharktank WHERE `Vineeta_Investment_Amount_in_lakhs` > 0
union all
SELECT `Anupam_Investment_Amount_in_lakhs` AS investment, 'Anupam' AS sharkname FROM sharktank WHERE `Anupam_Investment_Amount_in_lakhs` > 0
union all
SELECT `Aman_Investment_Amount_in_lakhs` AS investment, 'Aman' AS sharkname FROM sharktank WHERE `Aman_Investment_Amount_in_lakhs` > 0
union all
SELECT `Peyush_Investment_Amount_in_lakhs` AS investment, 'peyush' AS sharkname FROM sharktank WHERE `Peyush_Investment_Amount_in_lakhs` > 0
union all
SELECT `Amit_Investment_Amount_in_lakhs` AS investment, 'Amit' AS sharkname FROM sharktank WHERE `Amit_Investment_Amount_in_lakhs` > 0
union all
SELECT `Ashneer_Investment_Amount` AS investment, 'Ashneer' AS sharkname FROM sharktank WHERE `Ashneer_Investment_Amount` > 0
)k group by sharkname

-- 8. Develop a system that accepts inputs for the season number and the name of a shark. The procedure will then provide detailed insights into the total investment made by 
-- that specific shark across different industries during the specified season. Additionally, it will calculate the percentage of their investment in each sector relative to
-- the total investment in that year, giving a comprehensive understanding of the shark's investment distribution and impact.

DELIMITER //
create PROCEDURE getseason_investment(IN season INT, IN sharkname VARCHAR(100))
BEGIN
      
    CASE 

        WHEN sharkname = 'namita' THEN
            set @total = (select  sum(`Namita_Investment_Amount_in_lakhs`) from sharktank where Season_Number= season );
            SELECT Industry, sum(`Namita_Investment_Amount_in_lakhs`) as 'sum' ,(sum(`Namita_Investment_Amount_in_lakhs`)/@total)*100 as 'Percent' FROM sharktank WHERE season_Number = season AND `Namita_Investment_Amount_in_lakhs` > 0
            group by industry;
        WHEN sharkname = 'Vineeta' THEN
            SELECT industry,sum(`Vineeta_Investment_Amount_in_lakhs`) as 'sum' FROM sharktank WHERE season_Number = season AND `Vineeta_Investment_Amount_in_lakhs` > 0
            group by industry;
        WHEN sharkname = 'Anupam' THEN
            SELECT industry,sum(`Anupam_Investment_Amount_in_lakhs`) as 'sum' FROM sharktank WHERE season_Number = season AND `Anupam_Investment_Amount_in_lakhs` > 0
            group by Industry;
        WHEN sharkname = 'Aman' THEN
            SELECT industry,sum(`Aman_Investment_Amount_in_lakhs_`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Aman_Investment_Amount_in_lakhs_` > 0
             group by Industry;
        WHEN sharkname = 'Peyush' THEN
             SELECT industry,sum(`Peyush_Investment_Amount_in_lakhs`) as 'sum'  FROM sharktank WHERE season_Number = season AND `Peyush_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Amit' THEN
              SELECT industry,sum(`Amit_Investment_Amount_in_lakhs`) as 'sum'   WHERE season_Number = season AND `Amit_Investment_Amount_in_lakhs` > 0
             group by Industry;
        WHEN sharkname = 'Ashneer' THEN
            SELECT industry,sum(`Ashneer_Investment_Amount`)  FROM sharktank WHERE season_Number = season AND `Ashneer_Investment_Amount` > 0
             group by Industry;
        ELSE
            SELECT 'Invalid shark name';
    END CASE;
    
END //
DELIMITER ;
drop procedure getseason_investment;
call getseason_investment(2, 'Anupam')
