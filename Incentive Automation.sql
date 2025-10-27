
Select * INTO #INC
FROM 
(
SELECT
B.Project Client,
B.State,
A.Branchcode Collate Latin1_General_CI_AI Branchcode,
B.[Branch ] Collate Latin1_General_CI_AI Branch,
A.EMP_ID Collate Latin1_General_CI_AI EMP_ID,
Hr.Name Collate Latin1_General_CI_AI EMP_NAME,
A.Client_ID,
A.Customer_Name,
A.Center_Name,
A.groupname,
A.Buckets,
0 Dis_Ac,
CASE WHEN A.Buckets = 'A_Regular' 
THEN 1 ELSE 0 END Demand_Ac_Reg,
CASE WHEN A.Coll_Status IN ('A_Collected','C_Advanced','E_Closed') 
and A.Buckets = 'A_Regular'
THEN 1 ELSE 0 END Recovery_Ac_Reg,
CASE WHEN A.Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due') 
THEN 1 ELSE 0 END Demand_Ac_B1,
CASE WHEN A.Coll_Status IN ('A_Collected','C_Advanced','E_Closed') 
and A.Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due')
THEN 1 ELSE 0 END Recovery_Ac_B1,

CASE WHEN A.Coll_Status IN ('A_Collected','C_Advanced','E_Closed') AND A.Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due')
and DueDate >= coalesce(Coll_Date,DueDate)
THEN 1 ELSE 0 END Before_Recovery_Acc,

CASE WHEN A.Coll_Status IN ('A_Collected','C_Advanced','E_Closed') AND A.Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due')
and DueDate < coalesce(Coll_Date,DueDate) 
THEN 1 ELSE 0 END After_Recovery_Acc,

CASE WHEN A.Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	THEN 1 ELSE 0 END Coll_Acc_MTD,
CASE WHEN A.Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	and A.Pay_Mode in ('A_Online','B_Agent','C_Nearby','D_Paytm','E_Scan')
	THEN 1 ELSE 0 END DIG_ACC_MTD,

CASE WHEN A.Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	and A.Pay_Mode = 'A_Online' THEN 1 ELSE 0 END Subk_Pay_ACC_MTD,

CASE WHEN A.Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	and A.Pay_Mode in ('B_Agent','C_Nearby','D_Paytm','E_Scan') THEN 1 ELSE 0 END Other_Chanels_ACC_MTD

from AllClient_record (NOLOCK)A
left join  Branch_Master (NOLOCK)B
on A.Branchcode= B.BranchCode

left join Master (NOLOCK) D
on A.Client_ID = D.Client_ID 
left join HR_Status Hr on A.EMP_ID collate Latin1_General_CI_AI=HR.EMPID
where A.Cust_Status = 'Active' and A.Product_defined = 'Post_Covid'
and A.Month_id = '202506' and D.Client_ID is null

Union All

Select 
B.project Client,
B.State,
A.BranchCode Collate Latin1_General_CI_AI BranchCode,
B.[Branch ] Collate Latin1_General_CI_AI Branch,
A.EMP_ID Collate Latin1_General_CI_AI EMP_ID ,
Hr.Name Collate Latin1_General_CI_AI CSR_NAME,
CASE WHEN A.Client_ID IS NULL OR LEN(A.Client_ID)<5 THEN A.Form_no ELSE A.Client_ID END Client_ID,
A.Customer_Name,
A.Center_Name,
' ' groupname,
' ' Buckets,
case when Client_ID is not null then 1 else 0 end Dis_Ac,
0 Demand_Ac_Reg,
0 Recovery_Ac_Reg,
0 Demand_Ac_B1,
0 Recovery_Ac_B1,

0 Before_Recovery_Acc,

0 After_Recovery_Acc,

0 Coll_Acc_MTD,
0 DIG_ACC_MTD,
0 Subk_Pay_ACC_MTD,
0 Other_Chanels_ACC_MTD

from Cust_Record (NOLOCK)A
left join Branch_Details (NOLOCK) B
on A.BranchCode = B.BranchCode
LEFT JOIN HR_Status Hr on A.EMP_ID collate Latin1_General_CI_AI=Hr.EMPID
where Month_id='202506'
)A



Select A.Client,A.State,A.Branchcode,A.Branch,A.EMP_ID,A.CSR_NAME,
SUM(A.Dis_Ac) Disb_Ac,
' ' [Incentive Slab],
' ' [Per Account],
' ' [Growth Index Incentive],
' ' [More A/Cs required for Next Slab Incentive Eligibility],

SUM(A.Demand_Ac_Reg) Demand_Ac_Reg,
SUM(A.Recovery_Ac_Reg) Recovery_Ac_Reg,
' ' [FTM CE % (Reg B0)],

SUM(A.Demand_Ac_B1) Demand_Ac_B1,
SUM(A.Recovery_Ac_B1) Recovery_Ac_B1,
' ' [FTM CE %],
B.[LM CE%],
' ' Diff,
SUM(A.Before_Recovery_Acc) Before_Recovery_Acc,

SUM(A.After_Recovery_Acc) After_Recovery_Acc,

' ' [Quality Index Incentive],
' ' [More A/Cs need to be collect to archieve >=98%],
' ' [Quality Index Incentive],
' ' [More A/Cs need to be collect to archieive previous Month CE%],
SUM(A.Coll_Acc_MTD) Coll_Acc_MTD,
SUM(A.DIG_ACC_MTD) DIG_ACC_MTD,
' ' [DIG %],
SUM(A.Subk_Pay_ACC_MTD) Subk_Pay_ACC_MTD,
SUM(A.Other_Chanels_ACC_MTD) Other_Chanels_ACC_MTD,
B.[LM_DIG%],
' ' [Increase/decrease],
' ' [>=50% Incentive Payable],
' ' [<50% Incentive Payable],
' ' [Total Payable - 100%]

from #INC A
left join
(SELECT Branch,Branchcode,EMP_ID,

count(CASE WHEN Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due') and Coll_Status IN ('A_Collected','C_Advanced','E_Closed') 
THEN 1 ELSE NULL END) LM_RECOVERY_Ac_B1,
count(CASE WHEN Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due')
THEN 1 ELSE NULL END) LM_Demand_Ac_B1,

cast(count(CASE WHEN Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due') and Coll_Status IN ('A_Collected','C_Advanced','E_Closed') 
THEN 1 ELSE NULL END) as float),
cast(nullif(count(CASE WHEN Buckets in ('A_Regular','B_1-29 Due','C_30-59 Due')
THEN 1 ELSE NULL END),0) as float) [LM CE%],

count(CASE WHEN Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	and Pay_Mode in ('A_Online','B_Agent','C_Nearby','D_Paytm','E_Scan')THEN 1 ELSE NULL END) LM_DIG_Ac,

count(CASE WHEN Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
THEN 1 ELSE null END) LM_RECOVERY_Ac,

cast(count(CASE WHEN Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
	and Pay_Mode in ('A_Online','B_Agent','C_Nearby','D_Paytm','E_Scan')THEN 1 ELSE NULL END) as float)/
cast(nullif(count(CASE WHEN Coll_Status IN ('A_Collected','B_Partial_Collected','C_Advanced','E_Closed')
THEN 1 ELSE null END),0) as float) [LM_DIG%]

from AllClient_record
where Month_id = '202505' and Cust_Status = 'Active'
and Product_defined = 'Post_Covid'
group by Branch,Branchcode,EMP_ID) B
on A.EMP_ID = B.EMP_ID collate Latin1_General_CI_AI
and A.Branchcode = B.Branchcode collate Latin1_General_CI_AI

group by A.Client,A.State,A.Branchcode,A.Branch,A.EMP_ID,A.CSR_NAME,B.[LM CE%],B.[LM_DIG%]

