const CACHE = 'monbluu-v7';
const SHELL = '/index.html';
const ASSETS = [
  '/index.html',
  '/manifest.json'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c =>
      Promise.all(ASSETS.map(url =>
        c.add(url).catch(() => { /* ignore individual failures */ })
      ))
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const url = new URL(e.request.url);

  // Let Supabase API calls go through network-only
  if (url.hostname.includes('supabase')) return;

  // For navigation requests (opening the PWA), always serve sistema.html
  if (e.request.mode === 'navigate') {
    e.respondWith(
      fetch(e.request)
        .then(resp => {
          if (resp && resp.ok) {
            caches.open(CACHE).then(c => c.put(e.request, resp.clone()));
            return resp;
          }
          // Network returned error — serve cached shell
          return caches.match(SHELL);
        })
        .catch(() => caches.match(SHELL))
    );
    return;
  }

  // For other resources: network-first, cache fallback
  e.respondWith(
    fetch(e.request)
      .then(resp => {
        if (resp && resp.status === 200 && resp.type === 'basic') {
          caches.open(CACHE).then(c => c.put(e.request, resp.clone()));
        }
        return resp;
      })
      .catch(() => caches.match(e.request))
  );
});
