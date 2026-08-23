with order_items as (
    
    select 
        order_id,
        product_id
    from {{ ref('stg_olist__order_items') }}

),

product_pairs as (

    select
        a.order_id,
        a.product_id as product_a_id,
        b.product_id as product_b_id
    from order_items a
    join order_items b
        on a.order_id = b.order_id
        and a.product_id < b.product_id 

),

cross_sell_calc as (

    select
        product_a_id,
        product_b_id,
        count(distinct order_id) as times_bought_together
    from product_pairs
    group by 1, 2
    having count(distinct order_id) > 1 

),

final as (

    select
        c.product_a_id,
        p1.category_name_english as category_a,
        c.product_b_id,
        p2.category_name_english as category_b,
        c.times_bought_together
    from cross_sell_calc c
    left join {{ ref('dim_products') }} p1 
        on c.product_a_id = p1.product_id
    left join {{ ref('dim_products') }} p2 
        on c.product_b_id = p2.product_id

)

select * from final
order by times_bought_together desc