# Customer Lifetime Value (CLV) Analysis

A comprehensive data warehouse and ETL pipeline for analyzing customer lifetime value and marketing performance. This project integrates customer, order, session, support, and external factor data into a structured PostgreSQL database for deep CLV analysis.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Data Pipeline](#data-pipeline)
- [Database Schema](#database-schema)
- [Scripts & Automation](#scripts--automation)
- [Data Quality](#data-quality)
- [License](#license)

---

## 📊 Overview

This project provides an end-to-end solution for:

- **Data Collection**: Ingests 14 CSV files containing customer, transactional, and operational data
- **Data Transformation**: Converts raw staging data into a normalized, validated core schema
- **Data Validation**: Runs automated quality checks to ensure data integrity
- **CLV Analysis**: Provides a structured foundation for customer lifetime value analysis, marketing attribution, and business intelligence

### Key Features

✅ **Automated ETL Pipeline** - CSV to database ingestion with data cleaning  
✅ **Multi-Schema Architecture** - Staging → Core transformation with validation  
✅ **Data Quality Checks** - Automated row count verification  
✅ **Dockerized Environment** - Complete reproducible setup  
✅ **Relational Design** - Foreign key constraints and referential integrity  
✅ **Python + PostgreSQL** - Robust data processing  

---

## 🏗️ Architecture

```
Raw CSV Files → Staging Schema → Core Schema → Analytics Schema
                    ↓               ↓              (Future)
              Initial Load      Transformation
                                & Validation
```

### Data Flow

1. **CSV Ingestion**: 14 CSV files loaded into staging tables
2. **Cleaning**: Column names standardized (lowercase, spaces → underscores)
3. **Type Conversion**: Text fields converted to appropriate types (dates, integers, decimals)
4. **Validation**: Data validated against foreign key constraints and business rules
5. **Core Storage**: Cleaned data written to core schema tables
6. **Quality Assurance**: Row counts compared between staging and core

---

## 🛠️ Technology Stack

| Component | Technology | Version |
|-----------|-----------|---------|
| **Database** | PostgreSQL | 16 |
| **Python** | Python | 3.11 |
| **Container Runtime** | Docker & Docker Compose | Latest |
| **Data Processing** | Pandas | Latest |
| **Database Driver** | psycopg2 | Latest |
| **CLI Tools** | psql | PostgreSQL 16 |

---

## 📁 Project Structure

```
.
├── docker-compose.yml                 # Docker orchestration configuration
├── README.md                          # This file
├── LICENSE                            # MIT License
├── data/                              # CSV source files
│   ├── CAMPAIGN_TOUCH.csv            # Customer marketing touch points
│   ├── CATEGORY.csv                  # Product categories
│   ├── CHANNEL.csv                   # Sales/order channels
│   ├── CUSTOMER.csv                  # Customer master data
│   ├── EXTERNAL_FACTOR.csv           # External factors (weather, holidays, etc.)
│   ├── MARKETING_CHANNEL.csv         # Marketing channels with cost tiers
│   ├── ORDER.csv                     # Order transactions
│   ├── ORDER_ITEM.csv                # Line items within orders
│   ├── PRICE_CHANGE.csv              # Product price history by week
│   ├── PRODUCT.csv                   # Product master data
│   ├── PROMOTION.csv                 # Promotional campaigns
│   ├── SESSION.csv                   # Customer web sessions
│   ├── STORE.csv                     # Physical store locations
│   ├── SUPPORT_TICKET.csv            # Customer support interactions
│   └── ER Diagram.md                 # Entity relationship diagrams
├── scripts/
│   ├── load_csv_to_staging.py        # Python ETL script for CSV ingestion
│   ├── create_analytics_views.py      # (Future) Analytics view creation
│   └── Dockerfile                     # Docker image for loader service
└── sql/
    ├── create_staging_tables.sql      # Staging schema table definitions
    ├── create_core_tables.sql         # Core schema with constraints
    ├── transform_staging_to_core.sql  # Data transformation & migration
    └── quality_checks.sql             # Validation queries
```

---

## 🚀 Getting Started

### Prerequisites

- Docker and Docker Compose installed
- Git (to clone the repository)
- ~2GB disk space for database

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Customer-Lifetime-Value-Analysis
   ```

2. **Start the services**
   ```bash
   docker-compose up
   ```

   This will:
   - Create the PostgreSQL database container
   - Initialize staging and core schemas
   - Load CSV data into staging tables
   - Transform staging data into core schema
   - Run data quality checks

3. **Connect to the database**
   ```bash
   psql -h localhost -p 5433 -U postgres -d "Marketing-HW2"
   ```
   
   Password: `my_secret`

4. **Query the data**
   ```sql
   SELECT COUNT(*) FROM core.customer;
   SELECT * FROM core.orders LIMIT 10;
   ```

### Stopping the Services

```bash
docker-compose down
```

To also remove the database volume:
```bash
docker-compose down -v
```

---

## 🔄 Data Pipeline

### Step 1: Staging Tables Creation
**File**: `sql/create_staging_tables.sql`

Creates raw table structures mirroring CSV files. All columns are TEXT type initially.

```sql
CREATE SCHEMA IF NOT EXISTS staging;
CREATE TABLE staging.customer_raw (
    customer_id TEXT,
    signup_date TEXT,
    city TEXT,
    state TEXT,
    segment TEXT,
    status TEXT
);
-- ... more tables
```

### Step 2: CSV Data Loading
**File**: `scripts/load_csv_to_staging.py`

Python script that:
- Connects to PostgreSQL database
- Reads each CSV file using Pandas
- Cleans column names (lowercase, spaces → underscores)
- Fills NaN values with empty strings
- Uses PostgreSQL COPY command for efficient bulk loading
- Prints progress and row counts

```python
# Column cleaning example
# "Customer ID" → "customer_id"
df.columns = (df.columns.str.strip()
              .str.lower()
              .str.replace(" ", "_"))
```

### Step 3: Core Schema Transformation
**File**: `sql/transform_staging_to_core.sql`

Transforms staging data to core schema with:
- Data type conversions (dates, integers, decimals)
- String trimming and NULL handling
- Validation against foreign key constraints
- DISTINCT selection to remove duplicates
- ON CONFLICT DO NOTHING for idempotency

Example transformation:
```sql
INSERT INTO core.customer (...)
SELECT DISTINCT
    TRIM(customer_id),
    TO_DATE(NULLIF(TRIM(signup_date), ''), 'DD-MM-YYYY'),
    TRIM(city),
    TRIM(state),
    TRIM(segment),
    TRIM(status)
FROM staging.customer_raw
WHERE customer_id IS NOT NULL AND TRIM(customer_id) <> ''
ON CONFLICT (customer_id) DO NOTHING;
```

### Step 4: Quality Checks
**File**: `sql/quality_checks.sql`

Verifies data integrity by:
- Comparing row counts between staging and core
- Identifying any data loss during transformation
- Reporting results for manual review

---

## 🗄️ Database Schema

### Schemas

- **`staging`**: Raw data from CSV imports (all TEXT columns)
- **`core`**: Transformed, validated data with proper types and constraints
- **`analytics`**: Reserved for future analytics views and aggregations

### Core Tables & Relationships

```
CUSTOMER (Master Entity)
  ├─→ ORDER (transactions)
  │     ├─→ ORDER_ITEM (line items)
  │     │     ├─→ PRODUCT
  │     │     │     ├─→ CATEGORY
  │     │     │     └─→ PRICE_CHANGE
  │     │     └─→ PROMOTION
  │     ├─→ STORE
  │     └─→ CHANNEL
  ├─→ SESSION (web sessions)
  ├─→ SUPPORT_TICKET (customer support)
  ├─→ CAMPAIGN_TOUCH (marketing interactions)
  └─→ MARKETING_CHANNEL

EXTERNAL_FACTOR (Context)
  └─→ STORE
```

### Key Tables

| Table | Purpose | Primary Key |
|-------|---------|------------|
| **customer** | Customer master data | customer_id |
| **order** | Order transactions | order_id |
| **order_item** | Line items within orders | order_item_id |
| **product** | Product catalog | product_id |
| **category** | Product categories | category_id |
| **store** | Physical store locations | store_id |
| **channel** | Order/sales channels | channel_id |
| **promotion** | Promotional campaigns | promo_id |
| **price_change** | Product price history | (product_id, year, week) |
| **session** | Customer web sessions | session_id |
| **support_ticket** | Support interactions | ticket_id |
| **campaign_touch** | Marketing touchpoints | touch_id |
| **external_factor** | Environmental factors | factor_id |
| **marketing_channel** | Marketing channels with cost info | channel_id |

### Data Types & Constraints

- **Text Fields**: customer_id, product_id, order_id, etc. (STRING)
- **Dates**: signup_date, order_date (DATE)
- **Timestamps**: session_start (TIMESTAMP)
- **Numeric**: unit_price, discount_value (NUMERIC(10,2))
- **Integers**: quantity, year, week (INT)
- **Foreign Keys**: Referential integrity enforced
- **Primary Keys**: Uniqueness enforced with unique constraints

---

## 📜 Scripts & Automation

### load_csv_to_staging.py

**Purpose**: Ingests CSV files into staging tables

**Key Functions**:
- Establishes PostgreSQL connection using environment variables
- Iterates through CSV files in `data/` directory
- Performs data cleaning (column name normalization, NULL handling)
- Uses efficient COPY command for bulk loading
- Prints progress and success metrics

**Environment Variables**:
```
DB_NAME=Marketing-HW2
DB_USER=postgres
DB_PASSWORD=my_secret
DB_HOST=postgres
DB_PORT=5432
```

**Usage** (via Docker):
```bash
docker-compose up
```

**Usage** (standalone):
```bash
python scripts/load_csv_to_staging.py
```

### Docker Automation

The `docker-compose.yml` orchestrates the complete pipeline:

1. **postgres service**: Initializes database with schemas
2. **loader service**: Depends on postgres health check, then:
   - Runs `load_csv_to_staging.py` (CSV → staging)
   - Runs `transform_staging_to_core.sql` (staging → core)
   - Runs `quality_checks.sql` (validation)

---

## 🔍 Data Quality

### Quality Checks

The `quality_checks.sql` script performs:

- **Row Count Validation**: Compares staging vs. core row counts for each table
- **Referential Integrity**: Foreign key constraints prevent orphaned records
- **Type Safety**: Data type conversions validate format and range
- **NULL Handling**: Explicit NULL handling with NULLIF function
- **Duplicate Detection**: DISTINCT clause removes duplicate records

### Expected Results

```sql
SELECT 'customer' AS table_name,
       (SELECT COUNT(*) FROM staging.customer_raw) AS staging_rows,
       (SELECT COUNT(*) FROM core.customer) AS core_rows;
```

### Common Issues & Resolution

| Issue | Cause | Resolution |
|-------|-------|-----------|
| Row count mismatch | Foreign key validation failures | Check referential integrity in staging data |
| Date conversion errors | Invalid date format | Verify format (DD-MM-YYYY) in source data |
| NULL values | Empty strings in CSV | Handled automatically via NULLIF |
| Duplicate records | Duplicates in source | DISTINCT clause removes duplicates |

---

## 🔌 Docker Configuration

### docker-compose.yml Overview

```yaml
services:
  postgres:
    image: postgres:16
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: my_secret
      POSTGRES_DB: "Marketing-HW2"
    ports:
      - "5433:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./sql/create_staging_tables.sql:/docker-entrypoint-initdb.d/01_*.sql
      - ./sql/create_core_tables.sql:/docker-entrypoint-initdb.d/02_*.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      retries: 10

  loader:
    build:
      context: .
      dockerfile: scripts/Dockerfile
    environment:
      DB_NAME: "Marketing-HW2"
      DB_USER: postgres
      DB_PASSWORD: my_secret
      DB_HOST: postgres
      DB_PORT: 5432
    volumes:
      - ./data:/app/data
      - ./scripts:/app/scripts
      - ./sql:/app/sql
    depends_on:
      postgres:
        condition: service_healthy
```

### Dockerfile (scripts/Dockerfile)

```dockerfile
FROM python:3.11

WORKDIR /app

RUN pip install pandas psycopg2-binary
RUN apt-get update && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

COPY scripts/ /app/scripts/
COPY data/ /app/data/

CMD ["python", "/app/scripts/load_csv_to_staging.py"]
```

---

## 📊 Sample Queries

### Top Customers by Order Value
```sql
SELECT 
    c.customer_id,
    c.segment,
    COUNT(o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_items
FROM core.customer c
JOIN core.orders o ON c.customer_id = o.customer_id
JOIN core.order_item oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.segment
ORDER BY total_orders DESC
LIMIT 10;
```

### Product Performance
```sql
SELECT 
    p.product_id,
    p.sku_name,
    cat.category_name,
    COUNT(oi.order_item_id) AS units_sold,
    SUM(oi.quantity) AS total_quantity
FROM core.product p
JOIN core.category cat ON p.category_id = cat.category_id
LEFT JOIN core.order_item oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.sku_name, cat.category_name
ORDER BY units_sold DESC;
```

### Customer Support Analysis
```sql
SELECT 
    c.customer_id,
    c.segment,
    COUNT(st.ticket_id) AS support_tickets,
    AVG(st.csat_score) AS avg_satisfaction,
    AVG(st.resolution_time_hr) AS avg_resolution_hrs
FROM core.customer c
LEFT JOIN core.support_ticket st ON c.customer_id = st.customer_id
GROUP BY c.customer_id, c.segment
HAVING COUNT(st.ticket_id) > 0
ORDER BY support_tickets DESC;
```

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

**Copyright © 2026 Ali Sedghiye**

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

---

## 📞 Support & Questions

For issues or questions about the data pipeline, please check:
1. The ER Diagram in `data/ER Diagram.md`
2. SQL files in `sql/` directory for transformation logic
3. Python scripts in `scripts/` directory for ETL logic

---

**Last Updated**: 2026-07-03
