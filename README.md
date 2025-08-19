# Roblox Emote AnimationId Finder

Dark-themed web app to resolve an emote's AnimationId by fetching Asset Delivery v2 and scanning the CDN asset for numeric IDs (6+ digits).

Important: This app requires a valid .ROBLOSECURITY for Asset Delivery v2. Do NOT expose this cookie in client-side code. Supply it to the server via environment variable or an HTTP header in a trusted environment.

## Setup

1. Create `.env` from the example and set your .ROBLOSECURITY:

```bash
cp .env.example .env
```

Edit `.env`:

```
ROBLOSECURITY=your_cookie_here
PORT=3000
```

2. Install dependencies:

```bash
npm install
```

3. Run the server:

```bash
npm run dev
```

Open `http://localhost:3000`.

## API

POST `/api/resolve`

Body:

```
{ "catalogUrl": "https://www.roblox.com/catalog/123456789/Some", "assetId": "123456789" }
```

Headers (optional):

```
X-Roblox-Security: <cookie value>
```

Response:

```
{ inputId, animationIdCandidate, allNumericMatches, cdnLocationsTried }
```

Notes:
- The server extracts the first 6+ digit number from the provided URL if `assetId` is not supplied.
- The CDN asset is fetched and scanned for 6+ digit numbers; the first is returned as `animationIdCandidate`.
- Authentication is required by Asset Delivery and must be provided server-side.

