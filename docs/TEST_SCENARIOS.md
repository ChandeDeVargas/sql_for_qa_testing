# Documentación de escenarios

# Test Scenarios - SQL QA Validation

## Overview

This document describes the QA test scenarios covered by this project.

## 1. Basic Validation

- ✅ List all users with validation flags
- ✅ Filter orders by date range
- ✅ Rank and sort results

## 2. Data Quality

- ✅ Detect negative/zero totals
- ✅ Find invalid dates (future, null, old)
- ✅ Identify zero/negative prices
- ✅ Locate null or empty required fields

## 3. Duplicate Detection

- ✅ Find duplicate emails
- ✅ Detect duplicate product names
- ✅ Identify duplicate orders

## 4. Data Integrity

- ✅ Find orphaned orders (missing user)
- ✅ Detect broken product references
- ✅ Validate all relationships

## Test Results

- **Total Queries:** 13
- **Bugs Detected:** 12 distinct issues
- **Data Integrity:** 86.67%
