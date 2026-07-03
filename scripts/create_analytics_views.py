import os
import psycopg2


def get_connection():
    """
    Create database connection using environment variables.
    These values come from docker-compose.yml when running inside Docker.
    """
    return psycopg2.connect(
        dbname=os.getenv("DB_NAME", "Marketing-HW2"),
        user=os.getenv("DB_USER", "postgres"),
        password=os.getenv("DB_PASSWORD", "my_secret"),
        host=os.getenv("DB_HOST", "localhost"),
        port=os.getenv("DB_PORT", "5433")
    )


def create_analytics_schema(cur):
    cur.execute("""
        CREATE SCHEMA IF NOT EXISTS analytics;
    """)


def create_order_revenue_view(cur):
    cur.execute("""
        CREATE OR REPLACE VIEW analytics.order_revenue AS
        SELECT
            o.order_id,
            o.customer_id,
            o.order_date,
            o.store_id,
            o.channel_id,
            o.payment_type,
            o.year,
            o.week,
            oi.order_item_id,
            oi.product_id,
            p.category_id,
            c.category_name,
            oi.quantity,
            pc.unit_price,
            COALESCE(oi.item_discount, 0) AS item_discount,
            ((oi.quantity * pc.unit_price) - COALESCE(oi.item_discount, 0)) AS item_revenue
        FROM core.orders o
        JOIN core.order_item oi
            ON o.order_id = oi.order_id
        JOIN core.product p
            ON oi.product_id = p.product_id
        JOIN core.category c
            ON p.category_id = c.category_id
        LEFT JOIN core.price_change pc
            ON oi.product_id = pc.product_id
           AND o.year = pc.year
           AND o.week = pc.week;
    """)


def create_customer_revenue_view(cur):
    cur.execute("""
        CREATE OR REPLACE VIEW analytics.customer_revenue AS
        SELECT
            customer_id,
            COUNT(DISTINCT order_id) AS number_of_transactions,
            MIN(order_date) AS first_purchase_date,
            MAX(order_date) AS last_purchase_date,
            SUM(item_revenue) AS total_revenue,
            AVG(item_revenue) AS avg_item_revenue
        FROM analytics.order_revenue
        WHERE item_revenue IS NOT NULL
        GROUP BY customer_id;
    """)


def create_rfm_base_view(cur):
    cur.execute("""
        CREATE OR REPLACE VIEW analytics.rfm_base AS
        WITH reference_date AS (
            SELECT MAX(order_date) + INTERVAL '1 day' AS analysis_date
            FROM core.orders
        )
        SELECT
            cr.customer_id,
            EXTRACT(DAY FROM (rd.analysis_date - cr.last_purchase_date)) AS recency,
            cr.number_of_transactions AS frequency,
            cr.total_revenue AS monetary
        FROM analytics.customer_revenue cr
        CROSS JOIN reference_date rd;
    """)


def run_quality_checks(cur):
    print("\nChecking analytics views...")

    cur.execute("""
        SELECT COUNT(*) 
        FROM analytics.order_revenue;
    """)
    order_revenue_rows = cur.fetchone()[0]

    cur.execute("""
        SELECT COUNT(*) 
        FROM analytics.customer_revenue;
    """)
    customer_revenue_rows = cur.fetchone()[0]

    cur.execute("""
        SELECT COUNT(*) 
        FROM analytics.rfm_base;
    """)
    rfm_rows = cur.fetchone()[0]

    cur.execute("""
        SELECT COUNT(*) 
        FROM analytics.order_revenue
        WHERE unit_price IS NULL;
    """)
    missing_price_rows = cur.fetchone()[0]

    print(f"analytics.order_revenue rows: {order_revenue_rows}")
    print(f"analytics.customer_revenue rows: {customer_revenue_rows}")
    print(f"analytics.rfm_base rows: {rfm_rows}")
    print(f"Rows with missing price: {missing_price_rows}")

    if order_revenue_rows > 0 and customer_revenue_rows > 0 and rfm_rows > 0:
        print("Analytics views created successfully.")
    else:
        print("Warning: One or more analytics views are empty.")


def main():
    conn = get_connection()
    cur = conn.cursor()

    try:
        print("Connected to PostgreSQL.")

        create_analytics_schema(cur)
        print("Analytics schema ready.")

        create_order_revenue_view(cur)
        print("analytics.order_revenue view created.")

        create_customer_revenue_view(cur)
        print("analytics.customer_revenue view created.")

        create_rfm_base_view(cur)
        print("analytics.rfm_base view created.")

        conn.commit()

        run_quality_checks(cur)

    except Exception as e:
        conn.rollback()
        print("Error while creating analytics views:")
        print(e)
        raise

    finally:
        cur.close()
        conn.close()
        print("Database connection closed.")


if __name__ == "__main__":
    main()