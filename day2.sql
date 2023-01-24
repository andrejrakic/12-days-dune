-- how many swaps per week, and what is the total volume of these swaps (in USD) for USDC/WETH?
-- USDC/WETH pair on Uniswap V2: 0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc
-- https://v2.info.uniswap.org/pair/0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc

WITH frequency AS (
    SELECT 
        date_trunc('week', evt_block_time) AS perWeek,
        count(*) AS num_swaps
    FROM uniswap_v2_ethereum.Pair_evt_Swap
    WHERE contract_address = 0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc
    GROUP BY 1
),

volume AS (
    WITH 
        base AS (
            SELECT 
                date_trunc('minute', s.evt_block_time) AS time,
                CASE WHEN cast(amount0Out AS DOUBLE) = 0 THEN p.token1 ELSE p.token0 END AS token_bought_address,
                CASE WHEN cast(amount0Out AS DOUBLE) = 0 THEN cast(amount1Out AS DOUBLE) ELSE cast(amount0Out AS DOUBLE) END AS token_bought_amount_raw
            FROM uniswap_v2_ethereum.Pair_evt_Swap AS s
            LEFT JOIN uniswap_v2_ethereum.Factory_evt_PairCreated AS p 
            ON p.pair = s.contract_address
            WHERE s.contract_address = 0xb4e16d0168e52d35cacd2c6185b44281ec28c9dc
        )
    
    SELECT 
        date_trunc('week', b.time) AS time,
        SUM(token_bought_amount_raw / pow(10, COALESCE(t.decimals, 18)) * p.price) AS total_usd_amount
    FROM base AS b
    LEFT JOIN tokens.erc20 as t ON t.contract_address = b.token_bought_address
    LEFT JOIN prices.usd AS p ON p.minute = b.time AND p.blockchain = 'ethereum' AND p.contract_address = b.token_bought_address
    GROUP BY 1
)

-- SELECT * FROM frequency
-- SELECT * FROM volume

SELECT
    v.time,
    f.num_swaps,
    v.total_usd_amount
FROM volume AS v
LEFT JOIN frequency as f ON f.perWeek = v.time

