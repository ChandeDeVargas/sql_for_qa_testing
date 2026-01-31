# SQL for QA Testing

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-CC2927?style=for-the-badge&logo=microsoft-sql-server&logoColor=white)

A comprehensive SQL query collection focused on **data quality validation** and **bug detection** in databases. This project demonstrates real-world QA skills: finding data anomalies, validating integrity, and detecting broken relationships.

---

## 🎯 Project Purpose

This repository showcases SQL skills from a **QA Engineer perspective**:

- ✅ Detecting invalid data (negative values, nulls, zeros)
- ✅ Finding duplicates and inconsistencies
- ✅ Validating data integrity and relationships
- ✅ Identifying orphaned records and broken references

**This is NOT about writing complex queries to show off.**  
**This IS about writing clear, focused queries that find real bugs.**

---

## 🗄️ Database Schema

Simple e-commerce database with intentional bugs for QA practice:

### **Tables:**

- **`users`** - Customer accounts
- **`products`** - Product catalog
- **`orders`** - Purchase orders

### **Relationships:**

```
orders.user_id    → users.id
orders.product_id → products.id
```

---

## 🐛 Intentional Bugs in Dataset

The seed data contains **real-world bugs** that QA engineers encounter:

### **Data Quality Issues:**

- Negative totals and prices
- Zero prices and quantities
- Invalid/future dates
- Empty/null required fields

### **Duplicates:**

- Duplicate emails in users
- Potential duplicate orders

### **Data Integrity:**

- Orphaned orders (user doesn't exist)
- Broken references (product doesn't exist)
- Totals that don't match calculations

---

## 📂 Project Structure

```
sql-for-qa-testing/
├── schema/
│   └── schema.sql              # Database structure (simple & clear)
├── data/
│   └── seed_data.sql           # Test data with intentional bugs
├── queries/
│   ├── 01_basic_queries.sql    # Simple filters and aggregations
│   ├── 02_joins.sql            # Find missing relationships
│   └── 03_edge_cases.sql       # Real-world scenarios
├── results/
│   └── bug_findings.md         # Document what you found
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- MySQL 8.0+
- MySQL Workbench (or any SQL client)

### Setup

1. **Create database:**

```sql
   CREATE DATABASE ecommerce_qa_testing;
   USE ecommerce_qa_testing;
```

2. **Run schema:**

```bash
   mysql -u root -p ecommerce_qa_testing < schema/schema.sql
```

3. **Load test data:**

```bash
   mysql -u root -p ecommerce_qa_testing < data/seed_data.sql
```

4. **Start finding bugs:**

```sql
   source queries/01_basic_queries.sql
```

---

## 🧪 Running Queries

Each query file is standalone and can be executed independently:

```sql
-- Example: Find negative prices
source queries/02_data_quality/find_negative_totals.sql
```

Or open in MySQL Workbench and execute.

---

## 📊 What You'll Learn

### **As a QA Engineer:**

- How to validate data quality systematically
- Writing queries that detect real bugs
- Understanding data relationships and integrity
- Identifying edge cases in datasets

### **Technical Skills:**

- SQL SELECT with filters and joins
- Aggregate functions for validation
- Subqueries for data verification
- NULL handling and data anomalies

---

## 🎓 Query Philosophy

**Good QA SQL queries are:**

- ✅ **Clear** - Easy to understand what's being checked
- ✅ **Focused** - One validation per query
- ✅ **Documented** - Comments explain the bug being detected
- ✅ **Actionable** - Results can be directly reported

**Avoid:**

- ❌ Overly complex queries that are hard to maintain
- ❌ Multiple validations in one query
- ❌ Queries without clear purpose

---

## 📊 Project Status

| Category         | Status      | Queries |
| ---------------- | ----------- | ------- |
| Basic Validation | ✅ Complete | 3/3     |
| Data Quality     | ✅ Complete | 4/4     |
| Duplicates       | ✅ Complete | 3/3     |
| Data Integrity   | ✅ Complete | 3/3     |

**Total: 13 professional QA queries**

### 🐛 Bugs Found

This project successfully detected:

- 3 orders with invalid totals (negative/zero)
- 2 records with future dates
- 3 products with zero/negative prices
- 1 user with empty name
- 2 duplicate emails (4 users affected)
- 1 orphaned order (user doesn't exist)
- 1 broken reference (product doesn't exist)

## 🎓 Learning Outcomes

### QA Thinking:

- ✅ How to approach data validation systematically
- ✅ What questions to ask about data integrity
- ✅ How to prioritize which checks matter most
- ✅ Writing queries that find **real** bugs

### SQL Skills:

- ✅ Basic SELECT with meaningful WHERE clauses
- ✅ JOINs to detect missing relationships
- ✅ Aggregations (COUNT, SUM) for validation
- ✅ NULL handling (IS NULL, COALESCE)

### Not Covered (Intentionally):

- ❌ Window functions (ROW_NUMBER, RANK)
- ❌ Complex subqueries
- ❌ CTEs (WITH clauses)
- ❌ Stored procedures

**Why?** These are developer tools. QA needs **clarity over complexity**.

**Data Integrity: 86.67%** (13 out of 15 orders are valid)

## 🤝 Contributing

This is a personal learning project, but suggestions are welcome!

---

## 👤 Author

- GitHub: https://github.com/ChandeDeVargas
- LinkedIn: https://www.linkedin.com/in/chande-de-vargas-b8a51838a/

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**⭐ If this project helps you learn SQL for QA, give it a star!**
