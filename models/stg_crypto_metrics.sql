{{ config(materialized='view') }}

with source_payload as (
    select * from {{ source('api_source', 'api_crypto_tickers') }}
),

transformed as (
    select
        coin_id as asset_id,
        coin_symbol as ticker_symbol,
        coin_name as asset_name,
        current_price as price_usd,
        market_cap as market_cap_usd,
        total_volume as volume_24h_usd,
        extracted_at as loaded_at_timestamp
    from source_payload
)

select * from transformed
