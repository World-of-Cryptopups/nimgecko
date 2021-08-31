import nimgecko , json

let r = newCoinGecko()

let s = r.simplePrice(@["wax"], @["php"])
echo $s


let y = r.coinsMarketChartRange("wax", "php", "1392577232", "1422577232")
echo $y