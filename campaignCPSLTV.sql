----dspCampaings-----

select distinct 
	o.campaignid
	, o.CampaignName || ' (CID :  ' || o.CampaignID || ')' as CampaignName
	,PricingModelInd 
FROM dw.vDM_OfferPlus as o 
where 7=7
and o.SentToOpsDT is not null
AND o.CampaignName iLIKE (?)
and o.PricingModelInd in (1,4,5,6)
order by campaignid desc


-----dspRedeemingMerchants------

select 
	v.CampaignID
	,m.SegmentID
	,m.SegmentName
from dw.vCampaignRedemptionMerchant v
join bi.vDM_AdCat m on v.SegmentID = m.SegmentID
where 7=7
and v.CampaignID in (?)  

-------dstDateThrough----------


select 
	max(weekenddt) as WeekEndDT
from dw.vFT_Merchant_AllCustomers
where 7=7
and InstitutionID in (2252,2726,2755)

---------dsCampaignLTV--------

WITH 
PricingModelCheck as
(
	Select distinct
		CampaignID 
		,PricingModelInd
	FROM dw.vDM_OfferPlus
	WHERE Campaignid=?
	and iscampaignsenttoops=1
)
,

ProjectionFactor AS
(
	SELECT
		SUM(CAST(SG_Trips AS NUMERIC(20,8))) / (SUM(CAST(SG_Trips AS NUMERIC(20,8))) + SUM(CAST
		(Other_Trips AS NUMERIC(20,8)))) AS ProjFactor
	FROM(
		SELECT
			CASE
				WHEN ((InstitutionID = 2726) OR  (InstitutionID = 2252)  OR  (InstitutionID = 2755))
				THEN COUNT(dwCustomerID)
				ELSE 0
			END AS SG_Trips ,
			CASE
				WHEN ((InstitutionID <> 2726) AND (InstitutionID <> 2252) AND (InstitutionID <> 2755))
				THEN COUNT(dwCustomerID)
				ELSE 0
			END AS Other_Trips
		FROM dw.vRedemptionplus vrp
		inner join PricingModelCheck pmc on vrp.Campaignid=pmc.Campaignid
		-- dw.vRedemptionplus vrp
		where RedemptionStateInd in ('A') 
		and vrp.campaignid = ?
		and segmentid IN(
			SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
            FROM(SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
			WHERE SPLIT_PART(?, ',', row_num) <> '')
		AND InstitutionID IN (3931, 2755, 2002, 2542, 2726, 5136, 2252, 6804, 3335, 5992, 7082, 7083, 7085, 7086)
		and pmc.PricingModelInd=1                     
		GROUP BY InstitutionID
	)Z
                    
	UNION ALL
	SELECT
		SUM(CAST(SG_Trips AS NUMERIC(20,8))) / (SUM(CAST(SG_Trips AS NUMERIC(20,8))) + SUM(CAST
		(Other_Trips AS NUMERIC(20,8)))) AS ProjFactor
	FROM(
		SELECT
			CASE
				WHEN ((InstitutionID = 2726) OR  (InstitutionID = 2252) OR  (InstitutionID = 2755))
				THEN COUNT(dwCustomerID)
				ELSE 0
			END AS SG_Trips ,
			CASE
				WHEN ((InstitutionID <> 2726) AND (InstitutionID <> 2252) AND (InstitutionID <> 2755))
				THEN COUNT(dwCustomerID)
				ELSE 0
			END AS Other_Trips
		FROM dw.vRPT_OfferSpend_ReportedSpend osrs
		inner join PricingModelCheck pmc2 on osrs.CampaignID=pmc2.Campaignid
		WHERE osrs.CampaignID = ?
		and pmc2.PricingModelInd IN (4,5,6)
		and segmentid IN
			(SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
			FROM(SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
			WHERE SPLIT_PART(?, ',', row_num) <> '')
		AND InstitutionID IN (3931,2755,2002,2542,2726,5136,2252,6804,3335,5992,7082,7083,7085,7086)
		GROUP BY InstitutionID 
	) AS Y
)


,
CampaignCustomers AS
(
	SELECT DISTINCT
		OE.InstitutionID,
		OE.dwCustomerID AS dwCustID,           
		CASE
			WHEN OP.CustomerType = 'Existing'
			THEN 'Infrequent'
			ELSE OP.CustomerType
		END AS Segment
	FROM dw.vredemptionplus OE
	JOIN dw.vDM_OfferPlus AS OP ON OE.CampaignID = OP.CampaignID AND OE.OfferID=op.OfferID
	inner join PricingModelCheck pmc on oe.Campaignid=pmc.Campaignid
	WHERE OE.CampaignID = ?
	AND OE.institutionid IN (2726,2252,2755)
	and RedemptionStateInd in ('A')
	and segmentid IN
		(SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
		FROM(SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
	and pmc.PricingModelInd=1
          
	UNION ALL
          
	SELECT DISTINCT
		OE.InstitutionID,
		OE.dwCustomerID AS dwCustID,           
		CASE
			WHEN OP.CustomerType = 'Existing'
			THEN 'Infrequent'
			ELSE OP.CustomerType
		END AS Segment
	FROM dw.vft_CustomerOfferEvent OE
	JOIN dw.vDM_OfferPlus AS OP ON OE.CampaignID = OP.CampaignID AND OE.OfferID=op.OfferID
	join PricingModelCheck pmc2 on pmc2.Campaignid=oe.CampaignID
	WHERE OE.CampaignID = ? 
	AND OE.institutionid IN (2726,2252,2755)
	AND OE.EventID IN (60010)
	and pmc2.PricingModelInd IN (4,5,6)
	AND EXISTS 
		(SELECT 1 
		FROM dw.vRPT_OfferSpend_ReportedSpend rs 
		WHERE rs.CampaignID = ? 
		and segmentid IN
			(SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
			FROM(SELECT ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
			WHERE SPLIT_PART(?, ',', row_num) <> '')
		AND rs.institutionid IN (2726,2252,2755)
		AND rs.dwCustomerID = OE.dwCustomerID 
		)
) 

      
,  
CampaignSpendTrips AS
(
	SELECT
		CustomerType AS Segment,
		SUM(RedeemingTransactionAmount) AS Spend,
		count(distinct dwCustomerID) AS Trips
	FROM dw.vredemptionplus PS
	JOIN dw.vDM_OfferPlus OP on PS.CampaignID=OP.CampaignID AND PS.OfferID=OP.OfferID
	join PricingModelCheck pmc on ps.campaignid=pmc.campaignid
	WHERE OP.CampaignID=? 
	and redemptionstateind in ('A')
	and segmentid IN
		(SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
		FROM(SELECT  ROW_NUMBER() OVER () AS row_num FROM bi.vDM_AdCat) row_nums
		WHERE SPLIT_PART(?, ',', row_num) <> '')
	AND InstitutionID IN (3931,2755,2002,2542,2726,5136,2252,6804,3335,5992,7082,7083,7085,7086)
	and pmc.PricingModelInd=1
	GROUP BY CustomerType
            
	UNION ALL
            
	SELECT
		CustomerType AS Segment,
		SUM(SpendPostServe) AS Spend,
		SUM(TripsPostServe) AS Trips
	FROM  bi.vAG_CampaignOfferPostServeByFI PS
	JOIN dw.vDM_OfferPlus OP ON PS.CampaignID=OP.CampaignID AND PS.OfferID=OP.OfferID
	join PricingModelCheck pmc2 on ps.CampaignID=pmc2.CampaignID
	WHERE OP.CampaignID=?
	AND InstitutionID IN (3931,2755,2002,2542,2726,5136,2252,6804,3335,5992,7082,7083,7085,7086)
	and pmc2.PricingModelInd IN (4,5,6)
	GROUP BY CustomerType      
) 
    
,
CustomerDates2 AS
(       
	SELECT Distinct
		campaignid ,    
		AD_WeekStart as WeekStartDt,
		AD_WeekEnd as WeekEndDt           
	FROM dw.vdm_offerplus i
	INNER JOIN dw.vdm_date h  ON h.calendardate BETWEEN i.offerstartdt AND i.offerenddt    --i.offerredemptionenddt     
	WHERE   CampaignID=?
) 
   
,
CampaignDateRange AS
(
	SELECT
		MIN(T.WeekStartDT) AS weekStartDTC,
		MAX(T.WeekEndDT)   AS weekEndDTC,
		TIMESTAMPADD('d',(DATEDIFF('d',MIN(T.WeekStartDT),MAX(T.WeekEndDT))*-1),TIMESTAMPADD
		('d',-1,MIN(T.WeekStartDT))) AS prePeriodStartDT,
		TIMESTAMPADD('d',-1,MIN(T.WeekStartDT)) AS prePeriodEndDT,
		TIMESTAMPADD('d',1,MAX(T.WeekEndDT)) AS post1StartDT,
		TIMESTAMPADD('d',?::INTEGER,TIMESTAMPADD('d',1,MAX(T.WeekEndDT))) AS post1EndDT,
		TIMESTAMPADD('d',1,TIMESTAMPADD('d',?::INTEGER,TIMESTAMPADD('d',1,MAX(T.WeekEndDT)))) AS post2StartDT,
		TIMESTAMPADD('d',?::INTEGER,TIMESTAMPADD('d',1,TIMESTAMPADD('d',?::INTEGER,TIMESTAMPADD('d',1,MAX(T.WeekEndDT))))) AS post2EndDT
	FROM CustomerDates2 AS T       
) 
,
CampaignPeriods AS
(
	Select 'Offer' as Period,WeekStartDTC as RangeStart,WeekEndDTC as RangeEnd From CampaignDateRange
	UNION ALL
	Select 'Pre' as Period,prePeriodStartDT as RangeStart,prePeriodEndDT as RangeEnd From CampaignDateRange
	UNION ALL
	Select 'Post1' as Period,post1StartDT as RangeStart,post1EndDT as RangeEnd From CampaignDateRange
	UNION ALL
	Select 'Post2' as Period,post2StartDT as RangeStart,post2EndDT as RangeEnd From CampaignDateRange
    
)  
    ,
Transactions AS
(
	SELECT
		dwAccountID,
		dwCustomerID,
		WeekStartDt,
		WeekEndDt,
		SegmentID,
		InstitutionID,
		FiMerchantID,
		Trips,
		Amount
	FROM(
		SELECT
			dwAccountID,
			dwCustomerID,
			WeekStartDt,
			WeekEndDt,
			SegmentID,
			InstitutionID,
			FiMerchantID,
			Trips,
			Amount,
			dense_rank () OVER (partition BY dwAccountID,WeekStartDt,FiMerchantID, Amount,
			Trips ORDER BY dwCustomerID) AS rank
		FROM(
			SELECT
				TRANS.dwAccountID,
				TRANS.dwCustomerID,
				TRANS.WeekStartDt,
				TRANS.WeekEndDt,
				TRANS.SegmentID,
				TRANS.InstitutionID,
				TRANS.FiMerchantID,
				TRANS.Trips,
				TRANS.Amount
			FROM dw.vFT_Merchant_AllCustomers TRANS
			WHERE TRANS.InstitutionID IN ( 2252, 2726, 2755 )
			AND TRANS.SegmentID  IN
				(SELECT SPLIT_PART(?, ',', row_num) "TargetSegmentIDParam"
				FROM(SELECT  ROW_NUMBER() OVER () AS row_num  FROM bi.vDM_AdCat) row_nums
				WHERE SPLIT_PART(?, ',', row_num) <> '')
			AND TRANS.WeekStartDT >=(SELECT prePeriodStartDT FROM CampaignDateRange)
			AND EXISTS(SELECT 1 FROM CampaignCustomers WHERE dwCustID = TRANS.dwCustomerID)
			GROUP BY 1,2,3,4,5,6,7,8,9
			ORDER BY 1,2,3,4,5,6,7,8,9 
		)AS y 
	)AS x
        WHERE x.rank = 1
        ORDER BY WeekStartDT
) 
,
TransactionsByType AS
(
	SELECT          
		T.Period,
		S.Segment,
		SUM(q.Trips) AS Trips,
		ROUND(Sum(q.Trips) / u.ProjFactor,0) AS FactoredTrips,
		SUM(q.Amount/ u.ProjFactor) AS Amount
        FROM Transactions AS q
        JOIN campaigncustomers AS S ON q.dwCustomerID = s.dwCustID
        JOIN CampaignPeriods AS T on q.WeekStartDT >= T.RangeStart and q.WeekEndDt <= T.RangeEnd
        JOIN ProjectionFactor AS u on 1=1
        WHERE Not (S.Segment = 'New' And (T.Period = 'Pre' or T.Period = 'Offer') 
        and u.ProjFactor is not null)       
        GROUP BY
            u.ProjFactor,
            Period ,
            S.Segment 
	UNION ALL
	SELECT
		'Offer' AS Period,
		'New' AS Segment,
		ISNULL(Trips,0) AS Trips,
		ISNULL(Trips,0) AS FactoredTrips,
		ISNULL(Amount,0) AS Amount 
	FROM CampaignDateRange AS u
	JOIN(Select Spend as Amount,Trips  from CampaignSpendTrips Where Segment = 'New')RedemptionNew on 1=1
	JOIN ProjectionFactor as pf on 1=1
	where pf.projfactor is not null 
	UNION ALL
	SELECT
		'Pre' AS Period,
		'New' AS Segment,
		0 AS Trips,
		0 AS FactoredTrips,
		0 AS Amount
	FROM CampaignDateRange AS u  
)
SELECT /*+label(biReports_campaignLTV_LTV)*/
    Period ,
    z.Segment ,
    CAST(SUM(FactoredTrips) AS INT) AS Trips,
    CAST(SUM(Amount) AS INT)        AS Spend,
    PS.Spend as CampSpend,
    PS.Trips as CampTrips,
	T.weekStartDTC ,
	T.weekEndDTC ,
	T.prePeriodStartDT ,
	T.prePeriodEndDT ,
	T.post1StartDT ,
	T.post1EndDT ,
	T.post2StartDT ,
	T.post2EndDT ,
	u.ProjFactor
FROM TransactionsByType z
JOIN CampaignSpendTrips PS ON z.Segment=PS.Segment
JOIN CampaignDateRange AS T ON 1=1
JOIN ProjectionFactor AS u ON 1=1
where z.FactoredTrips is not null
and z.Amount is not null
and u.projfactor is not null
GROUP BY
	z.Period ,
	z.Segment ,
	PS.Spend,
    PS.Trips,
	T.weekStartDTC ,
	T.weekEndDTC ,
	T.prePeriodStartDT ,
	T.prePeriodEndDT ,
	T.post1StartDT ,
	T.post1EndDT ,
	T.post2StartDT ,
	T.post2EndDT ,
	u.ProjFactor
UNION ALL
SELECT
    'NewTotal' AS Period,
    'New' AS Segment,
    CAST(SUM(FactoredTrips) AS INT) AS Trips,
    CAST(SUM(Amount) AS INT) AS Spend ,
	PS.Spend as CampSpend,
    PS.Trips as CampTrips,
	T.weekStartDTC ,
	T.weekEndDTC ,
	T.prePeriodStartDT ,
	T.prePeriodEndDT ,
	T.post1StartDT ,
	T.post1EndDT ,
	T.post2StartDT ,
	T.post2EndDT ,
	u.ProjFactor
FROM TransactionsByType z
JOIN CampaignSpendTrips PS ON z.Segment=PS.Segment
JOIN CampaignDateRange AS T ON 1=1
JOIN ProjectionFactor AS u ON 1=1
WHERE z.Segment = 'New'
and z.FactoredTrips is not null
and z.Amount is not null
and u.projfactor is not null
GROUP BY
    PS.Spend,
    PS.Trips,
	T.weekStartDTC ,
	T.weekEndDTC ,
	T.prePeriodStartDT ,
	T.prePeriodEndDT ,
	T.post1StartDT ,
	T.post1EndDT ,
	T.post2StartDT ,
	T.post2EndDT ,
	u.ProjFactor
order by Segment,Period