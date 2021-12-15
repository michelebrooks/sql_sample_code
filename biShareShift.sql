WITH 
pricingModelCheck as
(
	select distinct
		CampaignID ,
		PricingModelInd,
		CampaignStartDT,
		CampaignEndDT
	from  dw.vDM_OfferPlus
	where CampaignID ='29706'::integer
	and iscampaignsenttoops=1
)

,
prePeriodDates as 
(
	select
		AD_WeekStart as PrePeriodStart
		,AD_WeekStart as PrePeriodEnd
		,AD_WeekStart as CampaignPeriodStart
		,AD_WeekStart as CampaignPeriodEnd
	from dw.vDM_Date
	where

)

,
redeemingSegments as
(
	select SPLIT_PART('22300,34072,34074,34076,34078,34800,34805,50408,50618,50836,80500,80505', ',', row_num) "SegmentID"
	from (select ROW_NUMBER() OVER () as row_numfrom tables) row_nums
	where SPLIT_PART('22300,34072,34074,34076,34078,34800,34805,50408,50618,50836,80500,80505', ',', row_num) <> ''
)

,
selectedBrands AS
(
	SELECT BrandID, SegmentID, 'AdvertiserID' as SelectedGroup, 0 as GroupID
	FROM bi.vDM_AdCat ac
	WHERE exists(select 1 from redeemingSegments where segmentid = ac.segmentid)

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
