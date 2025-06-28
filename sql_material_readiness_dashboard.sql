-- Enterprise Manufacturing Material Readiness Dashboard (SQL)
-- Replace all YOUR_* placeholders with your actual data source/schema/table/column names.

WITH
ItemDetails AS (
    SELECT
        I.ITEM_ID,
        I.DESCRIPTION,
        I.BUYER,
        I.VENDOR,
        I.STOCKING_TYPE,
        I.ON_HAND_QTY,
        I.BRANCH_PLANT
    FROM YOUR_ITEM_BRANCH_MASTER_TABLE I
    WHERE I.BRANCH_PLANT = 'YOUR_BRANCH_PLANT_CODE'
),
RecursiveBOM AS (
    -- Initial level: all manufactured items in the branch
    SELECT
        B.PARENT_ITEM_ID,
        B.COMPONENT_ITEM_ID,
        B.QTY_PER_PARENT,
        1 AS Level,
        CAST(B.PARENT_ITEM_ID AS VARCHAR(100)) + ' > ' + CAST(B.COMPONENT_ITEM_ID AS VARCHAR(100)) AS Path
    FROM YOUR_BOM_TABLE B
    WHERE TRIM(B.IXTBM) = 'M'
      AND B.BRANCH_PLANT = 'YOUR_BRANCH_PLANT_CODE'
    UNION ALL
    -- Recursively expand components
    SELECT
        B.PARENT_ITEM_ID,
        B.COMPONENT_ITEM_ID,
        B.QTY_PER_PARENT,
        RB.Level + 1,
        RB.Path + ' > ' + CAST(B.COMPONENT_ITEM_ID AS VARCHAR(100))
    FROM YOUR_BOM_TABLE B
    INNER JOIN RecursiveBOM RB
        ON B.PARENT_ITEM_ID = RB.COMPONENT_ITEM_ID
    WHERE RB.Level < 5 -- adjust recursion depth as needed
      AND NOT CHARINDEX('>' + CAST(B.COMPONENT_ITEM_ID AS VARCHAR(100)) + '>', RB.Path) > 0 -- prevents circular BOMs
      AND B.BRANCH_PLANT = 'YOUR_BRANCH_PLANT_CODE'
),
WorkOrders AS (
    SELECT
        WO.ORDER_NUMBER,
        WO.ORDER_TYPE,
        WO.STATUS,
        WO.PARENT_ITEM_ID,
        WO.ORDERED_QTY,
        WO.TRANS_DATE
    FROM YOUR_WORK_ORDER_HEADER_TABLE WO
    WHERE WO.BRANCH_PLANT = 'YOUR_BRANCH_PLANT_CODE'
      AND WO.WASRST IN ('10') -- adjust active status codes as needed
      AND WO.WADCTO IN ('WS','WO') -- adjust order types as needed
),
JoinedData AS (
    SELECT
        WO.ORDER_NUMBER,
        WO.TRANS_DATE,
        RB.COMPONENT_ITEM_ID,
        RB.QTY_PER_PARENT,
        WO.ORDERED_QTY,
        (WO.ORDERED_QTY * RB.QTY_PER_PARENT) AS TOTAL_QTY_REQUIRED
    FROM WorkOrders WO
    INNER JOIN RecursiveBOM RB
        ON WO.PARENT_ITEM_ID = RB.PARENT_ITEM_ID
),
CostData AS (
    SELECT
        C.ITEM_ID,
        C.COST_EURO
    FROM YOUR_COST_TABLE C
),
RunningTotals AS (
    SELECT
        JD.ORDER_NUMBER,
        JD.TRANS_DATE,
        JD.COMPONENT_ITEM_ID,
        JD.TOTAL_QTY_REQUIRED,
        ID.ON_HAND_QTY AS INITIAL_STOCK,
        SUM(JD.TOTAL_QTY_REQUIRED) OVER (
            PARTITION BY JD.COMPONENT_ITEM_ID
            ORDER BY JD.TRANS_DATE, JD.ORDER_NUMBER
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CUMULATIVE_USAGE
    FROM JoinedData JD
    INNER JOIN ItemDetails ID
        ON JD.COMPONENT_ITEM_ID = ID.ITEM_ID
)
SELECT
    ORDER_NUMBER,
    TRANS_DATE,
    COMPONENT_ITEM_ID,
    TOTAL_QTY_REQUIRED,
    INITIAL_STOCK,
    CUMULATIVE_USAGE,
    (INITIAL_STOCK - CUMULATIVE_USAGE) AS REMAINING_STOCK
FROM RunningTotals
ORDER BY COMPONENT_ITEM_ID, TRANS_DATE, ORDER_NUMBER;
