import nimgecko , json

let r = newCoinGecko()

let s = r.simplePrice(@["wax"], @["php"])
echo $s