WITH selectedBrands AS
(
	SELECT BrandID, SegmentID, 'AdvertiserID' as SelectedGroup, 0 as GroupID
	FROM bi.vDM_AdCat
	WHERE BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "TargetAdvertiserParam"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')

	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup1' as SelectedGroup, 1 as GroupID
	from bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor1Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup2' as SelectedGroup, 2 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor2Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup3' as SelectedGroup, 3 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor3Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup4' as SelectedGroup, 4 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor4Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup5' as SelectedGroup, 5 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor5Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup6' as SelectedGroup, 6 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor6Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup7' as SelectedGroup, 7 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor7Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup8' as SelectedGroup, 8 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor8Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup9' as SelectedGroup, 9 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor9Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
		
	UNION
	
	Select BrandID, SegmentID,'CompetitorGroup10' as SelectedGroup, 10 as GroupID
	FROM bi.vDM_AdCat
	Where BrandID IN 
		(SELECT SPLIT_PART(?, ',', row_num) "Competitor1Param"
		FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
)


,CategoryBrandSegments as 
(
	Select 
		sb.BrandID
		,sb.SegmentID
		,SelectedGroup
		,GroupID			
	From selectedBrands sb 
	inner join bi.vDM_AdCat ac on sb.SegmentID = ac.SegmentID

	UNION
	
	SELECT
		BrandID
		,SegmentID
		,'CompetitorGroupOtherCategory' AS SelectedGroup
		,11 as GroupID
	FROM bi.vDM_AdCat
	WHERE SegmentCategoryID IN
		(SELECT SPLIT_PART(?, ',', row_num) "CompetitorGroupOtherCategoryParam"
		FROM(SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
) 


,DMAList as
( 
	SELECT 
		rankgeo.ZipID
	FROM 
	(         
        SELECT 
        cbaccy.ZipID
        ,Sum(1) as Customers 
        ,NTILE(10) OVER(ORDER BY Sum(1) DESC) AS rank                                           
        FROM bi.vAG_CustomerBrandActCustCY cbaccy
        Inner join bi.GeoDMA geo on cbaccy.ZipID = geo.ZipID
        WHERE  exists (select 1 from categorybrandsegments cbs WHERE GroupID = 0 AND cbaccy.BrandID=cbs.BrandID)        
        and case 
			when ? = 1 then 24=24
			else DMA_CODE IN 
				(SELECT SPLIT_PART(?, ',', row_num) "DMAParam"
				FROM (SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_DMARegion) row_nums
                WHERE SPLIT_PART(?, ',', row_num) <> '')
		end        
        GROUP BY cbaccy.ZipID        
	) rankgeo                                                                                                                         
	WHERE 24=24
	and rankgeo.Rank <= 2 
	AND rankgeo.Customers > 1
)


,CustomerSet AS  
(		
	SELECT         
        cust.dwCustomerID
        ,cust.ZipID
	FROM            
	(
		SELECT 
			dwCustomerID
			,ZipID
		FROM bi.vAG_CustomerBrandActCustCY cbaccy	
		WHERE  exists (select 1 from CategoryBrandSegments cbs  WHERE GroupID = 0 AND cbaccy.BrandID = cbs.BrandID) 		
		GROUP BY 1,2
	) cust 
	WHERE exists (select 1 from DMAList dma where cust.ZipID = dma.ZipID)
) 

,NetworkData AS 
(                
	SELECT             
		cbs.SelectedGroup 
        ,cbs.GroupID 
        ,isnull(COUNT(DISTINCT cbaccy.dwCustomerID),0)::int AS NetworkMerchCustomers
        ,isnull(Sum(cbaccy.Trips),0)::int as TotalNetworkTrips
        ,isnull(Sum(cbaccy.Amount),0)::int as TotalNetworkSpend
	FROM bi.vAG_CustomerBrandActCustCY  cbaccy 
	INNER JOIN CategoryBrandSegments cbs ON cbaccy.BrandID = cbs.BrandID
	where exists (select 1 from DMAList dma where cbaccy.ZipID = dma.ZipID)
	Group by 
		cbs.SelectedGroup 
        ,cbs.GroupID 

)
,CustomerSetData AS 
(                
	SELECT               
        cbs.SelectedGroup 
        ,cbs.GroupID 
        ,isnull(COUNT(DISTINCT cbaccy.dwCustomerID),0)::int AS UniqueCustomerSetCustomers
        ,isnull(Sum(cbaccy.Trips),0)::int as TotalCustomerSetTrips
        ,isnull(Sum(cbaccy.Amount),0)::int as TotalCustomerSetSpend
		,MAX(cbaccy.WeekStartDT_MAX) as WeekDT
	FROM bi.vAG_CustomerBrandActCustCY cbaccy     
	INNER JOIN CategoryBrandSegments cbs ON cbaccy.BrandID = cbs.BrandID
	where exists (select 1 from CustomerSet cs where cbaccy.dwCustomerID = cs.dwcustomerID) 
	Group by 
		 cbs.SelectedGroup 
        ,cbs.GroupID 
) 

,RawData as 
(
        SELECT 
        nd.SelectedGroup
        ,nd.GroupID
        ,isnull(nd.NetworkMerchCustomers,0)::int as NetworkMerchCustomers
        ,isnull(nd.TotalNetworkTrips,0)::int as TotalNetworkTrips
        ,isnull(nd.TotalNetworkSpend,0)::int as TotalNetworkSpend
        ,isnull(UniqueCustomerSetCustomers,0)::int as UniqueCustomerSetCustomers
        ,isnull(TotalCustomerSetTrips,0)::int as TotalCustomerSetTrips
        ,isnull(TotalCustomerSetSpend,0)::int as TotalCustomerSetSpend
		,csd.WeekDT
	From NetworkData nd
	Left Join CustomerSetData csd on nd.SelectedGroup = csd.SelectedGroup and nd.GroupID = csd.GroupID
) 
,AdvertiserInfo AS
(
	SELECT 
		SelectedGroup
		,TotalCustomerSetTrips::int
		,TotalCustomerSetSpend::int
		,UniqueCustomerSetCustomers::int
	FROM CustomerSetData as csd
	WHERE csd.GroupID = 0                                  
)
              
,NetworkInfo AS 
(
	SELECT          
        COUNT(DISTINCT dwCustomerID) AS NetworkCustomers
	FROM bi.vAG_CustomerBrandActCustCY cbaccy
	where exists (select 1 from DMAList dma where cbaccy.zipid = dma.zipid)              
) 
 
 
SELECT  /*+label(biReports_competitorInteraction_dsCompetitorInteraction)*/ DISTINCT
	cbs.SelectedGroup
	,cbs.GroupID
	,(CASE WHEN rd.TotalCustomerSetTrips IS NULL or rd.TotalCustomerSetTrips=0 THEN .00001 ELSE rd.TotalCustomerSetTrips END) as TotalTrips
	,(CASE WHEN rd.TotalCustomerSetSpend IS NULL or rd.TotalCustomerSetSpend=0 THEN .00001 ELSE rd.TotalCustomerSetSpend END)  as TotalSpend
	,(CASE WHEN rd.UniqueCustomerSetCustomers IS NULL OR rd.UniqueCustomerSetCustomers=0 THEN .00001 ELSE rd.UniqueCustomerSetCustomers END) as UniqueCustomers
	,(CASE WHEN rd.NetworkMerchCustomers IS NULL OR rd.NetworkMerchCustomers=0 THEN .00001 ELSE rd.NetworkMerchCustomers END) as NetworkMerchCustomers
	,(CASE WHEN rd.TotalNetworkTrips IS NULL OR rd.TotalNetworkTrips=0 THEN .000001 ELSE rd.TotalNetworkTrips END) as TotalNetworkTrips
	,(CASE WHEN rd.TotalNetworkSpend IS NULL OR rd.TotalNetworkSpend=0 THEN .000001 ELSE rd.TotalNetworkSpend END) as TotalNetworkSpend
	,(CASE WHEN rd.TotalCustomerSetTrips IS NULL OR rd.TotalCustomerSetTrips = 0 THEN .000001 ELSE ((CASE WHEN rd.TotalCustomerSetTrips > 0 THEN (rd.TotalCustomerSetTrips / ai.TotalCustomerSetTrips)*10 ELSE 0 END)) END)::Numeric(20,6) AS TripsPerAdTrips
	,(CASE WHEN rd.TotalCustomerSetSpend IS NULL OR rd.TotalCustomerSetSpend = 0 THEN .000001 ELSE((CASE WHEN rd.TotalCustomerSetSpend > 0 THEN (rd.TotalCustomerSetSpend / ai.TotalCustomerSetSpend)*10 ELSE 0 END)) END)::Numeric(20,6) AS SpendPerAdSpend
	,(CASE WHEN rd.UniqueCustomerSetCustomers IS NULL OR rd.UniqueCustomerSetCustomers = 0 THEN .000001 ELSE ((CASE WHEN rd.UniqueCustomerSetCustomers > 0 THEN (rd.UniqueCustomerSetCustomers / ai.UniqueCustomerSetCustomers) ELSE 0 END))*100 END)::Numeric(20,6) AS Perc_Advertiser
	,(CASE WHEN rd.NetworkMerchCustomers IS NULL OR rd.NetworkMerchCustomers = 0 THEN .000001 ELSE ((CASE WHEN rd.NetworkMerchCustomers > 0 THEN (rd.NetworkMerchCustomers / ni.NetworkCustomers) ELSE 0 END))*100 END)::Numeric(20,6) AS Perc_Network
	,((CASE WHEN rd.UniqueCustomerSetCustomers > 0 THEN (rd.UniqueCustomerSetCustomers / ai.UniqueCustomerSetCustomers)*100 ELSE .000001 END) / (CASE WHEN rd.NetworkMerchCustomers > 0 THEN rd.NetworkMerchCustomers / ni.NetworkCustomers ELSE 1 END)) as IndexNum
	,rd.WeekDT         
FROM CategoryBrandSegments as cbs
CROSS JOIN AdvertiserInfo as ai 
CROSS JOIN NetworkInfo as ni
Left Join RawData as rd on cbs.SelectedGroup = rd.SelectedGroup AND cbs.GroupID = rd.GroupID             
order by groupid

;