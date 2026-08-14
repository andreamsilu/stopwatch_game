# Demo admin dashboard

The Flutter web application exposes a temporary administration dashboard at:

```text
/admin
```

The dashboard currently uses static sample data. It is deliberately labelled
**Demo mode** and must not be treated as an operational reporting source.

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
