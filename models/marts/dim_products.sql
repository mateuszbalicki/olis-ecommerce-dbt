with products as (

    select * from {{ ref('stg_olist__products') }}

),

translation as (

    select * from {{ ref('stg_olist__product_category_name_translation') }}

),

final as (

    select
        p.product_id,
        p.product_category_name as category_name_portuguese,
        coalesce(t.product_category_name_english, 'unknown') as category_name_english,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm

    from products as p
    left join translation as t
        on p.product_category_name = t.product_category_name

)

select * from final