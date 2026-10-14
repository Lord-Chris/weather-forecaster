# Observability workshop

The app talks only to a small telemetry layer in [lib/core/telemetry/](lib/core/telemetry/). The layer sends data to a `TelemetryExporter`. Today that is `ConsoleExporter`. To move to Sentry, Grafana or anything else, write one new exporter class; nothing else changes.

## Run

```sh
flutter run --dart-define=ATTENDEE=<your-name> --dart-define=OPEN_WEATHER_KEY=...
```

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

1. **Logs.** Use the injected `ITelemetry` (`locator<ITelemetry>()`): `telemetry.log(level, message, fields)`. Keep the existing `_log.e` calls and add a telemetry call next to each. Replace every `debugPrint` with a structured log that has named fields.
2. **Metrics.** In `WeatherRepo`, add a `weather.fetch.attempts` counter and a `weather.fetch.duration` timing. Stretch: cache-hit ratio, per-city timing.
3. **Traces.** Add `TelemetryInterceptor` in `ApiService`, make the view models extend `ObservedViewModel` and wrap their work in `observe(...)`. One tap on a city card should give one connected waterfall: view model, request (screen spans are separate).
4. **Migrating an existing code base (partial).** Instrument without touching every call site: forward existing `package:logger` output to telemetry with a `LogOutput`, and carry the trace with a `Zone` so no span is passed by hand. Metrics approach to be decided.

Outside Lab 1, `ITelemetry` is injected everywhere (registered in the locator), so tests can swap in `InMemoryExporter`.

## Branches

`workshop/main` is the starter. Solution branches fork from it. `main` is not used.
