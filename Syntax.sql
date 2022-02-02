/* Sushiswap query: Guzzling Gas
When do LPers decide to pay the gas fees and take profits? 
What percentage (and how much) of profits usually get eaten up by gas fees?

The result used 40.067 MB 
*/
    SELECT DISTINCT(T4.from_address) -- To have each address from the table made by a subquery
      		, transactions.block_timestamp
      		, T3.pool_name
      		, T3.tx_id
      		, udm_events.amount -- Amount based on the coin/token
      		, udm_events.amount_usd
      		, transactions.fee_usd
    FROM ethereum.udm_events LEFT JOIN ethereum.transactions
    		ON udm_events.symbol = transactions.symbol
          JOIN (
            	SELECT dex_liquidity_pools.pool_name
      					, dex_swaps.token_address
      					, dex_swaps.tx_id
      					, dex_swaps.from_address
      			FROM ethereum.dex_liquidity_pools LEFT JOIN ethereum.dex_swaps
      				ON dex_liquidity_pools.creation_time = dex_swaps.block_timestamp
      			WHERE dex_liquidity_pools.platform = 'sushiswap' -- To narrow the protocol used for the query
          ) AS T3
      		ON transactions.from_address = T3.from_address
      	  JOIN (
    			SELECT transactions.from_address
    			FROM ethereum.transactions
     			GROUP BY transactions.from_address
            ) AS T4
      		ON transactions.from_address = T4.from_address
    
    WHERE transactions.block_timestamp IS NOT NULL
    		AND udm_events.amount IS NOT NULL 
			AND transactions.block_timestamp::DATE > CURRENT_DATE-30 -- So the query is limited to activity within the past 30 days
;

-- The intention of the code below was to generate the images that depicted the withdrawl/addition into liquidity pools.
SELECT *
FROM ethereum.dex_swaps
WHERE block_timestamp::date > CURRENT_DATE - 30 
AND pool_name LIKE '%SUSHI%' -- Works best to contain SUSHI pools alone **
