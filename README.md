# Customer Lifetime Value Analysis

This project builds a small data warehouse for customer lifetime value analysis. It loads CSV files into PostgreSQL, transforms the data into a structured schema, and then uses a notebook for analysis.

## How to run the whole project

1. Start Docker on your machine.
2. From the project root, run:

   ```bash
   docker compose up --build
   ```

   This starts the PostgreSQL database and runs the ETL pipeline to load the source data into the staging and core tables.

3. Open the notebook at [notebooks/clv_analysis.ipynb](notebooks/clv_analysis.ipynb) and run the cells.

   The notebook connects to PostgreSQL and reads the prepared data for CLV analysis.

## What the project includes

- CSV data files in [data](data)
- ETL scripts in [scripts](scripts)
- SQL schema and transformation files in [sql](sql)
- A Jupyter notebook for analysis in [notebooks/clv_analysis.ipynb](notebooks/clv_analysis.ipynb)

## Database connection

The notebook uses the following PostgreSQL connection details:

- Host: localhost
- Port: 5433
- Database: Marketing-HW2
- User: postgres
- Password: my_secret

## Stop the project

To stop the containers:

```bash
docker compose down
```

To remove the database volume as well:

```bash
docker compose down -v
```
