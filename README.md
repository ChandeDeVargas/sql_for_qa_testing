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

## 📂 Query Organization

Queries are organized by validation type:

```
queries/
├── 01_basic_validation/      # List, filter, order data
├── 02_data_quality/          # Find invalid data
├── 03_duplicates/            # Detect duplicates
└── 04_data_integrity/        # Validate relationships
```

---

## 🚀 Getting Started

### **Prerequisites**

- MySQL 8.0+
- MySQL Workbench (or any SQL client)

### **Setup**

1. **Clone the repository:**

```bash
   git clone https://github.com/your-username/sql-for-qa-testing.git
   cd sql-for-qa-testing
```

2. **Create database:**

```sql
   CREATE DATABASE sql_qa_testing;
   USE sql_qa_testing;
```

3. **Run schema:**

```bash
   mysql -u root -p sql_qa_testing < database/schema.sql
```

4. **Load seed data:**

```bash
   mysql -u root -p sql_qa_testing < database/seed_data.sql
```

5. **Verify setup:**

```sql
   SELECT COUNT(*) FROM users;    -- Should return 10
   SELECT COUNT(*) FROM products; -- Should return 10
   SELECT COUNT(*) FROM orders;   -- Should return 15
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

## 📈 Project Status

| Category         | Status         | Queries |
| ---------------- | -------------- | ------- |
| Basic Validation | 🚧 In Progress | 0/3     |
| Data Quality     | ⏳ Pending     | 0/4     |
| Duplicates       | ⏳ Pending     | 0/3     |
| Data Integrity   | ⏳ Pending     | 0/3     |

---

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

```

---

## 📝 Paso 5: Crear `.gitignore`
```

# MySQL

_.sql~
_.swp

# IDE

.idea/
.vscode/
\*.iml

# OS

.DS_Store
Thumbs.db

# Results (optional - keep if you want to save query results)

# results/\*.txt

# results/\*.csv
