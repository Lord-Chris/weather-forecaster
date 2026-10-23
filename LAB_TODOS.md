# Lab TODOs

All 20 `TODO(lab-N.M)` markers on `workshop/main`, in lab order. Search for `TODO(lab-N.M)` in your IDE to jump to one. Line numbers are as on `workshop/main` and may drift.

| Lab | Topic | Steps |
|---|---|---|
| 1 | Logs | 1.1 to 1.10 |
| 2 | Metrics | 2.1 to 2.5 |
| 3 | Traces | 3.1 to 3.5 |

---

## Lab 1: Logs

Seven plain logs (1.1 to 1.7), then three wide events (1.8 to 1.10). Work top to bottom.

### 1.1 Errors in view models
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:101`
- **Why first:** rare and the most valuable.

> Errors in view models, touch these first (rare, most valuable): add telemetry.log.e(...) (locator<Telemetry>()) next to the line above, and at the same kind of catch in HomeViewModel.init, AddCityViewModel.search and onResultTap, AirQualityViewModel and WeatherDetailsViewModel.fetchForecast. Fields: viewmodel, operation, error.type. Never the message. Use `catch (e, s)` and pass the stack trace as the last argument: `log.e('...', {...}, s)`.

### 1.2 Errors at boundaries
- **File:** `lib/services/api/api_service.dart:145`
- **Why here:** the error type is lost once wrapped.

> Errors at boundaries: log the error type here, and in the WeatherRepo catch blocks that wrap unknown errors into FallbackAppException (the original type is lost once wrapped). Fields: service, operation, error.type. Pass the stack trace as the last argument too (`catch (e, s)`).

### 1.3 Decisions: data source
- **File:** `lib/features/weather/data/repositories/weather_repo.dart:46`
- **Why here:** this is where the silent fallback shows up.

> Decisions: data source. Log each branch that changes what the user sees (the prints below, the cache miss in _cachedWeather, and the same branches in get5DayForecast and getAirQuality) with named fields: source, offline, fallback, cache_hit.

### 1.4 Silent drops
- **File:** `lib/features/weather/data/repositories/weather_repo.dart:154`
- **Why here:** invisible by design, so you only see them if you log them.

> Silent drops: the app skips these without telling the user. Log the duplicate skip here, the stale search response and the too-short query in AddCityViewModel, and the offline refusal in searchCities.

### 1.5 State and persistence
- **File:** `lib/features/weather/data/datasources/weather_local_source.dart:100`
- **Why here:** explains stale or missing data later.

> State and persistence: log what was read and written to storage here and in saveCities (saved_count, cache_hit, parse failures), and what cacheWeather, cacheForecast and cacheAirQuality wrote (city_id).

### 1.6 Lifecycle: user input
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:38`
- **Why late:** noisy.

> Lifecycle: user input. Replace the print here, in AddCityViewModel.onQueryChanged and onResultTap with a structured log and named fields (query_length, city_id). Noisy, so touch these late.

### 1.7 Lifecycle: navigation
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:114`
- **Why last:** noisiest.

> Lifecycle: navigation. Replace the print here and in onAddCityTap, WeatherDetailsViewModel.init and onAirQualityTap, and AirQualityViewModel.init, with a structured log (screen, city_id).

### 1.8 Wide event: weather fetch
- **File:** `lib/features/weather/data/repositories/weather_repo.dart:34`
- **One event per:** repo call (`weather.fetch`).

> Wide event: weather fetch. Start a Stopwatch and a `final event = <String, Object?>{'operation': 'getCurrentWeather', 'city_id': city.id, 'success': true}` here, fill it as the branches below run (connected, source, fallback, cache_hit, error.type), and log it ONCE in a `finally` with duration_ms. Do the same in get5DayForecast and getAirQuality, then delete the fetch start/done prints in this repo.

### 1.9 Wide event: city search
- **File:** `lib/features/weather/presentation/add_city_view/add_city_viewmodel.dart:49`
- **One event per:** user action (`city.search`).

> Wide event: city search. One `city.search` event per search, logged once in a `finally`: query_length, result_count, stale_discarded, success, error.type, duration_ms. It replaces the separate start, result and stale-response logs you would otherwise write for this method.

### 1.10 Wide event: home load
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:55`
- **One event per:** whole flow (`home.load`).

> Wide event: home load. One `home.load` event for the whole flow, logged once in a `finally`: default_cities, saved_cities, cities_loaded, cities_failed, duration_ms. getCurrentWeather() runs one fetch per city, so this event summarises many of the step 1.8 events.

---

## Lab 2: Metrics

Pick the type from the question: "how many" is a counter, "how long" is a timing, "what is it now" is a gauge. Keep tags low-cardinality (`source`, `method`, `status_class`), never an id.

### 2.1 Request counter (network)
- **File:** `lib/core/interceptors/telemetry_interceptor.dart:29`
- **Metric:** `http.client.requests` by `method` and `status_class` (counter)

> Derive instead of hand-writing: record `http.client.requests` (counter, tags method and status_class such as 2xx, 4xx, 5xx, or `error` when no response came back) here in onResponse and onError. One place gives you the request rate and the error rate for every call.

### 2.2 Fetch duration (data)
- **File:** `lib/features/weather/data/repositories/weather_repo.dart:40`
- **Metric:** `weather.fetch.duration` tagged with `source` (timing)

> Timing, duration (the D in RED): `weather.fetch.duration` for the whole call, tagged with the source (remote or cache). Reuse the Stopwatch from step 1.8 if you did it. Run with FAULT_RETRY=true and find the p95 spike: it only shows once timings are split by source.

### 2.3 Cache hits and misses (storage)
- **File:** `lib/features/weather/data/datasources/weather_local_source.dart:33`
- **Metric:** `cache.hit` / `cache.miss` by `cache` (two counters)

> Counters, cache: `cache.hit` or `cache.miss` with a `cache` tag (weather, forecast, air_quality), here and in the two other cached reads. Record two counters, not a ratio: the dashboard divides them.

### 2.4 Saved cities (home screen)
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:62`
- **Metric:** `cities.saved` (gauge)

> Gauges, current level: `cities.saved` (saved cities loaded) once they are read. A gauge is a level that can go down; a counter cannot.

### 2.5 Stale search responses (add-city screen)
- **File:** `lib/features/weather/presentation/add_city_view/add_city_viewmodel.dart:46`
- **Metric:** `city.search.stale_discarded` (counter)

> Search metrics: counter `city.search.stale_discarded` for responses dropped because the user kept typing. Nothing else shows how often this silent drop happens.

---

## Lab 3: Traces

Start with 3.1: every later span hangs off the request spans. A span that is never ended is never exported, so the waterfall shows a gap.

### 3.1 One span per request (network)
- **File:** `lib/services/api/api_service.dart:29`
- **You should see:** one span per HTTP request.

> One span per request: add TelemetryInterceptor(locator<Telemetry>()) here (and import it). Do this first; every later step hangs its spans off these.

### 3.2 Home load waterfall (home screen)
- **File:** `lib/features/weather/presentation/home_view/home_viewmodel.dart:10`
- **You should see:** one view model span, one parallel request span per city.

> Home load waterfall: extend ObservedViewModel instead of BaseViewModel and wrap the work in getCurrentWeather() with `observe(() async { ... })`, keeping the try/catch outside it. You should see one view model span with one request span per city as its parallel children.

### 3.3 Details waterfall (details screen)
- **File:** `lib/features/weather/presentation/weather_details_view/weather_details_viewmodel.dart:11`
- **You should see:** with `SILENT_DUPLICATE_REQUEST=true`, two sibling request spans; with `FAULT_FAIL_RATE=100`, `error.type` on the span.

> Details waterfall: extend ObservedViewModel and wrap the work in fetchForecast() with `observe(() async { ... })`, keeping the try/catch OUTSIDE observe() so a failure reaches the span. Run with SILENT_DUPLICATE_REQUEST=true (two sibling request spans) and FAULT_FAIL_RATE=100 (error.type on the span).

### 3.4 Child span in the repo (data)
- **File:** `lib/features/weather/data/repositories/weather_repo.dart:94`
- **You should see:** a child span showing where the time goes inside the fetch.

> Child span in the repo: wrap the remote call in `traced(...)` so the waterfall shows where the time goes inside the fetch, not just that it was slow.

### 3.5 Storage span (storage)
- **File:** `lib/features/weather/data/datasources/weather_local_source.dart:98`
- **You should see:** local storage as its own bar.

> Storage span: wrap this read in `traced(...)`. Not every slow step is the network; local storage shows up as its own bar.
