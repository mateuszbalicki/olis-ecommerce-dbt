with customer_orders as (

    select
        customer_id,
        max(order_approved_at) as last_order_date,
        count(order_id) as frequency,
        sum(total_payment_value) as monetary
    from {{ ref('fct_orders') }}
    where order_status = 'delivered'
    group by 1

),

rfm_calc as (

    select
        customer_id,
        datediff(day, last_order_date, current_date()) as recency_days,
        frequency,
        monetary,
        ntile(5) over (order by datediff(day, last_order_date, current_date()) desc) as r_score,
        ntile(5) over (order by frequency asc) as f_score,
        ntile(5) over (order by monetary asc) as m_score
    from customer_orders

),

rfm_segments as (

    select 
        *,
        r_score + f_score + m_score as total_rfm_score,
        case
            when (r_score + f_score + m_score) >= 13 then 'Champions'
            when (r_score + f_score + m_score) between 10 and 12 then 'Loyal Customers'
            when (r_score + f_score + m_score) between 7 and 9 then 'Potential Loyalists'
            when (r_score + f_score + m_score) between 5 and 6 then 'At Risk'
            else 'Lost Customers'
        end as customer_segment

    from rfm_calc

)

select * from rfm_segments