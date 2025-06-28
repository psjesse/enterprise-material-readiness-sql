# Enterprise Manufacturing Material Readiness Dashboard (SQL)

## Project Overview

This project provides a comprehensive, enterprise-wide SQL solution for analyzing the availability of components required for active manufacturing work orders within a specified branch plant. By recursively traversing Bill of Materials (BOM) structures and integrating with real-time inventory and work order data, it calculates the cumulative demand for all relevant components and projects their remaining stock levels.

**Key Features:**
- Explodes multi-level BOMs recursively to any depth.
- Integrates work order demand and live inventory balances.
- Projects remaining stock for each component over time.
- Generic SQL: Easily adaptable to any ERP/database schema.
- Highlights potential shortages before they impact production.

## How It Works

The SQL script is modular, using Common Table Expressions (CTEs) for clarity:

1. **ItemDetails CTE:** Retrieves item and inventory info for a specified branch plant.
2. **RecursiveBOM CTE:** Recursively explodes BOMs, capturing hierarchy and component needs.
3. **WorkOrders CTE:** Fetches all active/pending work orders for manufactured items.
4. **JoinedData CTE:** Combines BOM and work order data to calculate total required quantities.
5. **CostData CTE (Optional):** Illustrates how to bring in cost data for components.
6. **RunningTotals CTE:** Calculates cumulative usage and projects remaining stock.
7. **Final SELECT:** Outputs an ordered, readable dashboard of demand and availability.

## Why This Project?
While recursive BOM SQL and ERP queries exist, this project distinguishes itself by:
- Being fully generic and adaptable.
- Including cumulative demand, live stock, and projected availability in one query.
- Offering transparent logic for auditability and learning.

## Customization

- **Schema/Table Placeholders:** Replace `YOUR_DATA_SOURCE_NAME`, `YOUR_SCHEMA_NAME`, etc. with your actual database details.
- **Branch Plant:** Set `YOUR_BRANCH_PLANT_CODE` for your plant.
- **Work Order Status/Types:** Adjust status/type filters as needed.
- **BOM Depth:** Change the recursion depth to suit your product structures.

## Sample Output

See [examples/sample_output.csv](examples/sample_output.csv) for a sample result.

## Similar Projects

While many ERP/SQL scripts exist for BOM and inventory, few offer a fully generic, enterprise-wide, and auditable approach as this script does. It is intended as a foundation for more advanced MRP and manufacturing analytics solutions.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Contributions

Contributions, suggestions, and improvements are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for more info.
