/*
Dark-themed web app backend for resolving Roblox emote AnimationId.

Security notes:
- Never store or log the .ROBLOSECURITY value. Read from env (ROBLOSECURITY) or allow explicit per-request header X-Roblox-Security if needed.
- Server-side only; browsers cannot safely send .ROBLOSECURITY to Roblox. The backend proxies requests to Asset Delivery v2.

Behavior:
- POST /api/resolve with { catalogUrl?: string, assetId?: string } and optional header X-Roblox-Security (discouraged; prefer env).
- Extract the numeric ID: from catalog URL query or path; or accept assetId directly.
- Call Asset Delivery v2 for that ID using .ROBLOSECURITY cookie.
- Follow returned CDN locations and fetch the asset file.
- Scan the asset content for numeric tokens with 6+ digits; return first/best candidate as animationIdCandidate plus all matches.
*/

const express = require('express');
const axios = require('axios');
const cors = require('cors');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json({ limit: '1mb' }));
app.use(express.static(path.join(__dirname, 'public')));

function extractFirstNumericIdFromUrl(input) {
  if (!input) return null;
  try {
    const url = new URL(input);
    const pathname = url.pathname || '';
    const search = url.search || '';
    const combined = `${pathname} ${search}`;
    const matches = combined.match(/\d{6,}/g);
    if (matches && matches.length > 0) {
      return matches[0];
    }
  } catch {
    // Not a valid URL; fallback to extracting digits directly
    const matches = String(input).match(/\d{6,}/g);
    if (matches && matches.length > 0) {
      return matches[0];
    }
  }
  return null;
}

function extractAllIdsFromText(text) {
  const matches = String(text).match(/\d{6,}/g);
  if (!matches) return [];
  // de-duplicate while preserving order
  const seen = new Set();
  const result = [];
  for (const m of matches) {
    if (!seen.has(m)) {
      seen.add(m);
      result.push(m);
    }
  }
  return result;
}

async function fetchAssetDeliveryInfo(assetId, roblosecurity) {
  const url = `https://assetdelivery.roblox.com/v2/assetId/${assetId}`;
  const headers = {
    'User-Agent': 'roblox-emote-animationid-finder/1.0',
    'Accept': 'application/json'
  };
  if (roblosecurity) {
    headers['Cookie'] = `.ROBLOSECURITY=${roblosecurity}`;
  }
  const response = await axios.get(url, {
    headers,
    validateStatus: () => true
  });
  if (response.status === 429) {
    throw new Error('Rate limited by Asset Delivery. Please try again later.');
  }
  if (response.status === 401) {
    throw new Error('Unauthorized: Asset Delivery requires a valid .ROBLOSECURITY.');
  }
  if (response.status >= 400) {
    throw new Error(`Asset Delivery error: ${response.status} ${response.statusText}`);
  }
  return response.data;
}

async function fetchFirstCdnAssetText(locations, roblosecurity) {
  if (!Array.isArray(locations) || locations.length === 0) {
    throw new Error('No CDN locations returned for this asset.');
  }
  const headers = {
    'User-Agent': 'roblox-emote-animationid-finder/1.0',
    'Accept': '*/*'
  };
  if (roblosecurity) {
    headers['Cookie'] = `.ROBLOSECURITY=${roblosecurity}`;
  }
  // Try in order until one succeeds
  for (const loc of locations) {
    const url = typeof loc === 'string' ? loc : (loc && loc.location) ? loc.location : null;
    if (!url) continue;
    const res = await axios.get(url, { headers, responseType: 'text', validateStatus: () => true });
    if (res.status >= 200 && res.status < 300 && typeof res.data === 'string') {
      return res.data;
    }
  }
  throw new Error('Failed to fetch any CDN asset content.');
}

app.post('/api/resolve', async (req, res) => {
  const { catalogUrl, assetId } = req.body || {};
  const roblosecurity = req.get('X-Roblox-Security') || process.env.ROBLOSECURITY || '';
  if (!roblosecurity) {
    return res.status(400).json({ error: 'Missing .ROBLOSECURITY. Set env ROBLOSECURITY or send X-Roblox-Security header server-side.' });
  }
  const targetId = assetId || extractFirstNumericIdFromUrl(catalogUrl);
  if (!targetId) {
    return res.status(400).json({ error: 'Could not extract an asset/catalog ID (6+ digits) from input.' });
  }
  try {
    const ad = await fetchAssetDeliveryInfo(targetId, roblosecurity);
    const locations = Array.isArray(ad.locations) ? ad.locations.map(l => (typeof l === 'string' ? l : l.location)) : [];
    const content = await fetchFirstCdnAssetText(locations, roblosecurity);
    const ids = extractAllIdsFromText(content);
    const candidate = ids.find(x => /\d{6,}/.test(x)) || null;
    return res.json({ inputId: String(targetId), animationIdCandidate: candidate, allNumericMatches: ids, cdnLocationsTried: locations.length });
  } catch (err) {
    return res.status(500).json({ error: err.message || 'Unknown error' });
  }
});

app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`Server listening on http://localhost:${PORT}`);
});

