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

   When you start the stack with `docker compose up -d`, wait for the loader container to finish its work. It will print a message when the data warehouse is ready, and then you can open the notebook.

   If you want to see the readiness message, run `docker compose logs -f loader`.

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

## Analysis formulas and report

The notebook performs a customer lifetime value workflow using the following core formulas:

- RFM scoring:
  - $RFM Score = R \times 100 + F \times 10 + M$
- Customer lifetime value:
  - $APV = \frac{Total\ Revenue}{Number\ of\ Transactions}$
  - $PF = \frac{Number\ of\ Transactions}{Number\ of\ Customers}$
  - $Churn\ Rate = \frac{Churned\ Customers}{Total\ Customers}$
  - $CLV = \frac{APV \times PF}{Churn\ Rate}$
- Predictive CLV model:
  - A Random Forest regressor is trained using RFM features to estimate customer CLV.
  - Model quality is evaluated with RMSE, MAE, and $R^2$.
- Customer segmentation:
  - Customers are grouped into segments such as Bronze, Silver, Gold, and Platinum based on their calculated CLV values.

The analysis report generated in the notebook includes:

- RFM score distribution and feature spread
- Overall CLV summary metrics
- Customer segmentation summary by CLV tier
- Predicted vs actual CLV scatter plot for model evaluation

This report helps identify high-value customers, understand churn risk, and support retention and marketing decisions.
