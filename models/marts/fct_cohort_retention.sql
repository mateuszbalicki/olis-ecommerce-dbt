with customer_orders as (
    
    select
        c.customer_unique_id,
        o.order_id,
        o.order_approved_at
    from {{ ref('fct_orders') }} as o
    join {{ ref('dim_customers') }} as c
        on o.customer_id = c.customer_id
    where o.order_status = 'delivered'
      and o.order_approved_at is not null
    
),

first_purchase as (
    
    select
        customer_unique_id,
        date_trunc('month', min(order_approved_at)) as cohort_month
    from customer_orders
    group by 1
    
),

cohort_calc as (
    
    select
        co.customer_unique_id,
        co.order_id,
        fp.cohort_month,
        datediff('month', fp.cohort_month, date_trunc('month', co.order_approved_at)) as cohort_index
    from customer_orders as co
    join first_purchase as fp
        on co.customer_unique_id = fp.customer_unique_id
        
)

select
    cohort_month,
    cohort_index,
    count(distinct customer_unique_id) as active_customers,
    count(order_id) as total_orders
from cohort_calc
group by 1, 2