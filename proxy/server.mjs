import http from 'node:http';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(here, '.env');

if (fs.existsSync(envPath)) {
  for (const line of fs.readFileSync(envPath, 'utf8').split(/\r?\n/)) {
    const match = line.match(/^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$/);
    if (match && !process.env[match[1]]) {
      process.env[match[1]] = match[2].replace(/^['"]|['"]$/g, '');
    }
  }
}

const port = Number(process.env.PORT || 8787);
const upstreamOrigin = 'https://rajaongkir.komerce.id';
const geocodeCache = new Map();

function addCorsHeaders(response) {
  response.setHeader('Access-Control-Allow-Origin', '*');
  response.setHeader('Access-Control-Allow-Headers', 'Content-Type, key');
  response.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
}

function readBody(request) {
  return new Promise((resolve, reject) => {
    const chunks = [];
    request.on('data', (chunk) => chunks.push(chunk));
    request.on('end', () => resolve(Buffer.concat(chunks)));
    request.on('error', reject);
  });
}

async function fetchJson(url, options = {}) {
  const upstreamResponse = await fetch(url, options);
  const body = await upstreamResponse.text();
  let payload;
  try {
    payload = JSON.parse(body);
  } catch (_) {
    throw new Error(`Response peta tidak valid (${upstreamResponse.status}).`);
  }
  if (!upstreamResponse.ok) {
    throw new Error(payload.message || `Layanan peta menolak request (${upstreamResponse.status}).`);
  }
  return payload;
}

async function geocodePlace(query) {
  const cached = geocodeCache.get(query);
  if (cached) return cached;
  const geocodeUrl = new URL('https://nominatim.openstreetmap.org/search');
  geocodeUrl.searchParams.set('format', 'jsonv2');
  geocodeUrl.searchParams.set('limit', '1');
  geocodeUrl.searchParams.set('countrycodes', 'id');
  geocodeUrl.searchParams.set('q', `${query}, Indonesia`);
  const results = await fetchJson(geocodeUrl, {
    headers: { 'User-Agent': 'Ongkirin/1.0 local development' },
  });
  const place = Array.isArray(results) ? results[0] : null;
  if (!place?.lat || !place?.lon) {
    throw new Error(`Lokasi tidak ditemukan: ${query}`);
  }
  const placeResult = {
    label: place.display_name || query,
    latitude: Number(place.lat),
    longitude: Number(place.lon),
  };
  geocodeCache.set(query, placeResult);
  return placeResult;
}

const server = http.createServer(async (request, response) => {
  addCorsHeaders(response);

  if (request.method === 'OPTIONS') {
    response.writeHead(204);
    response.end();
    return;
  }

  const requestUrl = new URL(request.url, `http://${request.headers.host}`);
  if (requestUrl.pathname === '/geocode/reverse') {
    const latitude = requestUrl.searchParams.get('lat');
    const longitude = requestUrl.searchParams.get('lon');
    if (!latitude || !longitude) {
      response.writeHead(400, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ message: 'Koordinat lokasi belum lengkap.' }));
      return;
    }
    try {
      const geocodeUrl = new URL('https://nominatim.openstreetmap.org/reverse');
      geocodeUrl.searchParams.set('format', 'jsonv2');
      geocodeUrl.searchParams.set('addressdetails', '1');
      geocodeUrl.searchParams.set('zoom', '18');
      geocodeUrl.searchParams.set('lat', latitude);
      geocodeUrl.searchParams.set('lon', longitude);
      const geocodeResponse = await fetch(geocodeUrl, {
        headers: { 'User-Agent': 'Ongkirin/1.0 local development' },
      });
      const geocodeBody = await geocodeResponse.arrayBuffer();
      response.writeHead(geocodeResponse.status, {
        'Content-Type': geocodeResponse.headers.get('content-type') || 'application/json',
      });
      response.end(Buffer.from(geocodeBody));
    } catch (error) {
      response.writeHead(502, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ message: `Reverse geocoding gagal: ${error.message}` }));
    }
    return;
  }

  if (requestUrl.pathname === '/maps/route') {
    const originQuery = requestUrl.searchParams.get('origin')?.trim();
    const destinationQuery = requestUrl.searchParams.get('destination')?.trim();
    if (!originQuery || !destinationQuery) {
      response.writeHead(400, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ message: 'Asal dan tujuan rute belum lengkap.' }));
      return;
    }
    try {
      const origin = await geocodePlace(originQuery);
      const destination = await geocodePlace(destinationQuery);
      const routeUrl = new URL(
        `https://router.project-osrm.org/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}`,
      );
      routeUrl.searchParams.set('overview', 'full');
      routeUrl.searchParams.set('geometries', 'geojson');
      routeUrl.searchParams.set('steps', 'false');
      const routePayload = await fetchJson(routeUrl, {
        headers: { 'User-Agent': 'Ongkirin/1.0 local development' },
      });
      const route = routePayload.routes?.[0];
      if (!route?.geometry) throw new Error('Rute jalan tidak ditemukan.');
      response.writeHead(200, { 'Content-Type': 'application/json' });
      response.end(
        JSON.stringify({
          origin,
          destination,
          route: {
            distanceMeters: route.distance,
            durationSeconds: route.duration,
            geometry: route.geometry,
          },
        }),
      );
    } catch (error) {
      response.writeHead(502, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ message: `Rute peta gagal: ${error.message}` }));
    }
    return;
  }

  if (!requestUrl.pathname.startsWith('/api/v1/')) {
    response.writeHead(404, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ message: 'Proxy endpoint tidak ditemukan.' }));
    return;
  }

  try {
    if (!process.env.RAJAONGKIR_API_KEY) {
      response.writeHead(500, { 'Content-Type': 'application/json' });
      response.end(JSON.stringify({ message: 'RAJAONGKIR_API_KEY belum diatur di proxy/.env.' }));
      return;
    }
    const body = await readBody(request);
    const upstreamUrl = `${upstreamOrigin}${requestUrl.pathname}${requestUrl.search}`;
    const headers = {
      key: process.env.RAJAONGKIR_API_KEY,
    };
    if (request.headers['content-type']) {
      headers['Content-Type'] = request.headers['content-type'];
    }

    const upstreamResponse = await fetch(upstreamUrl, {
      method: request.method,
      headers,
      body: request.method === 'GET' ? undefined : body,
    });
    const upstreamBody = await upstreamResponse.arrayBuffer();
    response.writeHead(upstreamResponse.status, {
      'Content-Type': upstreamResponse.headers.get('content-type') || 'application/json',
    });
    response.end(Buffer.from(upstreamBody));
  } catch (error) {
    response.writeHead(502, { 'Content-Type': 'application/json' });
    response.end(JSON.stringify({ message: `Proxy gagal menghubungi RajaOngkir: ${error.message}` }));
  }
});

server.listen(port, '0.0.0.0', () => {
  console.log(`RajaOngkir proxy aktif di http://0.0.0.0:${port}`);
  if (!process.env.RAJAONGKIR_API_KEY) {
    console.log('RAJAONGKIR_API_KEY belum ada di proxy/.env. Request API akan ditolak.');
  }
});
