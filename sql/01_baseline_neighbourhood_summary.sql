
with calendar_30 as (
    select
        cd.listing_id,
        avg(l.listing_price) as avg_calendar_price_30,
        avg(case when cd.available then 1.0 else 0.0 end) as availability_30_rate
    from core.calendar_day cd
    join core.listing l
        on cd.listing_id = l.listing_id
    where cd.date >= (select min(date) from core.calendar_day)
      and cd.date < (select min(date) from core.calendar_day) + interval '30 days'
    group by cd.listing_id
),

review_counts as (
    select
        listing_id,
        count(*) as total_reviews
    from core.review
    group by listing_id
),

listing_enriched as (
    select
        l.listing_id,
        l.neighbourhood_id as neighbourhood,
        l.listing_price,
        l.minimum_nights,
        coalesce(r.total_reviews, 0) as total_reviews,
        c.availability_30_rate
    from core.listing l
    left join review_counts r
        on l.listing_id = r.listing_id
    left join calendar_30 c
        on l.listing_id = c.listing_id
)

select
    neighbourhood,
    count(*) as num_listings,
    avg(listing_price) as avg_price,
    percentile_cont(0.5) within group (order by listing_price) as median_price,
    avg(minimum_nights) as avg_minimum_nights,
    sum(total_reviews) as total_reviews,
    sum(total_reviews)::float / count(*) as reviews_per_listing,
    avg(availability_30_rate) as availability_30_rate
from listing_enriched
group by neighbourhood
order by neighbourhood
