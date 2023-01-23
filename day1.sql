-- Dune Engine v2 (Dune SQL) -> Decoded projects -> 
-- Search: uniswap v2 -> All chains / Ethereum -> Factory -> event -> PairCreated

-- What is the number of pairs created containing tokens USDC and/or WETH?
-- USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48
-- WETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2

SELECT COUNT(pair)
FROM uniswap_v2_ethereum.Factory_evt_PairCreated
WHERE token0 IN (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)
OR token1 IN (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)


SELECT 
    p.evt_block_time as time,
    p.pair as pair_address,
    p.token0,
    t0.symbol as t0_symbol,
    p.token1,
    t1.symbol as t1_symbol
FROM uniswap_v2_ethereum.Factory_evt_PairCreated AS p

LEFT JOIN tokens.erc20 AS t0
    ON t0.contract_address = p.token0
LEFT JOIN tokens.erc20 as t1
    ON t1.contract_address = p.token1
    
WHERE token0 IN (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)
AND token1 IN (0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)
AND t0.blockchain = 'ethereum'
AND t1.blockchain = 'ethereum'
