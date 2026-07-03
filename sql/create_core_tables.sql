CREATE TABLE IF NOT EXISTS core.customer (
    customer_id TEXT PRIMARY KEY,
    signup_date DATE,
    city TEXT,
    state TEXT,
    segment TEXT,
    status TEXT
);

CREATE TABLE IF NOT EXISTS core.category (
    category_id TEXT PRIMARY KEY,
    category_name TEXT
);

CREATE TABLE IF NOT EXISTS core.channel (
    channel_id TEXT PRIMARY KEY,
    channel_name TEXT
);

CREATE TABLE IF NOT EXISTS core.marketing_channel (
    channel_id TEXT PRIMARY KEY,
    channel_name TEXT,
    channel_type TEXT,
    cost_tier TEXT
);

CREATE TABLE IF NOT EXISTS core.product (
    product_id TEXT PRIMARY KEY,
    category_id TEXT REFERENCES core.category(category_id),
    brand TEXT,
    sku_name TEXT
);

CREATE TABLE IF NOT EXISTS core.store (
    store_id TEXT PRIMARY KEY,
    store_city TEXT,
    store_state TEXT,
    store_type TEXT
);

CREATE TABLE IF NOT EXISTS core.promotion (
    promo_id TEXT PRIMARY KEY,
    promo_type TEXT,
    start_date DATE,
    end_date DATE,
    discount_value NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS core.orders (
    order_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.customer(customer_id),
    order_date DATE,
    store_id TEXT REFERENCES core.store(store_id),
    channel_id TEXT REFERENCES core.channel(channel_id),
    payment_type TEXT,
    year INT,
    week INT
);

CREATE TABLE IF NOT EXISTS core.order_item (
    order_item_id TEXT PRIMARY KEY,
    order_id TEXT REFERENCES core.orders(order_id),
    product_id TEXT REFERENCES core.product(product_id),
    promo_id TEXT REFERENCES core.promotion(promo_id),
    quantity INT,
    item_discount NUMERIC(10,2)
);

CREATE TABLE IF NOT EXISTS core.price_change (
    product_id TEXT REFERENCES core.product(product_id),
    year INT,
    week INT,
    unit_price NUMERIC(10,2),
    PRIMARY KEY (product_id, year, week)
);

CREATE TABLE IF NOT EXISTS core.session (
    session_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.customer(customer_id),
    session_start TIMESTAMP,
    session_duration_sec INT,
    pages_viewed INT,
    device TEXT,
    referrer TEXT
);

CREATE TABLE IF NOT EXISTS core.support_ticket (
    ticket_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.customer(customer_id),
    created_date DATE,
    issue_type TEXT,
    status TEXT,
    resolution_time_hr INT,
    csat_score INT
);

CREATE TABLE IF NOT EXISTS core.campaign_touch (
    touch_id TEXT PRIMARY KEY,
    customer_id TEXT REFERENCES core.customer(customer_id),
    touch_date DATE,
    channel TEXT,
    campaign_name TEXT,
    outcome TEXT
);

CREATE TABLE IF NOT EXISTS core.external_factor (
    factor_id TEXT PRIMARY KEY,
    store_id TEXT REFERENCES core.store(store_id),
    factor_date DATE,
    is_holiday BOOLEAN,
    temp_c NUMERIC(5,2),
    rainfall_mm NUMERIC(6,2),
    trend_index NUMERIC(10,2),
    cpi_index NUMERIC(10,2),
    year INT,
    week INT
);