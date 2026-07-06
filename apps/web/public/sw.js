const cacheName = "send-before-60-v1";

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(cacheName).then((cache) =>
      cache.addAll([
        "/",
        "/manifest.webmanifest",
        "/icons/icon-192.png",
        "/icons/icon-512.png",
      ]),
    ),
  );
  self.skipWaiting();
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) => Promise.all(keys.filter((key) => key !== cacheName).map((key) => caches.delete(key)))),
  );
  self.clients.claim();
});

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") {
    return;
  }

  event.respondWith(
    fetch(event.request).catch(() =>
      caches.match(event.request).then((cachedResponse) => cachedResponse || caches.match("/")),
    ),
  );
});
