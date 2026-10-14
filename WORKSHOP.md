# Observability workshop

The app talks only to a small telemetry layer in [lib/core/telemetry/](lib/core/telemetry/). The layer sends data to a `TelemetryExporter`. Today that is `ConsoleExporter`. To move to Sentry, Grafana or anything else, write one new exporter class; nothing else changes.

## Run

```sh
cp env.example.json env.json   # then put your OpenWeather key and name in it
flutter run --dart-define-from-file=env.json
```

`env.json` is gitignored. In VS Code, add a launch configuration with `"args": ["--dart-define-from-file=env.json"]` (`.vscode/` is gitignored in this repo).

The attendee tag is added to every log, metric and span so you can find your own data.

### Fault injection (debug builds only)

| Flag | Effect |
|---|---|
| `FAULT_LATENCY_MS=800` | delay every request |
| `FAULT_FAIL_RATE=30` | percent of requests that fail |
| `FAULT_RETRY=true` | first attempt fails, a retry follows after 1.5 s |

### Silent failures (final challenge, all off by default)

| Flag | Hidden problem | Where to see it |
|---|---|---|
| `SILENT_FALLBACK=true` | repo swallows a remote error and returns cached data | `fallback` field on a log line |
| `FAULT_RETRY=true` | latency spike only when a retry fires | long tail in `weather.fetch.duration` |
| `SILENT_DUPLICATE_REQUEST=true` | one tap sends the same forecast request twice | two sibling `http GET` spans |

## Privacy rules (enforced in the layer)

- Errors are recorded by type only, never the message.
- Attributes named `name`, `city`, `token`, `appid` or `amount` are dropped.
- URLs lose their query string (the API key lives there).
- Identifiers only where needed, such as `city_id`.

## Labs

Search for `TODO(lab-N)`.

1. **Logs.** Ten TODOs, `TODO(lab-1.1)` to `TODO(lab-1.10)`, about 70% plain logs (seven) and 30% wide events (three). Work top to bottom: the order is what to touch first. Use the injected `ITelemetry` (`locator<ITelemetry>()`) and keep the existing `_log.e` calls. Each TODO sits at one primary spot and lists the others it applies to.

   **Logs (seven)**

   | Step | What | Why this order |
   |---|---|---|
   | 1.1 | **Errors in view models.** Every catch block: `operation`, `error.type`, never the message. | Rare and the most valuable. |
   | 1.2 | **Errors at boundaries.** `ApiService` catch-all and the repo blocks that wrap errors in `FallbackAppException`, where the original type is lost. | The type disappears here if you don't log it. |
   | 1.3 | **Decisions: data source.** Which branch served the data: `source`, `offline`, `fallback`, `cache_hit`. | This is where the silent fallback shows up. |
   | 1.4 | **Decisions: silent drops.** Things the app skips without telling the user: duplicate city save, stale search response, too-short query, offline search refusal. | Invisible by design, so you only see them if you log them. |
   | 1.5 | **State and persistence.** Saved cities read and written, cache writes: `saved_count`, `cache_hit`, parse failures. | Explains stale or missing data later. |
   | 1.6 | **Lifecycle: user input.** Replace the `debugPrint`s for home search, add-city query and result tap. | Noisy. |
   | 1.7 | **Lifecycle: navigation.** Replace the `debugPrint`s for card tap, add city, details, air quality. | Noisiest, so last. |

   **Wide events (three)**

   | Step | One event per | Fields |
   |---|---|---|
   | 1.8 | **weather fetch** (`weather.fetch`, per repo call) | `operation`, `city_id`, `connected`, `source`, `fallback`, `cache_hit`, `error.type`, `duration_ms` |
   | 1.9 | **city search** (`city.search`, per user action) | `query_length`, `result_count`, `stale_discarded`, `success`, `error.type`, `duration_ms` |
   | 1.10 | **home load** (`home.load`, per flow) | `default_cities`, `saved_cities`, `cities_loaded`, `cities_failed`, `duration_ms` |

   Each event is built up in a plain map and logged once in a `finally`. The three sit at different levels (a call, a user action, a whole flow) so you can see how the same idea scales. After 1.8, delete the fetch start/done logs you wrote for 1.3: one line tells the whole story.
2. **Metrics.** In `WeatherRepo`, add a `weather.fetch.attempts` counter and a `weather.fetch.duration` timing. Stretch: cache-hit ratio, per-city timing.
3. **Traces.** Add `TelemetryInterceptor` in `ApiService`, make the view models extend `ObservedViewModel` and wrap their work in `observe(...)`. One tap on a city card should give one connected waterfall: view model, request (screen spans are separate).
4. **Migrating an existing code base (partial).** Instrument without touching every call site: forward existing `package:logger` output to telemetry with a `LogOutput`, and carry the trace with a `Zone` so no span is passed by hand. Metrics approach to be decided.

Outside Lab 1, `ITelemetry` is injected everywhere (registered in the locator), so tests can swap in `InMemoryExporter`.

## Branches

`workshop/main` is the starter. Solution branches fork from it. `main` is not used.
