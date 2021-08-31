# nim-gecko

A simple client for CoinGecko API (https://www.coingecko.com/en/api/documentation)

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

## Currently Implemented Endpoints

- ping
- simple
- coins
- contract (on-going)

#### &copy; 2021 | World of Cryptopups
