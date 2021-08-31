import asyncdispatch, httpclient, json, strutils, strformat

type
  CoinGeckoBase*[HttpType] = ref object
    client: HttpType
  CoinGecko* = CoinGeckoBase[HttpClient]
  AsyncCoinGecko* = CoinGeckoBase[AsyncHttpClient]


const API_URL = "https://api.coingecko.com/api/v3/"



proc newCoinGecko*(): CoinGecko =
  ## create a new sync CoinGecko object
  new(result)
  result.client = newHttpClient()


proc newAsyncCoinGecko*(): AsyncCoinGecko =
  ## create a new async CoinGecko client
  new(result)
  result.client = newAsyncHttpClient()



proc request(this: CoinGecko | AsyncCoinGecko, endpoint: string): Future[
    JsonNode] {.multisync.} =
  let r = await this.client.get(url = API_URL & endpoint)
  result = parseJson(await r.body)






type
  GeckoSays* = ref object
    gecko_says*: string

proc ping*(this: CoinGecko | AsyncCoinGecko): Future[GeckoSays] {.multisync.} =
  ## Check API server status,
  let r = await this.request("ping")
  result = to(r, GeckoSays)



#==================== `/simple/` endpoints

proc simplePrice*(this: CoinGecko | AsyncCoinGecko, 
    ids: seq[string],
    vs_currencies: seq[string], 
    include_market_cap = false,
    include_24hr_vol = false, 
    include_24hr_change = false,
    include_last_updated_at = false): Future[JsonNode] {.multisync.} =
  ## Get the current price of any cryptocurrencies in any other supported currencies that you need.
  let
    idss = ids.join(",")
    vsc = vs_currencies.join(",")
    url = &"simple/price?ids={idss}&vs_currencies={vsc}&include_market_cap={include_market_cap}&include_24hr_vol={include_24hr_vol}&include_24hr_change={include_24hr_change}&include_last_updated_at={include_last_updated_at}"

  result = await this.request(url)


proc simpleTokenPrice*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  contract_addresses: seq[string],
  vs_currencies: seq[string],
  include_market_cap = false,
  include_24hr_vol = false, 
  include_24hr_change = false,
  include_last_updated_at = false): Future[JsonNode] {.multisync.} =
  ## Get current price of tokens (using contract addresses) for a given platform in any other currency that you need.
  let
    cts = contract_addresses.join(",")
    vsc = vs_currencies.join(",")
    url = &"/simple/token_price/{id}?contract_addresses={cts}&vs_currencies={vsc}&include_market_cap={include_market_cap}&include_24hr_vol={include_24hr_vol}&include_24hr_change={include_24hr_change}&include_last_updated_at={include_last_updated_at}"

  result = await this.request(url)


proc simpleSupportedVsCurrencies*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} = 
  ## Get list of supported_vs_currencies.
  result = await this.request("simple/supported_vs_currencies")


#==================== `/coins/` endpoints

type
  Coin* = ref object
    id*: string
    symbol*: string
    name*: string


proc coinsList*(this: CoinGecko | AsyncCoinGecko,
  include_platform = false,
  ): Future[seq[Coin]] {.multisync.} =
  ## List all supported coins id, name and symbol. 
  let 
    url = fmt"coins/list?include_platform={include_platform}"
    r = await this.request(url)

  result = to(r, seq[Coin])


proc coinsMarket*(this: CoinGecko | AsyncCoinGecko,
  vs_currency: string,
  ids: seq[string] = @[],
  category: string,
  order: string = "market_cap_desc",
  per_page: int = 100,
  page: int = 1,
  sparkline = false,
  price_change_percentage: seq[string] = @[]
  ): Future[JsonNode] {.multisync.} = 
  ## List all supported coins price, market cap, volume, and market related data.
  let
    idss = ids.join(",")
    priceChanges = price_change_percentage.join(",")
    url = &"coins/markets?vs_currency={vs_currency}&ids={idss}&category={category}&order={order}&per_page={per_page}&page={page}&sparkline={sparkline}&price_change_percentage={priceChanges}"

  result = await this.request(url)


proc coinsID*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  localization = true,
  tickers = true,
  market_data = true,
  community_data = true,
  developer_data = true,
  sparkline = true
  ): Future[JsonNode] {.multisync.} =
  ## Get current data (name, price, market, ... including exchange tickers) for a coin.
  let url = &"coins/{id}?localization={localization}&tickers={tickers}&market_data={market_data}&community_data={community_data}&developer_data={developer_data}&sparkline={sparkline}"

  result = await this.request(url)


proc coinsTickers*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  exchange_ids: seq[string] = @[],
  include_exchange_logo: bool = false,
  page: int = 1,
  order: string = "trust_score_desc",
  depth: bool = false
  ): Future[JsonNode] {.multisync.} =
  ## Get coin tickers (paginated to 100 items).
  let url = &"coins/{id}/tickers?exchange_ids={exchange_ids}&include_exchange_logo={include_exchange_logo}&page={page}&order={order}&depth={depth}"

  result = await this.request(url)


proc coinsHistory*(this: Coingecko | AsyncCoinGecko,
  id: string,
  date: string,
  localization: bool = true 
  ): Future[JsonNode] {.multisync.} =
  ## Get historical data (name, price, market, stats) at a given date for a coin.
  let url = &"coins/{id}/history?date={date}&localization={localization}"

  result = await this.request(url)


proc coinsMarketChart*(this: CoinGecko | AsyncCoinGecko,
  id: string, 
  vs_currency: string,
  days: string,
  interval: string = ""
  ): Future[JsonNode] {.multisync.} =
  ## Get historical market data include price, market cap, and 24h volume (granularity auto)
  let url = &"coins/{id}/market_chart?vs_currency={vs_currency}&days={days}&interval={interval}"

  result = await this.request(url)


proc coinsMarketChartRange*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  vs_currency: string,
  `from`: string,
  to: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get historical market data include price, market cap, and 24h volume within a range of timestamp (granularity auto)
  let url = &"coins/{id}/market_chart/range?vs_currency={vs_currency}&from={`from`}&to={to}"
  echo url

  result = await this.request(url)
  

proc coinsStatusUpdates*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  per_page: int = 50,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## Get status updates for a given coin
  let url = &"coins/{id}/status_updates?per_page={per_page}&page={page}"

  result = await this.request(url)


proc coinsOHLC*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  vs_currency: string,
  days: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get coin's OHLC
  let url = &"coins/{id}/ohlc?vs_currency={vs_currency}&days={days}"

  result = await this.request(url) 


