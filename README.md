# NexaCloud-IT-Infrastructure-Cost-Optimization
SQL based cloud infrastructure cost optimization project analyzing spending trends, resource utilization, cost saving opportunities.
# NexaCloud Technologies Ltd. — IT Infrastructure Cost Optimization Using SQL

**A SQL Data Analytics Project | Cloud Cost Optimization | Resource Utilization Analysis**

## 📌 Project Overview

NexaCloud Technologies Ltd. is a growing technology company that relies on cloud infrastructure to support its applications, databases, internal systems, analytics platforms, and customer-facing services.

As the company expanded, different departments continuously provisioned cloud resources across multiple providers without centralized cost monitoring. This resulted in rising infrastructure expenditure and concerns about inefficient resource utilization.

This project uses **SQL and MySQL** to develop and analyze a centralized cloud infrastructure database, identify major cost drivers, evaluate departmental budget performance, detect underutilized resources, and recommend data-driven cost optimization strategies.

The analysis covers **four billing months**, six departments, and three cloud providers: Amazon Web Services (AWS), Microsoft Azure, and Google Cloud Platform (GCP).

The primary goal is to demonstrate how SQL can transform infrastructure and billing data into actionable insights that support operational efficiency and financial decision-making.

---

## 🎯 Business Problem

NexaCloud Technologies Ltd. faces increasing IT infrastructure costs due to company expansion and decentralized cloud resource management.

Different departments deploy computing, networking, storage, and database resources without sufficient centralized monitoring.

This creates several business challenges:

- Rising infrastructure expenditure.
- Limited visibility into departmental cloud spending.
- Poorly optimized computing and database capacity.
- Potentially unused or abandoned cloud resources generating costs.
- Difficulty identifying the most expensive infrastructure services.
- Lack of proactive budget monitoring and cost governance.

**Key Business Question:**

How can NexaCloud Technologies Ltd. use SQL-based analysis to identify infrastructure cost drivers, detect inefficient resource utilization, and reduce unnecessary cloud expenditure?

---

## 🎯 Project Objectives

The objectives of this project are to:

1. Design a centralized relational database for cloud infrastructure monitoring.
2. Analyze overall infrastructure expenditure.
3. Identify departments responsible for the highest spending.
4. Compare infrastructure costs across cloud providers.
5. Evaluate departmental spending against approved monthly budgets.
6. Identify infrastructure resource categories driving expenditure.
7. Detect high-cost resources with low utilization.
8. Recommend practical cost reduction strategies.
9. Establish a foundation for continuous infrastructure cost monitoring.

---

## 🛠️ Tools and Technologies

| Tool | Purpose |
|---|---|
| MySQL | Database management and SQL analysis |
| MySQL Workbench | Database development, query execution, and result inspection |
| SQL | Data querying, aggregation, filtering, and relational analysis |
| GitHub | Project documentation and version control |

### SQL Skills Demonstrated

- Relational database design
- Primary and foreign key relationships
- SQL joins
- Aggregate functions
- GROUP BY and ORDER BY
- Data filtering
- Cost and resource utilization analysis
- Budget performance analysis
- Translating SQL results into business insights

---

## 🗄️ Database Design

A centralized database named `nexacloud_infrastructure` was developed to organize infrastructure ownership, resource characteristics, utilization, billing, and cost optimization information.

The database consists of seven interconnected tables.

### Database Tables

| Table Name | Description |
|---|---|
| `departments` | Contains department information, managers, cost centers, and monthly budgets |
| `cloud_providers` | Stores cloud provider information, contracts, and billing details |
| `resource_types` | Classifies infrastructure resources by type,
