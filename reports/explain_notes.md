# Explain Analyze Notes

## Observation 1

The query performs a sequential scan on the listing table.

## Observation 2

The review table is grouped by listing_id before joining.

## Observation 3

The final result is grouped by neighbourhood_id to produce neighbourhood-level metrics.

## Raw plan excerpt

```text
GroupAggregate  (cost=40248.78..40485.24 rows=22 width=156) (actual time=401.157..406.881 rows=22 loops=1)
  Group Key: l.neighbourhood_id
  Buffers: shared hit=13394 read=7736
  ->  Sort  (cost=40248.78..40274.98 rows=10480 width=53) (actual time=400.552..401.487 rows=10480 loops=1)
        Sort Key: l.neighbourhood_id
        Sort Method: quicksort  Memory: 938kB
        Buffers: shared hit=13394 read=7736
        ->  Hash Left Join  (cost=39199.12..39548.96 rows=10480 width=53) (actual time=385.926..396.830 rows=10480 loops=1)
              Hash Cond: (l.listing_id = c.listing_id)
              Buffers: shared hit=13394 read=7736
              ->  Hash Left Join  (cost=13726.93..14049.25 rows=10480 width=29) (actual time=124.963..132.658 rows=10480 loops=1)
                    Hash Cond: (l.listing_id = r.listing_id)
                    Buffers: shared hit=670 read=7736
                    ->  Seq Scan on listing l  (cost=0.00..294.80 rows=10480 width=21) (actual time=0.035..1.526 rows=10480 loops=1)
                          Buffers: shared hit=190
                    ->  Hash  (cost=13658.66..13658.66 rows=5462 width=16) (actual time=124.897..125.032 rows=9383 loops=1)
                          Buckets: 16384 (originally 8192)  Batches: 1 (originally 1)  Memory Usage: 568kB
                          Buffers: shared hit=480 read=7736
                          ->  Subquery Scan on r  (cost=13549.41..13658.66 rows=5462 width=16) (actual time=120.132..123.167 rows=9383 loops=1)
                                Buffers: shared hit=480 read=7736
                                ->  Finalize HashAggregate  (cost=13549.41..13604.03 rows=5462 width=16) (actual time=120.130..121.841 rows=9383 loops=1)
                                      Group Key: review.listing_id
                                      Batches: 1  Memory Usage: 1169kB
                                      Buffers: shared hit=480 read=7736
                                      ->  Gather  (cost=12347.77..13494.80 rows=10924 width=16) (actual time=113.113..115.602 rows=13301 loops=1)
                                            Workers Planned: 2
                                            Workers Launched: 2
                                            Buffers: shared hit=480 read=7736
                                            ->  Partial HashAggregate  (cost=11347.77..11402.40 rows=5462 width=16) (actual time=101.018..101.954 rows=4434 loops=3)
                                                  Group Key: review.listing_id
                                                  Batches: 1  Memory Usage: 721kB
                                                  Buffers: shared hit=480 read=7736
                                                  Worker 0:  Batches: 1  Memory Usage: 721kB
                                                  Worker 1:  Batches: 1  Memory Usage: 721kB
                                                  ->  Parallel Seq Scan on review  (cost=0.00..10303.85 rows=208785 wid
