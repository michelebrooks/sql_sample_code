# Business Inteliigence SQL Sample Code

This is a collection of sample SQL queries that I wrote for the business intelligence platform of a fintech company. 

They formed part of the logic for SSRS reports that business users would access via a self-service SharePoint BI portal to generate PDF and Powerpoint formatted results. Primary departments using these reports were the sales and account management teams, but report results were shared externally with clients as well.

*NB: sensitive information redacted. Please pardon gaps in the code*

### biShareShift.sql ###
Pulls information for customers that have been targeted with a specific ad campaign to compare how their spending habits changed at the advertiser. Customers are automatically assigned groups based on their prior spending habits at the advertiser (Frequent, Infrequent, Lapsed, Loyal, New and Switched from Competitor) and these groups are served different portions of the ad campaign.

### campaignCPSLTV.sql ###
Examines the long-term value of customers based on their changes in spending habits after being served an advertising campaignn. This report provides insights into how advertisers can best shape their future campaigns by looking beyond the campaign context into long-term spending habits.

The first three sections provide data tables that fill cascading parameter selections of SSRS report.

### competitorInteraction.sql ###
Compares the interaction of customers of a given set of brands. BI user selects a target brand and up to 10 competitors to see how much money and how often the target brand's customrs are visiting the selected competitors. It's used to inform help build intelligent ad campaigns that specifically target a brand's closest competitors.


