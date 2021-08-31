import asyncdispatch, httpclient, json, strutils, strformat, options

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


proc simpleSupportedVsCurrencies*(this: CoinGecko | AsyncCoinGecko): Future[
    JsonNode] {.multisync.} =
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


proc coinsContract*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  contract_address: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get coin infofrom contract address
  let url = &"coins/{id}/contract/{contract_address}"

  result = await this.request(url)


proc coinsContractMarketChart*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  contract_address: string,
  vs_currency: string,
  days: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get historical market data include price, market cap, and 24h volume (granularity auto)
  let url = &"coins/{id}/market_chart?contract_address={contract_address}&vs_currency={vs_currency}&days={days}"

  result = await this.request(url)


proc coinsContractMarketChartRange*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  contract_address: string,
  vs_currency: string,
  `from`: string,
  to: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get historical market data include price, market cap, and 24h volume within a range of timestamp (granularity auto)
  let url = &"coins/{id}/market_chart/range?contract_address={contract_address}&vs_currency={vs_currency}&from={`from`}&to={to}"

  result = await this.request(url)


proc coinsCategoriesList*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## List all categories
  result = await this.request("coins/categories/list")


proc coinsCategories*(this: CoinGecko | AsyncCoinGecko,
  order: string = "market_cap_desc"
  ): Future[JsonNode] {.multisync.} =
  ## List all categories with market data
  let url = &"coins/categories?order={order}"

  result = await this.request(url)




#==================== `/asset_platforms` endpoints

type
  AssetPlatforms* = ref object
    id*: string
    chain_identifier*: Option[int] # could be null or int
    name*: string
    shortname*: string

proc assetPlatforms*(this: CoinGecko | AsyncCoinGecko): Future[seq[
    AssetPlatforms]] {.multisync.} =
  ## List all asset platforms (Blockchain networks)
  let r = await this.request("asset_platforms")

  result = to(r, seq[AssetPlatforms])


#==================== `/exchanges` endpoints

proc exchanges*(this: CoinGecko | AsyncCoinGecko,
  per_page: int = 100,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## List all exchanges
  let url = &"exchanges?per_page={per_page}&page={page}"

  result = await this.request(url)


proc exchangesList*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## List all supported market ids and name
  result = await this.request("exchanges/list")


proc exchangesID*(this: CoinGecko | AsyncCoinGecko,
  id: string
  ): Future[JsonNode] {.multisync.} =
  ## Get exhange volume in BTC and top 100 tickers only
  let url = &"exchanges/{id}"

  result = await this.request(url)


proc exchangesTickers*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  coin_ids: seq[string] = @[],
  include_exchange_logo = true,
  page: int = 1,
  order: string = "trust_score_desc",
  depth: string = "",
  ): Future[JsonNode] {.multisync.} =
  ## Get exhange volume in BTC and top 100 tickers only
  let
    cids = coin_ids.join(",")
    url = &"exchanges/{id}/tickers?coin_ids={cids}&include_exchange_logo={include_exchange_logo}&page={page}&order={order}&depth={depth}"

  result = await this.request(url)


proc exchangesStatusUpdates*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  per_page: int = 50,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## Get status updates for a given exchange
  let url = &"exchanges/{id}/status_updates?per_page={per_page}&page={page}"

  result = await this.request(url)


proc exchangesVolumeChart*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  days: int,
  ): Future[JsonNode] {.multisync.} =
  ## Get volume_chart data for a given exchange
  let url = &"exchanges/{id}/volume_chart?days={days}"

  result = await this.request(url)



#==================== `/finance` endpoints

proc financePlatforms*(this: CoinGecko | AsyncCoinGecko,
  per_page: int = 100,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## List all finance platforms
  result = await this.request(&"finance_platforms?per_page={per_page}&page={page}")


proc financeProducts*(this: CoinGecko | AsyncCoinGecko,
  per_page: int = 100,
  page: int = 1,
  start_at: string = "",
  end_at: string = ""
  ): Future[JsonNode] {.multisync.} =
  ## List all finance products
  result = await this.request(&"finance_products?per_page={per_page}&page={page}&start_at={start_at}&end_at={end_at}")


#==================== `/indexes` endpoints

proc indexes*(this: CoinGecko | AsyncCoinGecko,
  per_page: int = 100,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## List all market indexes
  result = await this.request(&"indexes?per_page={per_page}&page={page}")


proc indexesMarketID*(this: CoinGecko | AsyncCoinGecko,
  market_id: string,
  id: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get market index by market id and index id
  result = await this.request(&"indexes/{market_id}/{id}")


proc indexesList*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## List market indexes id and name
  result = await this.request(&"indexes/list")


#==================== `/indexes` endpoints

proc derivatives*(this: CoinGecko | AsyncCoinGecko,
  include_tickers: string = "unexpired"
  ): Future[JsonNode] {.multisync.} =
  ## List all derivative tickers
  result = await this.request(&"derivatives?include_tickers={include_tickers}")


proc derivativesExhanges*(this: CoinGecko | AsyncCoinGecko,
  order: string = "",
  per_page: int = 100,
  page: int = 1,
  ): Future[JsonNode] {.multisync.} =
  ## List all derivative exchanges
  result = await this.request(&"derivatives/exchanges?order={order}&per_page={per_page}&page={page}")


proc derivativesExchangesID*(this: CoinGecko | AsyncCoinGecko,
  id: string,
  include_tickers: string = ""
  ): Future[JsonNode] {.multisync.} =
  ## Show derivative exhange data
  result = await this.request(&"derivatives/exchanges/{id}?include_tickers={include_tickers}")

proc derivativesExchangesList*(this: CoinGecko | AsyncCoinGecko): Future[
    JsonNode] {.multisync.} =
  ## List all derivatives exchanges name and identifier
  result = await this.request(&"derivatives/exchanges/list")


#==================== `/status_updates` endpoints

proc statusUpdates*(this: CoinGecko | AsyncCoinGecko,
  category: string = "",
  project_type: string = "",
  per_page: int = 100,
  page: int = 1
  ): Future[JsonNode] {.multisync.} =
  ## List all status_updates with data (description, category, created_at, user, user_title and pin)
  result = await this.request(&"status_updates?category={category}&project_type={project_type}&per_page={per_page}&page={page}")


#==================== `/events` endpoints

proc events*(this: CoinGecko | AsyncCoinGecko,
  country_code: string = "",
  `type`: string = "",
  page: int = 1,
  upcoming_events_only = true,
  from_date: string = "",
  to_date: string = "",
  ): Future[JsonNode] {.multisync.} =
  ## Get events, paginated by 100
  let
    url = &"events?country_code={country_code}&type={`type`}&page={page}&upcoming_events_only={upcoming_events_only}&from_date={from_date}&to_date={to_date}"

  result = await this.request(url)


proc eventsCountries*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## Get list of event countries
  result = await this.request(&"events/countries")


proc eventsTypes*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## Get list of events types
  result = await this.request(&"events/types")


#==================== `/exchange_rates` endpoints

proc exchangeRates*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## Get BTC-to-Currency exchange rates
  result = await this.request("exchange_rates")


#==================== `/exchange_rates` endpoints

proc searchTrending*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## Get trending search coins (Top-7) on CoinGecko in the last 24 hours
  result = await this.request("search/trending")


#==================== `/global` endpoints

proc global*(this: CoinGecko | AsyncCoinGecko): Future[JsonNode] {.multisync.} =
  ## Get cryptocurrency global data
  result = await this.request("global")


proc globalDecentralizedFinanceDefi*(this: CoinGecko | AsyncCoinGecko): Future[
    JsonNode] {.multisync.} =
  ## Get cryptocurrency global decentralized finance(defi) data
  result = await this.request("global/decentralized_finance_defi")


#==================== `/companies` (beta) endpoints

proc companiesPublicTreasury*(this: CoinGecko | AsyncCoinGecko,
  coin_id: string,
  ): Future[JsonNode] {.multisync.} =
  ## Get public companies data
  result = await this.request(&"companies/public_treasury/{coin_id}")
