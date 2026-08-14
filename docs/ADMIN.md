# Demo admin dashboard

The Flutter web application exposes a temporary administration dashboard at:

```text
/admin
```

The dashboard currently uses static sample data. It is deliberately labelled
**Demo mode** and must not be treated as an operational reporting source.

Temporary client-side login:

```text
Email: admin@greentelecom.co.tz
Password: admin123
```

The logout button is available in the admin header. These credentials are
embedded dummy values and do not provide production security.

The application keeps a sanitized, in-memory session trace for development,
but it is not shown as a separate admin module. Administrators use the single
**Play Evidence** register for access, charge, SMS MO, and game dispute records.
The developer trace is not a replacement for server-side audit logging.

The **Play Evidence** page contains dummy dispute records showing the intended
server-side chain: portal access, authenticated user, confirmed payment-provider
transaction, game-session allocation, round start, round stop, and outcome.

Create an evidence envelope immediately for every user who reaches the portal's
play experience, before requesting payment. Assign a stable `portalSessionId`
and propagate it through `portal.session_started`, `game.play_opened`, billing,
game allocation, start, stop, and completion records. Keep access-only and
abandoned attempts in the register as `ACCESSED`; absence of a charge or game
must remain visible rather than causing the evidence record to disappear.

For the SMS channel, the primary user-action evidence is the Mobile Originated
(MO) message received by the SMSC/SMS gateway. Preserve the gateway's unique MO
message ID, masked MSISDN, destination short code, received-at timestamp, channel,
accepted command (or a canonical payload hash), gateway status, and correlation
ID. The MO proves that the subscriber-originated message reached the gateway; it
must still be linked to server acceptance, a confirmed charge, and a game result
to prove the complete charged-and-played chain.

## Charge-to-play evidence requirements

Client telemetry is supporting context only and must never be treated as proof
that money moved or that a game was played. Production evidence must correlate:

- A gateway access record with `requestId`, authenticated `userId`, masked
  MSISDN, UTC timestamp, route, result, and privacy-safe device/network context.
- For SMS, the authoritative MO receipt with `gatewayMessageId`, masked MSISDN,
  short code, UTC receipt time, accepted command/payload hash, and correlation ID.
- The payment provider's successful callback with unique `providerTxnId`,
  internal billing `requestId`, amount, currency, provider status, and callback
  receipt time. A submitted billing request is not proof of a charge.
- A server-created `sessionRef` linked directly to the successful transaction.
- Server-accepted game start and stop records with `sessionRef`, `roundId`, UTC
  timestamps, sequence numbers, final duration, and result.
- Append-only audit events with unique event IDs, actor/source, correlation IDs,
  canonical payload hashes, and preferably a chained hash or signed archive.

The backend should enforce a channel-aware state machine such as
`MO_RECEIVED -> COMMAND_ACCEPTED -> CHARGE_CONFIRMED -> GAME_ALLOCATED -> COMPLETED`
for SMS, or
`ACCESSED -> AUTHENTICATED -> CHARGE_CONFIRMED -> GAME_ALLOCATED -> STARTED -> COMPLETED`
for the portal.
If a charge is confirmed but no game session can be allocated, record the case
as `REFUND_DUE` and process an idempotent reversal. Never label that case as
played. Store timestamps in UTC and define retention and restricted-access
policies with the legal/compliance owner.

## Local access

Run the web application and append `/admin` to the displayed origin.

```powershell
flutter run -d web-server --web-port 8080
```

## Hosting requirement

Clean Flutter paths require the web server to return `index.html` for routes
that are not physical files. For example, an Nginx deployment needs a fallback
equivalent to:

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

Without an SPA fallback, opening `/admin` directly after deployment can return
the hosting server's 404 page even though in-app navigation works.

## Before production

- Require backend-authenticated admin accounts.
- Enforce an admin role on both the route and every administration endpoint.
- Replace `_AdminDemoData` with API-backed providers.
- Record every administrative read and mutation in an append-only audit log.
- Never expose OTPs, access tokens, secrets, full MSISDNs, or payment credentials.
