with source as (

    select * from {{ source('olist_raw', 'geolocation')}}

),

renamed as (

    select 
        geolocation_city,
        geolocation_lat,
        geolocation_lng,
        geolocation_state,
        geolocation_zip_code_prefix

    from source
)

select * from renamed