# Stopwatch Challenge — API Documentation

This document describes the HTTP API contract required by the **Stopwatch Challenge** Flutter client (`stopwatch_game`). The mobile/web app currently uses local stubs for auth and round scoring; backend implementations should follow this spec so the client can replace its `TODO` integration points without changing game UX.

---

## Table of contents

1. [Overview](#overview)
2. [Conventions](#conventions)
3. [Users](#users)
4. [Game rounds](#game-rounds)
5. [Interaction telemetry](#interaction-telemetry)
6. [Data models](#data-models)
7. [Client integration flow](#client-integration-flow)
8. [Errors](#errors)
9. [Security & integrity](#security--integrity)
10. [Client integration status](#client-integration-status)

---

## Overview

**Stopwatch Challenge** is a precision timing game: the player must start a stopwatch and stop as close as possible to a **target time**. Outcomes, prizes, and target assignment must be **authoritative on the server**—the client only displays results returned by the API and collects anti-automation telemetry.

| Concern | Owner |
|--------|--------|
| Win/lose decision, prize coins, tolerance | **Server** |
| Stopwatch UI, pointer samples, session metrics | **Client** |
| User registration (`msisdn`, `username`) | **Server** |

**Base URL (configured backend):**

```
http://188.64.189.38:9090
```

| Environment | Base URL |
|-------------|----------|
| **Current (development)** | `http://188.64.189.38:9090` |

All endpoints below are relative to this base URL. Example — register user:

```
POST http://188.64.189.38:9090/api/v1/users
```

> **Note:** This host uses plain HTTP. Use HTTPS with a proper domain before production release.

---

## Conventions

### Versioning

- URL prefix: `/api/v1`
- Breaking changes require a new major version (`/api/v2`).

### Request headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes (JSON bodies) | `application/json` |
| `Authorization` | TBD (game endpoints) | `Bearer <access_token>` — not returned by `POST /api/v1/users` today |
| `Accept` | Recommended | `application/json` |
| `X-Client-Version` | Recommended | App version, e.g. `1.0.0+1` |
| `X-Platform` | Recommended | `web`, `android`, `ios`, `windows`, `linux`, `macos` |
| `X-Request-Id` | Optional | Client-generated UUID for tracing |

### Time formats

- **Durations in JSON:** integer milliseconds unless noted.
- **Timestamps:** ISO-8601 UTC strings, e.g. `2026-05-18T14:32:01.123Z`.
- **Display labels** (e.g. `finalTimeLabel`): `MM:SS.mmm` — produced by the server for consistency.

### Idempotency

`POST` endpoints that finalize state (`/stop`, prize grant) should accept:

| Header | Description |
|--------|-------------|
| `Idempotency-Key` | Unique per user action; repeat requests return the same response without double-awarding prizes |

---

## Users

Registers or upserts a player before entering the game. This is the **live** backend endpoint confirmed against `http://188.64.189.38:9090`.

**Client references:** `LoginNotifier.submitLogin` (map phone → `msisdn`, add `username` + `channelSource`)

### Create / register user

```http
POST /api/v1/users
```

**Headers**

| Header | Value |
|--------|--------|
| `accept` | `application/json` |
| `Content-Type` | `application/json` |

**Request body**

```json
{
  "msisdn": "255676589824",
  "channelSource": "WEB",
  "username": "KIBABU"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `msisdn` | string | Yes | Mobile number (digits, country code included — e.g. Tanzania `255…`) |
| `channelSource` | string | Yes | Client channel; e.g. `WEB` for Flutter web builds |
| `username` | string | Yes | Display / account name chosen by the player |

**cURL example**

```bash
curl -X 'POST' \
  'http://188.64.189.38:9090/api/v1/users' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "msisdn": "255676589824",
  "channelSource": "WEB",
  "username": "KIBABU"
}'
```

**Success — `200 OK`**

```json
{
  "id": 2,
  "msisdn": "255676589824",
  "username": "KIBABU",
  "channelSource": "WEB",
  "status": "active",
  "createdAt": "2026-05-18T07:56:40.814919639Z",
  "updatedAt": "2026-05-18T07:56:40.814919639Z",
  "lastLoginAt": null
}
```

**Response fields**

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Server user id — persist for later game/telemetry calls |
| `msisdn` | string | Registered mobile number |
| `username` | string | Registered username |
| `channelSource` | string | Channel used at registration |
| `status` | string | Account status (e.g. `active`) |
| `createdAt` | string (ISO-8601) | Record creation time |
| `updatedAt` | string (ISO-8601) | Last update time |
| `lastLoginAt` | string \| null | Last login timestamp, or `null` on first registration |

**Response headers (observed)**

| Header | Example value |
|--------|-----------------|
| `content-type` | `application/json` |
| `cache-control` | `no-cache, no-store, max-age=0, must-revalidate` |
| `x-content-type-options` | `nosniff` |
| `x-frame-options` | `DENY` |

**Client mapping notes**

| App field | API field |
|-----------|-----------|
| Login phone input | `msisdn` |
| Platform | `channelSource` — use `WEB` on web; map `android` / `ios` / desktop when known |
| *(not in UI yet)* | `username` — add a field on login or derive a default until UX is defined |

> **Note:** This response does **not** include a bearer token. Store `id` (and profile fields) locally after a successful call. Document additional auth headers here once session/JWT endpoints are confirmed in Swagger.

> **Client status:** `LoginNotifier.submitLogin` still bypasses the API. Wire it to `POST /api/v1/users` before production.

### Suggested `channelSource` values

| Client platform | Suggested value |
|-----------------|-----------------|
| Flutter web | `WEB` |
| Android | `ANDROID` *(confirm with backend)* |
| iOS | `IOS` *(confirm with backend)* |
| Windows / Linux / macOS | `DESKTOP` *(confirm with backend)* |

---

## Game rounds

Round lifecycle maps to `GameController` methods:

| Client method | Intended API call |
|---------------|-------------------|
| `openRoundBoard()` | Create round (target time) |
| `startGame()` | Start round |
| `stopGame()` + `fetchRoundResultFromBackend()` | Stop round & get result |

### Game rules (server-enforced)

These values mirror the current client stub in `fetchRoundResultFromBackend` and should be configurable server-side:

| Rule | Value |
|------|--------|
| Target time range | **3 000–12 000 ms**, snapped to **10 ms** steps |
| Win tolerance | **±100 ms** from target |
| Perfect-stop prize | **100 coins** (`Perfect Stop Reward`) |
| Outcome labels | `WIN` or `LOSE` |

The server must **not** trust client-reported elapsed time alone; record authoritative start/stop timestamps server-side when `start` and `stop` are called.

---

### Create round

Issues a new round with server-generated target time and interaction session id.

```http
POST /api/v1/game/rounds
```

**Request body**

```json
{
  "interactionSessionId": "1716035520123456-48291"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `interactionSessionId` | string | No | Client session id; server may echo or replace |

**Success — `201 Created`**

```json
{
  "roundId": "rnd_01HXYZ",
  "targetTimeMs": 8200,
  "targetTimeLabel": "00:08.200",
  "interactionSessionId": "1716035520123456-48291",
  "status": "ready"
}
```

**Client mapping:** call when opening the play board (`openRoundBoard` / reset).

---

### Start round

Marks the round as running and records server start time.

```http
POST /api/v1/game/rounds/{roundId}/start
```

**Path parameters**

| Name | Description |
|------|-------------|
| `roundId` | Round from create response |

**Request body**

```json
{
  "interactionSessionId": "1716035520123456-48291",
  "clientStartedAt": "2026-05-18T14:32:01.123Z"
}
```

**Success — `200 OK`**

```json
{
  "roundId": "rnd_01HXYZ",
  "status": "running",
  "serverStartedAt": "2026-05-18T14:32:01.145Z"
}
```

**Errors:** `404` (unknown round), `409` (round not in `ready` state)

**Client mapping:** `GameController.startGame()` — invoked when the user presses **Start**.

---

### Stop round & get result

Ends the round and returns the authoritative outcome. This replaces local `fetchRoundResultFromBackend`.

```http
POST /api/v1/game/rounds/{roundId}/stop
```

**Request body**

```json
{
  "interactionSessionId": "1716035520123456-48291",
  "clientStoppedAt": "2026-05-18T14:32:09.367Z",
  "clientElapsedMs": 8222
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `clientStoppedAt` | string (ISO-8601) | Recommended | For audit only |
| `clientElapsedMs` | integer | Recommended | For audit only; **do not** use as sole source of truth |

**Success — `200 OK`**

```json
{
  "roundId": "rnd_01HXYZ",
  "status": "completed",
  "outcomeLabel": "WIN",
  "deltaLabel": "Great timing! Within +/-100 ms. Prize unlocked!",
  "finalTimeLabel": "00:08.222",
  "differenceMs": 22,
  "prizeLabel": "Perfect Stop Reward",
  "prizeCoins": 100,
  "isPrizeAwarded": true,
  "serverElapsedMs": 8222,
  "targetTimeMs": 8200
}
```

**LOSE example**

```json
{
  "roundId": "rnd_01HXYZ",
  "status": "completed",
  "outcomeLabel": "LOSE",
  "deltaLabel": "Late by 250 ms",
  "finalTimeLabel": "00:08.450",
  "differenceMs": 250,
  "prizeLabel": "No prize",
  "prizeCoins": 0,
  "isPrizeAwarded": false,
  "serverElapsedMs": 8450,
  "targetTimeMs": 8200
}
```

**Response field notes**

| Field | Maps to client `RoundResultData` |
|-------|----------------------------------|
| `outcomeLabel` | `outcomeLabel` |
| `deltaLabel` | `deltaLabel` |
| `finalTimeLabel` | `finalTimeLabel` |
| `differenceMs` | `differenceMs` (signed: negative = early, positive = late) |
| `prizeLabel` | `prizeLabel` |
| `prizeCoins` | `prizeCoins` |
| `isPrizeAwarded` | `isPrizeAwarded` |

**Errors:** `404`, `409` (not running), `422` (invalid stop)

**Client mapping:** `GameController.stopGame()` then map response to `RoundResultData`.

---

### Round history (optional)

The client keeps history in memory today. For cross-device history, provide:

```http
GET /api/v1/game/rounds?limit=20&cursor=<opaque>
```

**Success — `200 OK`**

```json
{
  "items": [
    {
      "roundId": "rnd_01HXYZ",
      "completedAt": "2026-05-18T14:32:09.367Z",
      "finalTimeLabel": "00:08.222",
      "outcomeLabel": "WIN"
    }
  ],
  "nextCursor": null
}
```

---

### Player stats (optional)

Aggregates shown on the play screen (`totalWins`, `totalPrizeCoins`) are client-local today.

```http
GET /api/v1/game/stats
```

**Success — `200 OK`**

```json
{
  "totalWins": 12,
  "totalPrizeCoins": 1200
}
```

---

## Interaction telemetry

Anti-automation metrics collected per round from pointer events. Submitted **after** the round stops, in parallel with displaying the result.

**Client reference:** `InteractionTelemetryService.submitRoundPayload`

```http
POST /api/v1/game/interaction-telemetry
```

**Request body**

```json
{
  "reactionTime": 342,
  "movementEntropy": 2.41,
  "clickVariance": 18.6,
  "interactionConsistency": 0.87,
  "sessionId": "1716035520123456-48291",
  "timestamp": "2026-05-18T14:32:09.400Z",
  "isTrusted": true,
  "roundId": "rnd_01HXYZ"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `reactionTime` | integer | Milliseconds from UI ready to first pointer down (0–60000) |
| `movementEntropy` | number | Shannon entropy (base 2) of movement direction bins; `0` if insufficient samples |
| `clickVariance` | number | Variance of down/up pointer distances per click pair |
| `interactionConsistency` | number | `0.0`–`1.0`; higher = more stable interaction patterns across recent rounds |
| `sessionId` | string | Client interaction session id |
| `timestamp` | string | ISO-8601 when payload was built |
| `isTrusted` | boolean \| null | On **web**, reflects `PointerEvent.isTrusted`; `null` on native platforms |
| `roundId` | string | Recommended — link telemetry to server round |

**Success — `202 Accepted`**

```json
{
  "received": true
}
```

Empty payloads are not sent by the client (`if (payload.isEmpty) return`).

**Server guidance:** use telemetry for fraud scoring; do not block prize payout solely on client metrics without additional signals.

---

## Data models

### `User` (server — `POST /api/v1/users` response)

| Property | Type | Example |
|----------|------|---------|
| `id` | integer | `2` |
| `msisdn` | string | `255676589824` |
| `username` | string | `KIBABU` |
| `channelSource` | string | `WEB` |
| `status` | string | `active` |
| `createdAt` | string | `2026-05-18T07:56:40.814919639Z` |
| `updatedAt` | string | `2026-05-18T07:56:40.814919639Z` |
| `lastLoginAt` | string \| null | `null` |

### `RoundResultData` (client)

| Property | Type | Example |
|----------|------|---------|
| `outcomeLabel` | string | `WIN`, `LOSE` |
| `deltaLabel` | string | Human-readable timing message |
| `finalTimeLabel` | string | `00:08.222` |
| `differenceMs` | int | Signed delta vs target |
| `prizeLabel` | string | `Perfect Stop Reward`, `No prize` |
| `prizeCoins` | int | `100` or `0` |
| `isPrizeAwarded` | bool | `true` when `prizeCoins > 0` |

### `HistoryEntry` (client, optional sync)

| Property | Type |
|----------|------|
| `timestamp` | datetime |
| `timeLabel` | string (`finalTimeLabel`) |
| `outcome` | string (`WIN` / `LOSE`) |

### Interaction payload (client-built)

Built in `GameController._buildInteractionPayload()`:

```json
{
  "reactionTime": 0,
  "movementEntropy": 0.0,
  "clickVariance": 0.0,
  "interactionConsistency": 1.0,
  "sessionId": "string",
  "timestamp": "ISO-8601",
  "isTrusted": true
}
```

---

## Client integration flow

```mermaid
sequenceDiagram
    participant User
    participant App as Flutter App
    participant API as Backend API

    User->>App: Enter msisdn, username & continue
    App->>API: POST /api/v1/users
    API-->>App: User (id, msisdn, status, …)

    User->>App: Open play / new round
    App->>API: POST /game/rounds
    API-->>App: roundId, targetTimeMs

    User->>App: Press Start
    App->>API: POST /game/rounds/{id}/start
    Note over App: Local stopwatch ticks (10ms)

    User->>App: Press Stop
    App->>API: POST /game/rounds/{id}/stop
    API-->>App: RoundResultData fields
    App->>API: POST /game/interaction-telemetry
    App-->>User: Result dialog (WIN / LOSE)
```

---

## Errors

Use a consistent error envelope:

```json
{
  "error": {
    "code": "ROUND_NOT_RUNNING",
    "message": "Round rnd_01HXYZ is not in running state.",
    "requestId": "req_abc123"
  }
}
```

| HTTP status | Typical use |
|-------------|-------------|
| `400` | Validation failure |
| `401` | Missing or invalid token |
| `403` | Forbidden / account suspended |
| `404` | Round or resource not found |
| `409` | Invalid state transition |
| `422` | Semantic error (e.g. stop before start) |
| `429` | Rate limit (OTP, round creation) |
| `500` | Internal error |

The client should surface `message` to users for auth failures; game errors may use generic copy while logging `requestId`.

---

## Security & integrity

1. **Server-owned outcomes** — Win/lose and prizes must be computed from server timestamps, not client stopwatch alone.
2. **User identity** — Persist `User.id` from `POST /api/v1/users` for downstream game calls. Add `Authorization` headers here once session/JWT endpoints are documented.
3. **Rate limits** — Apply per-IP and per-user limits on OTP, round creation, and stop.
4. **Telemetry** — Treat `isTrusted: false` on web as a risk signal (synthetic events).
5. **HTTPS only** in production.
6. **Prize idempotency** — Use `Idempotency-Key` on `/stop` to prevent duplicate coin grants on retries.

---

## Client integration status

| Area | Status | Source file |
|------|--------|-------------|
| Register user `POST /api/v1/users` | **Documented (live)** — not wired in app | `lib/features/auth/presentation/bloc/login_notifier.dart` |
| Login / continue | Bypassed (always succeeds) | `login_notifier.dart` |
| Start round | Placeholder | `lib/features/game/presentation/bloc/game_notifier.dart` |
| Stop round | Placeholder | `game_notifier.dart` |
| Round result | Local stub (±100 ms rule) | `fetchRoundResultFromBackend` |
| Interaction telemetry | No HTTP call | `lib/core/services/interaction_telemetry_service.dart` |

When implementing the client, replace the `TODO` blocks in those files with calls matching this document.

---

## Changelog

| Version | Date | Notes |
|---------|------|-------|
| 1.2 | 2026-05-18 | Document live `POST /api/v1/users` (msisdn, channelSource, username) |
| 1.1 | 2026-05-18 | Set base URL to `http://188.64.189.38:9090` |
| 1.0 | 2026-05-18 | Initial contract derived from `stopwatch_game` v1.0.0+1 |
