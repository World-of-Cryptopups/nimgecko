# nim-gecko

A simple api wrapper for CoinGecko API (https://www.coingecko.com/en/api/documentation)

## Install

```
nimble install https://github.com/World-of-Cryptopups/nimgecko.git
```

## Usage

```nim
import nimgecko


let r = newCoinGecko()

echo r.ping().gecko_says
```

### Note:

All functions are not yet tested and not assured to be working 100% correctly and fully. Either the endpoint was wrong or wrong query implementation.

#### &copy; 2021 | World of Cryptopups
