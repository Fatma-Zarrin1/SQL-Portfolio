Use Database_ABC
go

----------------------**************************************************--------------------------------

with Dep_CTE 
as
(select yearMonth,Cust_ID,
case when yearMonth = '202404' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_APR,

case when yearMonth = '202405' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_MAY,

case when yearMonth = '202406' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_JUN,

case when yearMonth = '202407' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_JUL,

case when yearMonth = '202408' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_AUG,

case when yearMonth = '202409' and Cust_Status = 'Active' and product_defined = 'After_22'
and Pay_mode in ('A_online','B_Agent','C_Nearby','D_Cash','E_Scan') then 1 else 0 end Dep_SEP
from Record
where yearMonth >= '202404' and client = 'ABC' AND
Cust_Status = 'Active')

Select 
A.location_code,
A.location_name,
A.LocationCode AS A_location,	
A.cust_name,	
A.Cust_ID,
A.product,
A.originator_name AS originator,	
A.collector_name,	
A.totalamount,	
A.principalamount,
A.interest,	
A.pay_date,	
A.installment_no,	
A.total_due_amount,	
A.first_emi_date,
A.first_emi_amount,
A.last_emi_date,	
A.last_emi_amount,
A.advanceamount,	
A.saving_Cust_ID,	
A.State,
A.Area,	
A.District,
A.LocationCode AS A_location,
A.Location,
case when A.Emp_ID is not null then RIGHT(A.Emp_ID,4) else A.Emp_ID end [EMP ID],	
A.CSR_NAME AS [CSR NAME],
A.Due_Amt AS Due_Amt,
A.MOBILE_Number AS Mobile_No,
a.EMI_AMT AS EMI,
A.advanceamount,

A.Due_days,
A.Due_BUCKET,
A.Remarks,
A.transfer_date,

A.Cust_Status as [Active/Non-Active],
C.Risk
from X_CHECK A
left join(select * from Dep_CTE
where yearMonth = '202410') B
on A.Cust_ID = B.Cust_ID
left join Branch_Master C ON A.location_code = C.LocationCode;






Select Cust_ID,[202404] as Dep_APR,
[202405] as Dep_MAY,[202406] as Dep_JUN,
[202407] as Dep_JUL,[202408] as Dep_AUG,
[202409] as Dep_SEP 
FROM (
    SELECT yearMonth, Cust_ID,
           CASE WHEN Cust_Status = 'Active' 
                     AND product_defined = 'After_22' 
                     AND Pay_mode IN ('A_online', 'B_Agent', 'C_Nearby', 'D_Cash', 'E_Scan')
           THEN 1 ELSE 0 END AS Dep_Value
    FROM Record
    WHERE yearMonth BETWEEN '202404' AND '202409' 
      AND client = 'ABC' 
      AND Cust_Status = 'Active'
) AS SourceTable
PIVOT(MAX(Dep_VALUE) FOR yearMonth IN ([202404], [202405], [202406], [202407], [202408], [202409])
) AS PivotTable;


DECLARE @columns AS NVARCHAR(MAX)
SET @columns = STRING_AGG(QUOTENAME(yearMonth), ', ') 
SELECT 
    client,
    Cust_ID,
    [202401], [202402], [202403], [202405], [202406],
    [202407], [202408], [202409], [202410], [202411]
FROM 
    (SELECT 
         client,
         Cust_ID,
         yearMonth,
         DAY(Paydate) AS Date_day
     FROM 
         Record
     WHERE 
         Cust_Status = 'Active' 
         AND product_defined = 'After_22'
    ) AS sourcetable
PIVOT
    (MAX(Date_day) FOR yearMonth IN 
        ([202401], [202402], [202403], [202405], [202406], 
         [202407], [202408], [202409], [202410], [202411])
    ) AS pivottable;


------------------------------****************************************--------------------------


