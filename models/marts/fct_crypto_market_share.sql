{{ config(materialized='table') }}

with staging_metrics as (
    select * from {{ ref('stg_crypto_metrics') }}
),

global_aggregations as (
    select 
        sum(market_cap_usd) as total_global_market_cap
    from staging_metrics
),

final_mart as (
    select
        s.asset_id,
        s.ticker_symbol,
        s.asset_name,
        s.price_usd,
        s.market_cap_usd,
        s.volume_24h_usd,
        
        round(
            (s.market_cap_usd / g.total_global_market_cap) * 100, 
            2
        ) as market_cap_dominance_percentage,
        
        s.loaded_at_timestamp
    from staging_metrics s
    cross join global_aggregations g
)

select * from final_mart
