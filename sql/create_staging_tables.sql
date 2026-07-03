CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE staging.customer_raw (
    customer_id TEXT,
    signup_date TEXT,
    city TEXT,
    state TEXT,
    segment TEXT,
	status TEXT
);

CREATE TABLE staging.category_raw (
    category_id TEXT,
    category_name TEXT
);

CREATE TABLE staging.channel_raw (
    channel_id TEXT,
    channel_name TEXT
);

CREATE TABLE staging.marketing_channel_raw (
    channel_id TEXT,
    channel_name TEXT, 
	channel_type TEXT,
	cost_tier TEXT
);

CREATE TABLE staging.product_raw (
    product_id TEXT,
    category_id TEXT,
    brand TEXT,
    sku_name TEXT
);

CREATE TABLE staging.store_raw (
    store_id TEXT,
    store_city TEXT,
    store_state TEXT,
    store_type TEXT
);

CREATE TABLE staging.promotion_raw (
    promo_id TEXT,
    promo_type TEXT,
    start_date TEXT,
    end_date TEXT,
    discount_value TEXT
);

CREATE TABLE staging.orders_raw (
    order_id TEXT,
    customer_id TEXT,
    order_date TEXT,
    store_id TEXT,
    channel_id TEXT,
    payment_type TEXT,
    year TEXT,
    week TEXT
);

CREATE TABLE staging.order_item_raw (
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    promo_id TEXT,
    quantity TEXT,
    item_discount TEXT
);

CREATE TABLE staging.price_change_raw (
    product_id TEXT,
    year TEXT,
    week TEXT,
    unit_price TEXT
);

CREATE TABLE staging.session_raw (
    session_id TEXT,
    customer_id TEXT,
    session_start TEXT,
    session_duration_sec TEXT,
    pages_viewed TEXT,
    device TEXT,
    referrer TEXT
);

CREATE TABLE staging.support_ticket_raw (
    ticket_id TEXT,
    customer_id TEXT,
    created_date TEXT,
    issue_type TEXT,
    status TEXT,
    resolution_time_hr TEXT,
    csat_score TEXT
);

CREATE TABLE staging.campaign_touch_raw (
    touch_id TEXT,
    customer_id TEXT,
    touch_date TEXT,
    channel TEXT,
    campaign_name TEXT,
    outcome TEXT
);

CREATE TABLE staging.external_factor_raw (
    factor_id TEXT,
    store_id TEXT,
    factor_date TEXT,
    is_holiday TEXT,
    temp_c TEXT,
    rainfall_mm TEXT,
    trend_index TEXT,
    cpi_index TEXT,
	year TEXT,
	week TEXT
);