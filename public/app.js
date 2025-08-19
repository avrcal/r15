const $ = (sel) => document.querySelector(sel);

async function resolveId() {
  const status = $('#status');
  const result = $('#result');
  const resInputId = $('#resInputId');
  const resCandidate = $('#resCandidate');
  const resAll = $('#resAll');
  const input = $('#catalogUrl').value.trim();
  const assetIdOverride = $('#assetId').value.trim();
  const xRobloxSecurity = $('#xRobloxSecurity').value.trim();

  status.textContent = 'Resolving…';
  result.classList.add('hidden');

  try {
    const payload = {};
    if (input) payload.catalogUrl = input;
    if (assetIdOverride) payload.assetId = assetIdOverride;
    const headers = { 'Content-Type': 'application/json' };
    if (xRobloxSecurity) headers['X-Roblox-Security'] = xRobloxSecurity;

    const resp = await fetch('/api/resolve', {
      method: 'POST',
      headers,
      body: JSON.stringify(payload)
    });
    const data = await resp.json();
    if (!resp.ok) {
      status.textContent = data && data.error ? data.error : 'Failed to resolve';
      return;
    }
    resInputId.textContent = data.inputId || '—';
    resCandidate.textContent = data.animationIdCandidate || '—';
    resAll.textContent = (data.allNumericMatches && data.allNumericMatches.length)
      ? data.allNumericMatches.join(', ')
      : '—';
    result.classList.remove('hidden');
    status.textContent = 'Done';
  } catch (err) {
    status.textContent = err.message || String(err);
  }
}

$('#resolveBtn').addEventListener('click', resolveId);
$('#catalogUrl').addEventListener('keydown', (e) => { if (e.key === 'Enter') resolveId(); });

