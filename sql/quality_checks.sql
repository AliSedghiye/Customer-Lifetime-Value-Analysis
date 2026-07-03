SELECT 'customer' AS table_name,
       (SELECT COUNT(*) FROM staging.customer_raw) AS staging_rows,
       (SELECT COUNT(*) FROM core.customer) AS core_rows

UNION ALL

SELECT 'category',
       (SELECT COUNT(*) FROM staging.category_raw),
       (SELECT COUNT(*) FROM core.category)

UNION ALL

SELECT 'channel',
       (SELECT COUNT(*) FROM staging.channel_raw),
       (SELECT COUNT(*) FROM core.channel)

UNION ALL

SELECT 'marketing_channel',
       (SELECT COUNT(*) FROM staging.marketing_channel_raw),
       (SELECT COUNT(*) FROM core.marketing_channel)

UNION ALL

SELECT 'product',
       (SELECT COUNT(*) FROM staging.product_raw),
       (SELECT COUNT(*) FROM core.product)

UNION ALL

SELECT 'store',
       (SELECT COUNT(*) FROM staging.store_raw),
       (SELECT COUNT(*) FROM core.store)

UNION ALL

SELECT 'promotion',
       (SELECT COUNT(*) FROM staging.promotion_raw),
       (SELECT COUNT(*) FROM core.promotion)

UNION ALL

SELECT 'orders',
       (SELECT COUNT(*) FROM staging.orders_raw),
       (SELECT COUNT(*) FROM core.orders)

UNION ALL

SELECT 'order_item',
       (SELECT COUNT(*) FROM staging.order_item_raw),
       (SELECT COUNT(*) FROM core.order_item)

UNION ALL

SELECT 'price_change',
       (SELECT COUNT(*) FROM staging.price_change_raw),
       (SELECT COUNT(*) FROM core.price_change)

UNION ALL

SELECT 'session',
       (SELECT COUNT(*) FROM staging.session_raw),
       (SELECT COUNT(*) FROM core.session)

UNION ALL

SELECT 'support_ticket',
       (SELECT COUNT(*) FROM staging.support_ticket_raw),
       (SELECT COUNT(*) FROM core.support_ticket)

UNION ALL

SELECT 'campaign_touch',
       (SELECT COUNT(*) FROM staging.campaign_touch_raw),
       (SELECT COUNT(*) FROM core.campaign_touch)

UNION ALL


SELECT 'external_factor',
       (SELECT COUNT(*) FROM staging.external_factor_raw),
       (SELECT COUNT(*) FROM core.external_factor);

SELECT 'quality check completed' AS status;