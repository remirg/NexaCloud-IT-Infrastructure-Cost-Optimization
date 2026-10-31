/*
==================================================================================================================
                Author:        Regina McDonald                                                                    
                Created Date:  10-07-2026                                                                       
                Description:   Business Analysis Queries. 
==================================================================================================================
*/
/* Question 1 - Which departments generate the highest infrastructure costs?
   Answered by using Query 4 - Infrastructure Cost by Department */

SELECT *
FROM departments;

SELECT *
FROM infrastructure_costs;

SELECT *
FROM infrastructure_resources;

SELECT
    d.department_name AS Department,
    COUNT(DISTINCT ir.resource_id) AS Number_of_Resources,
    ROUND(
        COALESCE(SUM(ic.compute_cost), 0)
      + COALESCE(SUM(ic.storage_cost), 0)
      + COALESCE(SUM(ic.network_cost), 0)
      + COALESCE(SUM(ic.database_cost), 0)
      + COALESCE(SUM(ic.other_cost), 0)
    , 2) AS Total_Infrastructure_Cost
FROM departments AS d
LEFT JOIN infrastructure_resources AS ir ON d.department_id  = ir.department_id
LEFT JOIN infrastructure_costs AS ic ON ir.resource_id   = ic.resource_id
GROUP BY d.department_id, d.department_name
ORDER BY Total_Infrastructure_Cost DESC;

/*
******************************************************************************
Question 2 - Which cloud providers account for the largest share of spending?
Answered by a provider-level version of Query 4 (same cost formula, grouped by
provider instead of department). Percentage_Share = provider spend / total spend.
******************************************************************************
*/

WITH resource_costs AS (
    SELECT
        resource_id,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0)) AS total_cost
    FROM infrastructure_costs
    WHERE billing_date < '2026-10-01'      -- analysis period only (excludes Part 11 test data)
    GROUP BY resource_id
)
SELECT
    p.provider_name                                                     AS Provider,
    COUNT(DISTINCT ir.resource_id)                                      AS Number_of_Resources,
    ROUND(COALESCE(SUM(rc.total_cost), 0), 2)                           AS Total_Provider_Spending,
    ROUND(COALESCE(SUM(rc.total_cost), 0) * 100.0
          / (SELECT SUM(total_cost) FROM resource_costs), 2)            AS Percentage_Share
FROM cloud_providers AS p
LEFT JOIN infrastructure_resources AS ir ON p.provider_id  = ir.provider_id
LEFT JOIN resource_costs           AS rc ON ir.resource_id = rc.resource_id
GROUP BY p.provider_id, p.provider_name
ORDER BY Total_Provider_Spending DESC;


/* Question 3 - Which infrastructure resource types are the most expensive?
   Threshold: $10,000 over the 4 billing months, answered by using Query 6 - High-Cost Resource Types */

SELECT
    rt.resource_type_name                    AS Resource_Type,
    COUNT(DISTINCT ir.resource_id)           AS Number_of_Resources,
    ROUND(SUM(
        COALESCE(ic.compute_cost, 0)
      + COALESCE(ic.storage_cost, 0)
      + COALESCE(ic.network_cost, 0)
      + COALESCE(ic.database_cost, 0)
      + COALESCE(ic.other_cost, 0)
    ), 2)                                    AS Total_Spending
FROM infrastructure_costs AS ic
JOIN infrastructure_resources AS ir ON ic.resource_id      = ir.resource_id
JOIN resource_types          AS rt ON ir.resource_type_id = rt.resource_type_id
GROUP BY rt.resource_type_id, rt.resource_type_name
HAVING ROUND(SUM(
        COALESCE(ic.compute_cost, 0)
      + COALESCE(ic.storage_cost, 0)
      + COALESCE(ic.network_cost, 0)
      + COALESCE(ic.database_cost, 0)
      + COALESCE(ic.other_cost, 0)
    ), 2) > 10000
ORDER BY Total_Spending DESC;


/* Question 4 - Which individual resources generate the highest costs?
   Answered by using Query 13 - Rank Resources by Infrastructure Cost */

SELECT 
    r.resource_name,
    rt.resource_type_name,
    d.department_name,
    SUM(
        COALESCE(c.compute_cost, 0) + 
        COALESCE(c.storage_cost, 0) + 
        COALESCE(c.network_cost, 0) + 
        COALESCE(c.database_cost, 0) + 
        COALESCE(c.other_cost, 0)
    ) AS total_cost,
    RANK() OVER (
        ORDER BY SUM(
            COALESCE(c.compute_cost, 0) + COALESCE(c.storage_cost, 0) + 
            COALESCE(c.network_cost, 0) + COALESCE(c.database_cost, 0) + 
            COALESCE(c.other_cost, 0)
        ) DESC
    ) AS cost_rank
FROM 
    Infrastructure_Resources r
JOIN 
    Resource_Types rt ON r.resource_type_id = rt.resource_type_id
JOIN 
    Departments d ON r.department_id = d.department_id
JOIN 
    Infrastructure_Costs c ON r.resource_id = c.resource_id
GROUP BY 
    r.resource_id,
    r.resource_name,
    rt.resource_type_name,
    d.department_name
ORDER BY 
    cost_rank ASC;

/*
********************************************************************
Question 5 - Which resources have consistently low utilization?
Answered by using Query 9 - Resource Utilization Analysis
Thresholds (average CPU): Low < 20% | Moderate 20-70% | High > 70%
"Consistently" is tested with peak CPU and the % of readings under 20%:
a resource with a 12% average but a 90% peak is NOT consistently idle.
********************************************************************
*/

WITH usage_stats AS (
    SELECT
        resource_id,
        AVG(cpu_utilization_percentage)                               AS avg_cpu,
        AVG(memory_utilization_percentage)                            AS avg_memory,
        MAX(cpu_utilization_percentage)                               AS peak_cpu,
        SUM(CASE WHEN cpu_utilization_percentage < 20 THEN 1 ELSE 0 END) * 100.0
            / COUNT(cpu_utilization_percentage)                       AS pct_readings_below_20
    FROM resource_usage
    WHERE cpu_utilization_percentage IS NOT NULL
    GROUP BY resource_id
),
resource_costs AS (
    SELECT
        resource_id,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0)) AS total_cost
    FROM infrastructure_costs
    GROUP BY resource_id
)
SELECT
    ir.resource_name                          AS Resource_Name,
    rt.resource_category                      AS Resource_Category,
    d.department_name                         AS Department,
    p.provider_name                           AS Provider,
    ROUND(us.avg_cpu, 2)                      AS Avg_CPU_Utilization,
    ROUND(us.avg_memory, 2)                   AS Avg_Memory_Utilization,
    ROUND(us.peak_cpu, 2)                     AS Peak_CPU,
    ROUND(us.pct_readings_below_20, 1)        AS Pct_Readings_Below_20,
    ROUND(COALESCE(rc.total_cost, 0), 2)      AS Total_Infrastructure_Cost,
    'Low Utilization'                         AS Utilization_Classification
FROM infrastructure_resources AS ir
JOIN resource_types  AS rt ON ir.resource_type_id = rt.resource_type_id
JOIN departments     AS d  ON ir.department_id    = d.department_id
JOIN cloud_providers AS p  ON ir.provider_id      = p.provider_id
JOIN usage_stats     AS us ON ir.resource_id      = us.resource_id
LEFT JOIN resource_costs AS rc ON ir.resource_id  = rc.resource_id
WHERE us.avg_cpu < 20
ORDER BY us.avg_cpu ASC;


/*
********************************************************************
Question 6 - Which resources combine high costs with low utilization?
Answered by using Query 10 - High-Cost, Low-Utilization Resources
********************************************************************
*/

SELECT
    ir.resource_name                 AS Resource_Name,
    rt.resource_type_name            AS Resource_Type,
    d.department_name                AS Department,
    p.provider_name                  AS Provider,
    ROUND(ua.avg_cpu, 2)             AS Average_Utilization,
    ROUND(ct.total_cost, 2)          AS Total_Cost
FROM infrastructure_resources AS ir
INNER JOIN resource_types  AS rt ON ir.resource_type_id = rt.resource_type_id
INNER JOIN cloud_providers AS p  ON ir.provider_id      = p.provider_id
INNER JOIN departments     AS d  ON ir.department_id    = d.department_id
INNER JOIN (
    SELECT
        resource_id,
        AVG(cpu_utilization_percentage) AS avg_cpu
    FROM resource_usage
    GROUP BY resource_id
    HAVING AVG(cpu_utilization_percentage) < 20          -- Low utilization
) AS ua ON ir.resource_id = ua.resource_id
INNER JOIN (
    SELECT
        resource_id,
        SUM(
            COALESCE(compute_cost, 0)
          + COALESCE(storage_cost, 0)
          + COALESCE(network_cost, 0)
          + COALESCE(database_cost, 0)
          + COALESCE(other_cost, 0)
        ) AS total_cost
    FROM infrastructure_costs
    GROUP BY resource_id
    HAVING SUM(
            COALESCE(compute_cost, 0)
          + COALESCE(storage_cost, 0)
          + COALESCE(network_cost, 0)
          + COALESCE(database_cost, 0)
          + COALESCE(other_cost, 0)
        ) > 1000                                           -- High cost
) AS ct ON ir.resource_id = ct.resource_id
ORDER BY ct.total_cost DESC;

/*
******************************************************************************
Question 7 - Which departments are exceeding their infrastructure budgets?
Answered by using Query 14 - Rank Departments by Infrastructure Spending
******************************************************************************
*/

WITH DepartmentTotals AS (
    SELECT
        d.department_id,
        d.department_name AS Department,
        d.monthly_budget  AS Monthly_Budget,
        SUM(  COALESCE(ic.compute_cost, 0)
            + COALESCE(ic.storage_cost, 0)
            + COALESCE(ic.network_cost, 0)
            + COALESCE(ic.database_cost, 0)
            + COALESCE(ic.other_cost, 0)) AS Total_Spending
    FROM departments AS d
    JOIN infrastructure_resources AS ir ON d.department_id = ir.department_id
    JOIN infrastructure_costs     AS ic ON ir.resource_id  = ic.resource_id
    GROUP BY d.department_id, d.department_name, d.monthly_budget
),
Months AS (
    SELECT COUNT(DISTINCT DATE_FORMAT(billing_date, '%Y-%m')) AS months_of_data
    FROM infrastructure_costs
),
Consumption AS (
    SELECT
        t.*,
        m.months_of_data,
        t.Total_Spending / m.months_of_data                          AS Avg_Monthly_Spending,
        t.Total_Spending / m.months_of_data / t.Monthly_Budget * 100 AS Budget_Consumption_Pct
    FROM DepartmentTotals AS t
    CROSS JOIN Months AS m
)
SELECT
    Department,
    Monthly_Budget,
    ROUND(Total_Spending, 2)                       AS Total_Spending,
    months_of_data                                 AS Months_of_Data,
    ROUND(Avg_Monthly_Spending, 2)                 AS Avg_Monthly_Spending,
    ROUND(Budget_Consumption_Pct, 2)               AS Budget_Consumption_Pct,
    CASE
        WHEN Budget_Consumption_Pct > 100 THEN 'Over Budget'
        WHEN Budget_Consumption_Pct >= 90 THEN 'At Risk (90%+)'
        ELSE 'Within Budget'
    END                                            AS Budget_Status,
    RANK() OVER (ORDER BY Total_Spending DESC)     AS Spending_Rank
FROM Consumption
ORDER BY Spending_Rank;

/*
******************************************************************************
Question 8 - How has infrastructure spending changed over time?
Answered by using Query 15 - Running Infrastructure Cost
Spending is grouped by billing MONTH (DATE_FORMAT). LAG() compares each month
with the month before it, which shows whether spending is going up or down.
A running total alone only ever goes up, so it can't show that by itself.
******************************************************************************
*/

WITH MonthlyTotals AS (
    SELECT
        DATE_FORMAT(billing_date, '%Y-%m') AS Billing_Period,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0))     AS Infrastructure_Cost
    FROM infrastructure_costs
    WHERE billing_date < '2026-10-01'      -- analysis period only (excludes Part 11 test data)
    GROUP BY DATE_FORMAT(billing_date, '%Y-%m')
)
SELECT
    Billing_Period,
    ROUND(Infrastructure_Cost, 2)  AS Infrastructure_Cost,
    ROUND(Infrastructure_Cost - LAG(Infrastructure_Cost) OVER (ORDER BY Billing_Period), 2)
    AS Change_vs_Prior_Month,
    ROUND((Infrastructure_Cost - LAG(Infrastructure_Cost) OVER (ORDER BY Billing_Period))
          / LAG(Infrastructure_Cost) OVER (ORDER BY Billing_Period) * 100, 2)   AS Pct_Change_vs_Prior_Month,
    ROUND(SUM(Infrastructure_Cost) OVER (ORDER BY Billing_Period), 2)           AS Running_Infrastructure_Cost
FROM MonthlyTotals
ORDER BY Billing_Period;

/* 


**************************************************************************************
Question 9 - Which cost categories contribute most to total infrastructure spending?
Built on the Query 5 cost formula (Compute + Storage + Network + Database + Other),
broken out by category. UNION ALL turns the five cost columns into rows so they can
be compared side by side; SUM() OVER () gives each category's share of the total.
**************************************************************************************
*/

SELECT
    cost_category AS `Cost Category`,
    ROUND(SUM(cost_amount), 2) AS `Total Spending`,
    ROUND(SUM(cost_amount) * 100.0 / SUM(SUM(cost_amount)) OVER (), 2) AS `Percentage of Total Spend`
FROM (
    SELECT 'Compute'  AS cost_category, COALESCE(compute_cost, 0)  AS cost_amount
    FROM infrastructure_costs WHERE billing_date < '2026-10-01'
    UNION ALL
    SELECT 'Storage',  COALESCE(storage_cost, 0)
    FROM infrastructure_costs WHERE billing_date < '2026-10-01'
    UNION ALL
    SELECT 'Network',  COALESCE(network_cost, 0)
    FROM infrastructure_costs WHERE billing_date < '2026-10-01'
    UNION ALL
    SELECT 'Database', COALESCE(database_cost, 0)
    FROM infrastructure_costs WHERE billing_date < '2026-10-01'
    UNION ALL
    SELECT 'Other',    COALESCE(other_cost, 0)
    FROM infrastructure_costs WHERE billing_date < '2026-10-01'
) AS category_costs
GROUP BY cost_category
ORDER BY `Total Spending` DESC;

/* 
**********************************************************************************************************************
Question 10 - Are the company's most expensive resources also its most heavily utilized?
Answered by combining Query 7 (Complete Infrastructure Cost Report) and Query 13 (Rank Resources by Cost)
Cost_Rank and Utilization_Rank sit side by side. If the most expensive resources were also the busiest,
the two ranks would be close. A big gap (high cost rank, low utilization rank) answers the question.
Resources with no CPU metric (networking / serverless) show NULL instead of being treated as 0%.
**********************************************************************************************************************
*/


WITH resource_costs AS (
    SELECT
        resource_id,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0)) AS total_cost
    FROM infrastructure_costs
    GROUP BY resource_id
),
usage_stats AS (
    SELECT resource_id, AVG(cpu_utilization_percentage) AS avg_cpu
    FROM resource_usage
    GROUP BY resource_id
)
SELECT
    ir.resource_name                                    AS Resource,
    rt.resource_type_name                               AS Resource_Type,
    d.department_name                                   AS Department,
    ROUND(rc.total_cost, 2)                             AS Total_Cost,
    ROUND(us.avg_cpu, 2)                                AS Avg_CPU_Utilization,
    RANK() OVER (ORDER BY rc.total_cost DESC)           AS Cost_Rank,
    CASE WHEN us.avg_cpu IS NULL THEN NULL
         ELSE RANK() OVER (ORDER BY us.avg_cpu IS NULL, us.avg_cpu DESC)
    END                                                 AS Utilization_Rank,
    CASE
        WHEN us.avg_cpu IS NULL THEN 'No CPU metric'
        WHEN us.avg_cpu < 20    THEN 'Low Utilization'
        WHEN us.avg_cpu <= 70   THEN 'Moderate Utilization'
        ELSE 'High Utilization'
    END                                                 AS Utilization_Classification
FROM infrastructure_resources AS ir
JOIN resource_types AS rt ON ir.resource_type_id = rt.resource_type_id
JOIN departments    AS d  ON ir.department_id    = d.department_id
JOIN resource_costs AS rc ON ir.resource_id      = rc.resource_id
LEFT JOIN usage_stats AS us ON ir.resource_id    = us.resource_id
ORDER BY Cost_Rank;

/* 
**********************************************************************************************************************
Question 11 - Which resources appear to be oversized?
Answered by using Query 2 - Filter Idle and Underutilized Resources cross-referenced with the logic from 
Query 10: High-Cost, Low-Utilization Resources
*********************************************************************************************************************
*/

WITH ResourceCosts AS (
    -- Pre-aggregating costs per resource (from Query 10)
    SELECT
        resource_id,
        SUM(
            COALESCE(compute_cost, 0)
          + COALESCE(storage_cost, 0)
          + COALESCE(network_cost, 0)
          + COALESCE(database_cost, 0)
          + COALESCE(other_cost, 0)
        ) AS total_cost
    FROM infrastructure_costs
    GROUP BY resource_id
),
ResourceUtilization AS (
    -- Pre-aggregating CPU utilization per resource (from Query 2 & Query 10)
    SELECT
        resource_id,
        AVG(cpu_utilization_percentage) AS avg_cpu
    FROM resource_usage
    GROUP BY resource_id
)
SELECT
    ir.resource_name AS `Resource Name`,
    rt.resource_type_name AS `Resource Type`,
    ir.resource_status AS `Status`,
    d.department_name AS `Department`,
    p.provider_name AS `Provider`,
    ROUND(ru.avg_cpu, 2) AS `Average CPU Utilization %`,
    ROUND(rc.total_cost, 2) AS `Total Cost`
FROM infrastructure_resources AS ir
INNER JOIN resource_types AS rt ON ir.resource_type_id = rt.resource_type_id
INNER JOIN cloud_providers AS p ON ir.provider_id = p.provider_id
INNER JOIN departments AS d ON ir.department_id = d.department_id
LEFT JOIN ResourceCosts AS rc ON ir.resource_id = rc.resource_id
LEFT JOIN ResourceUtilization AS ru ON ir.resource_id = ru.resource_id
WHERE 
    -- CONDITION A (From Query 2): The resource is completely Idle
    ir.resource_status = 'Idle'
    
    -- CONDITION B (From Query 2 & 10): It is running compute but wasted (< 20% CPU)
    OR (
        ir.resource_status = 'Running' 
        AND rt.resource_category = 'Compute' 
        AND ru.avg_cpu < 20
    )
ORDER BY 
    rc.total_cost DESC;



/* 
**********************************************************************************************************************
Question 12 - Which idle resources are still generating costs?
Answered by using Query 2 - Filter Idle and Underutilized Resources 

**********************************************************************************************************************
*/

SELECT 
    ir.resource_id,
    ir.resource_name,
    rt.resource_type_name AS resource_type,
    ir.resource_status,
    -- Add the cost aggregation to see the financial damage
    SUM(
        COALESCE(ic.compute_cost, 0) + 
        COALESCE(ic.storage_cost, 0) + 
        COALESCE(ic.network_cost, 0) + 
        COALESCE(ic.database_cost, 0) + 
        COALESCE(ic.other_cost, 0)
    ) AS "Total Cost Waste"
FROM infrastructure_resources AS ir
LEFT JOIN resource_types AS rt ON ir.resource_type_id = rt.resource_type_id
-- Join the cost table so you can pull the billing amounts
LEFT JOIN infrastructure_costs AS ic ON ir.resource_id = ic.resource_id
WHERE ir.resource_status = 'Idle'
GROUP BY 
    ir.resource_id,
    ir.resource_name,
    rt.resource_type_name,
    ir.resource_status
HAVING `Total Cost Waste` > 0
ORDER BY 
    `Total Cost Waste` DESC;

/* 
**********************************************************************************************************************
Question 13 - Which resources should management investigate for optimization?
Answered by using Query 10 (High-Cost, Low-Utilization Resources) and Query 8 (Resources With and Without
Optimization Actions)
A resource is flagged when its total cost is over $1,000 AND it is either under 20% average CPU or Idle.
Optimization_Review_Status shows whether anyone has looked at it yet. Unreviewed, expensive resources
are the first ones to investigate. 

**********************************************************************************************************************
*/

WITH resource_costs AS (
    SELECT
        resource_id,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0)) AS total_cost
    FROM infrastructure_costs
    GROUP BY resource_id
),
usage_stats AS (
    SELECT resource_id, AVG(cpu_utilization_percentage) AS avg_cpu
    FROM resource_usage
    GROUP BY resource_id
)
SELECT
    ir.resource_name                          AS Resource,
    rt.resource_type_name                     AS Resource_Type,
    d.department_name                         AS Department,
    ir.resource_status                        AS Status,
    ROUND(rc.total_cost, 2)                   AS Total_Cost,
    ROUND(us.avg_cpu, 2)                      AS Avg_CPU_Utilization,
    CASE WHEN EXISTS (SELECT 1 FROM optimization_actions AS oa
                      WHERE oa.resource_id = ir.resource_id)
         THEN 'Already reviewed' ELSE 'Not yet reviewed'
    END                                       AS Optimization_Review_Status,
    CASE
        WHEN ir.resource_status = 'Idle' THEN 'Idle but billed'
        ELSE 'High cost, low CPU'
    END                                       AS Reason_Flagged
FROM infrastructure_resources AS ir
JOIN resource_types AS rt ON ir.resource_type_id = rt.resource_type_id
JOIN departments    AS d  ON ir.department_id    = d.department_id
JOIN resource_costs AS rc ON ir.resource_id      = rc.resource_id
LEFT JOIN usage_stats AS us ON ir.resource_id    = us.resource_id
WHERE rc.total_cost > 1000
  AND (us.avg_cpu < 20 OR ir.resource_status = 'Idle')
ORDER BY Optimization_Review_Status DESC, Total_Cost DESC;


/* 
**********************************************************************************************************************
Question 14 - How much money has been saved through completed optimization actions?
Answered directly from the optimization_actions table: monthly savings = previous_monthly_cost - new_monthly_cost
   for every action marked Completed.
**********************************************************************************************************************
*/

SELECT 
    COUNT(optimization_id) AS "Total Optimization Actions",
    SUM(COALESCE(previous_monthly_cost, 0)) AS "Original Cost Baseline",
    SUM(COALESCE(new_monthly_cost, 0)) AS "New Optimized Cost",
    -- The core savings calculation
    SUM(COALESCE(previous_monthly_cost, 0) - COALESCE(new_monthly_cost, 0)) AS "Total Monthly Savings"
FROM 
    optimization_actions
WHERE 
    LOWER(action_status) = 'completed'; 


/* 
**********************************************************************************************************************
Question 15 - Where are the largest opportunities to reduce infrastructure spending?
Answered by using Query 12 / Query 4 (department spending baseline) cross-referenced with
Query 10 (High-Cost, Low-Utilization Resources)
Each RESOURCE is classified once: it counts as a savings opportunity if its average CPU is under 20%
or its status is Idle. Its total cost is then counted once toward its department.

**********************************************************************************************************************
*/

WITH resource_costs AS (
    SELECT
        resource_id,
        SUM(  COALESCE(compute_cost, 0)
            + COALESCE(storage_cost, 0)
            + COALESCE(network_cost, 0)
            + COALESCE(database_cost, 0)
            + COALESCE(other_cost, 0)) AS total_cost
    FROM infrastructure_costs
    WHERE billing_date < '2026-10-01'      -- analysis period only (excludes Part 11 test data)
    GROUP BY resource_id
),
usage_stats AS (
    SELECT resource_id, AVG(cpu_utilization_percentage) AS avg_cpu
    FROM resource_usage
    GROUP BY resource_id
),
DepartmentWaste AS (
    SELECT
        d.department_name                                       AS Department,
        SUM(COALESCE(rc.total_cost, 0))                         AS total_department_cost,
        SUM(CASE WHEN us.avg_cpu < 20 OR ir.resource_status = 'Idle'
                 THEN COALESCE(rc.total_cost, 0) ELSE 0 END)    AS total_wasted_cost,
        SUM(CASE WHEN us.avg_cpu < 20 OR ir.resource_status = 'Idle'
                 THEN 1 ELSE 0 END)                             AS flagged_resources
    FROM departments AS d
    JOIN infrastructure_resources AS ir ON d.department_id = ir.department_id
    LEFT JOIN resource_costs      AS rc ON ir.resource_id  = rc.resource_id
    LEFT JOIN usage_stats         AS us ON ir.resource_id  = us.resource_id
    GROUP BY d.department_id, d.department_name
)
SELECT
    Department,
    flagged_resources                                                   AS `Flagged Resources`,
    ROUND(total_department_cost, 2)                                     AS `Total Department Spending`,
    ROUND(total_wasted_cost, 2)                                         AS `Spend on Low-Use or Idle Resources`,
    ROUND(total_wasted_cost * 100.0 / NULLIF(total_department_cost, 0), 2)
                                                                        AS `Pct of Department Spending`
FROM DepartmentWaste
ORDER BY `Spend on Low-Use or Idle Resources` DESC;


