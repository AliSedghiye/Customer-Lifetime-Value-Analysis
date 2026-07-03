import os
import pandas as pd
import psycopg2
from pathlib import Path
from io import StringIO

DB_NAME = os.environ.get("DB_NAME", "Marketing-HW2")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "my_secret")
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")

conn = psycopg2.connect(
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=DB_PORT
)
cur = conn.cursor()

DATA_DIR = Path("/app/data")

csv_to_table = {
    "CUSTOMER.csv": "staging.customer_raw",
    "CATEGORY.csv": "staging.category_raw",
    "CHANNEL.csv": "staging.channel_raw",
    "MARKETING_CHANNEL.csv": "staging.marketing_channel_raw",
    "PRODUCT.csv": "staging.product_raw",
    "STORE.csv": "staging.store_raw",
    "PROMOTION.csv": "staging.promotion_raw",
    "ORDER.csv": "staging.orders_raw",
    "ORDER_ITEM.csv": "staging.order_item_raw",
    "PRICE_CHANGE.csv": "staging.price_change_raw",
    "SESSION.csv": "staging.session_raw",
    "SUPPORT_TICKET.csv": "staging.support_ticket_raw",
    "CAMPAIGN_TOUCH.csv": "staging.campaign_touch_raw",
    "EXTERNAL_FACTOR.csv": "staging.external_factor_raw",
}

for csv_file, table_name in csv_to_table.items():
    csv_path = DATA_DIR / csv_file

    print(f"Loading {csv_file} into {table_name}...")
    df = pd.read_csv(csv_path)

    # Cleaning column names
    df.columns = (df.columns.str.strip().str.lower().str.replace(" ", "_"))
    # Replace NaN with ""
    df = df.fillna("")

    # create in memory (RAM) buffer
    buffer = StringIO()
    df.to_csv(buffer, index=False, header=False)
    buffer.seek(0)

    columns = ", ".join(df.columns)
    copy_sql = f"""
        COPY {table_name} ({columns})
        FROM STDIN
        WITH CSV
    """
    cur.copy_expert(copy_sql, buffer)
    conn.commit()

    print(f"Finished {csv_file}. Rows loaded: {len(df)}")

cur.close()
conn.close()

print("task:CSV files -> staging || done...")