with orders as (

    select * from {{ ref('stg_olist__orders') }}

),

order_payments as (

    select
        order_id,
        sum(payment_value) as total_payment_value,
        count(payment_sequential) as payment_transactions_count
    from {{ ref('stg_olist__order_payments') }}
    group by 1

),

final as (

    select
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        coalesce(p.total_payment_value, 0) as total_payment_value,
        coalesce(p.payment_transactions_count, 0) as payment_transactions_count

    from orders as o
    left join order_payments as p
        on o.order_id = p.order_id

)

select * from final