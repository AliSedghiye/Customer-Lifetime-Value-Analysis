INSERT INTO core.customer (
    customer_id,
    signup_date,
    city,
    state,
    segment,
    status
)
SELECT DISTINCT
    TRIM(customer_id),
    TO_DATE(NULLIF(TRIM(signup_date), ''), 'YYYY-MM-DD'),
    TRIM(city),
    TRIM(state),
    TRIM(segment),
    TRIM(status)
FROM staging.customer_raw
WHERE customer_id IS NOT NULL
  AND TRIM(customer_id) <> ''
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO core.category (
    category_id,
    category_name
)
SELECT DISTINCT
    TRIM(category_id),
    TRIM(category_name)
FROM staging.category_raw
WHERE category_id IS NOT NULL
  AND TRIM(category_id) <> ''
ON CONFLICT (category_id) DO NOTHING;

INSERT INTO core.channel (
    channel_id,
    channel_name
)
SELECT DISTINCT
    TRIM(channel_id),
    TRIM(channel_name)
FROM staging.channel_raw
WHERE channel_id IS NOT NULL
  AND TRIM(channel_id) <> ''
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO core.marketing_channel (
    channel_id,
    channel_name,
    channel_type,
    cost_tier
)
SELECT DISTINCT
    TRIM(channel_id),
    TRIM(channel_name),
    TRIM(channel_type),
    TRIM(cost_tier)
FROM staging.marketing_channel_raw
WHERE channel_id IS NOT NULL
  AND TRIM(channel_id) <> ''
ON CONFLICT (channel_id) DO NOTHING;

INSERT INTO core.store (
    store_id,
    store_city,
    store_state,
    store_type
)
SELECT DISTINCT
    TRIM(store_id),
    TRIM(store_city),
    TRIM(store_state),
    TRIM(store_type)
FROM staging.store_raw
WHERE store_id IS NOT NULL
  AND TRIM(store_id) <> ''
ON CONFLICT (store_id) DO NOTHING;

INSERT INTO core.promotion (
    promo_id,
    promo_type,
    start_date,
    end_date,
    discount_value
)
SELECT DISTINCT
    TRIM(promo_id),
    TRIM(promo_type),
    TO_DATE(NULLIF(TRIM(start_date), ''), 'YYYY-MM-DD'),
    TO_DATE(NULLIF(TRIM(end_date), ''), 'YYYY-MM-DD'),
    NULLIF(TRIM(discount_value), '')::NUMERIC(10,2)
FROM staging.promotion_raw
WHERE promo_id IS NOT NULL
  AND TRIM(promo_id) <> ''
ON CONFLICT (promo_id) DO NOTHING;

INSERT INTO core.product (
    product_id,
    category_id,
    brand,
    sku_name
)
SELECT DISTINCT
    TRIM(product_id),
    TRIM(category_id),
    TRIM(brand),
    TRIM(sku_name)
FROM staging.product_raw
WHERE product_id IS NOT NULL
  AND TRIM(product_id) <> ''
  AND TRIM(category_id) IN (
      SELECT category_id FROM core.category
  )
ON CONFLICT (product_id) DO NOTHING;

INSERT INTO core.orders (
    order_id,
    customer_id,
    order_date,
    store_id,
    channel_id,
    payment_type,
    year,
    week
)
SELECT DISTINCT
    TRIM(order_id),
    TRIM(customer_id),
    TO_DATE(NULLIF(TRIM(order_date), ''), 'DD-MM-YYYY'),
    TRIM(store_id),
    TRIM(channel_id),
    TRIM(payment_type),
    NULLIF(TRIM(year), '')::INT,
    NULLIF(TRIM(week), '')::INT
FROM staging.orders_raw
WHERE order_id IS NOT NULL
  AND TRIM(order_id) <> ''
  AND TRIM(customer_id) IN (
      SELECT customer_id FROM core.customer
  )
  AND TRIM(store_id) IN (
      SELECT store_id FROM core.store
  )
  AND TRIM(channel_id) IN (
      SELECT channel_id FROM core.channel
  )
ON CONFLICT (order_id) DO NOTHING;

INSERT INTO core.order_item (
    order_item_id,
    order_id,
    product_id,
    promo_id,
    quantity,
    item_discount
)
SELECT DISTINCT
    TRIM(order_item_id),
    TRIM(order_id),
    TRIM(product_id),
    NULLIF(TRIM(promo_id), ''),
    NULLIF(TRIM(quantity), '')::INT,
    NULLIF(TRIM(item_discount), '')::NUMERIC(10,2)
FROM staging.order_item_raw
WHERE order_item_id IS NOT NULL
  AND TRIM(order_item_id) <> ''
  AND TRIM(order_id) IN (
      SELECT order_id FROM core.orders
  )
  AND TRIM(product_id) IN (
      SELECT product_id FROM core.product
  )
  AND (
      promo_id IS NULL
      OR TRIM(promo_id) = ''
      OR TRIM(promo_id) IN (
          SELECT promo_id FROM core.promotion
      )
  )
ON CONFLICT (order_item_id) DO NOTHING;

INSERT INTO core.price_change (
    product_id,
    year,
    week,
    unit_price
)
SELECT DISTINCT
    TRIM(product_id),
    NULLIF(TRIM(year), '')::INT,
    NULLIF(TRIM(week), '')::INT,
    NULLIF(TRIM(unit_price), '')::NUMERIC(10,2)
FROM staging.price_change_raw
WHERE TRIM(product_id) IN (
    SELECT product_id FROM core.product
)
ON CONFLICT (product_id, year, week) DO NOTHING;

INSERT INTO core.session (
    session_id,
    customer_id,
    session_start,
    session_duration_sec,
    pages_viewed,
    device,
    referrer
)
SELECT DISTINCT
    TRIM(session_id),
    TRIM(customer_id),
    NULLIF(TRIM(session_start), '')::TIMESTAMP,
    NULLIF(TRIM(session_duration_sec), '')::INT,
    NULLIF(TRIM(pages_viewed), '')::INT,
    TRIM(device),
    TRIM(referrer)
FROM staging.session_raw
WHERE session_id IS NOT NULL
  AND TRIM(session_id) <> ''
  AND TRIM(customer_id) IN (
      SELECT customer_id FROM core.customer
  )
ON CONFLICT (session_id) DO NOTHING;

INSERT INTO core.support_ticket (
    ticket_id,
    customer_id,
    created_date,
    issue_type,
    status,
    resolution_time_hr,
    csat_score
)
SELECT DISTINCT
    TRIM(ticket_id),
    TRIM(customer_id),
    TO_DATE(NULLIF(TRIM(created_date), ''), 'YYYY-MM-DD'),
    TRIM(issue_type),
    TRIM(status),
    NULLIF(TRIM(resolution_time_hr), '')::INT,
    NULLIF(TRIM(csat_score), '')::INT
FROM staging.support_ticket_raw
WHERE ticket_id IS NOT NULL
  AND TRIM(ticket_id) <> ''
  AND TRIM(customer_id) IN (
      SELECT customer_id FROM core.customer
  )
ON CONFLICT (ticket_id) DO NOTHING;

INSERT INTO core.campaign_touch (
    touch_id,
    customer_id,
    touch_date,
    channel,
    campaign_name,
    outcome
)
SELECT DISTINCT
    TRIM(touch_id),
    TRIM(customer_id),
    TO_DATE(NULLIF(TRIM(touch_date), ''), 'YYYY-MM-DD'),
    TRIM(channel),
    TRIM(campaign_name),
    TRIM(outcome)
FROM staging.campaign_touch_raw
WHERE touch_id IS NOT NULL
  AND TRIM(touch_id) <> ''
  AND TRIM(customer_id) IN (
      SELECT customer_id FROM core.customer
  )
ON CONFLICT (touch_id) DO NOTHING;

INSERT INTO core.external_factor (
    factor_id,
    store_id,
    factor_date,
    is_holiday,
    temp_c,
    rainfall_mm,
    trend_index,
    cpi_index,
    year,
    week
)
SELECT DISTINCT
    TRIM(factor_id),
    TRIM(store_id),
    TO_DATE(NULLIF(TRIM(factor_date), ''), 'YYYY-MM-DD'),
    NULLIF(TRIM(is_holiday), '')::BOOLEAN,
    NULLIF(TRIM(temp_c), '')::NUMERIC(5,2),
    NULLIF(TRIM(rainfall_mm), '')::NUMERIC(6,2),
    NULLIF(TRIM(trend_index), '')::NUMERIC(10,2),
    NULLIF(TRIM(cpi_index), '')::NUMERIC(10,2),
    NULLIF(TRIM(year), '')::INT,
    NULLIF(TRIM(week), '')::INT
FROM staging.external_factor_raw
WHERE factor_id IS NOT NULL
  AND TRIM(factor_id) <> ''
  AND TRIM(store_id) IN (
      SELECT store_id FROM core.store
  )
ON CONFLICT (factor_id) DO NOTHING;