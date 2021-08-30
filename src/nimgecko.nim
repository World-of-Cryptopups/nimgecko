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