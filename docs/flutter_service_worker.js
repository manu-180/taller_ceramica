'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "02cde573d6cf21588044237712a308eb",
"assets/AssetManifest.bin.json": "e610949fcd4c36752bc5cc304222a570",
"assets/AssetManifest.json": "7fd9bb5ff2b34e0bb45b9bdd398f02a4",
"assets/assets/icon/background.png": "95bc417d2bb18a1f81bf1e110d633593",
"assets/assets/icon/icon%2520(2).png": "99edbdb4c7aa4499041822619fad1bb8",
"assets/assets/icon/image.png": "1f1461f2a563b345539b37ea9543a512",
"assets/assets/images/Acting.png": "be1263077a3fb0cc0c648f47fe573d4b",
"assets/assets/images/artesmarciales.png": "c733f16328727f36786ac24086bf71bd",
"assets/assets/images/Boxing.png": "c63028c4edb4c6a6789e30e5f893c13b",
"assets/assets/images/ceramicagif.gif": "6cfd46a4cb9fa2a9deeca4fa7a98f4c0",
"assets/assets/images/ceramicamujer.gif": "edca0b9f1add565301cb23e8b090a98b",
"assets/assets/images/Cooking.png": "2c92baee067ee3fdcf7a2248dc7c70e5",
"assets/assets/images/CrossFit.png": "04abe92f190d75a41869af923a54e616",
"assets/assets/images/danza.png": "f928a62b63ec99cdc69d4ddd9fb719b9",
"assets/assets/images/Gymnastics.png": "4a23a8dc1f013925f2b83950bb1a68cc",
"assets/assets/images/Languages.png": "e3d8cac80af92be5ad4f33b156253041",
"assets/assets/images/libreta.png": "a55ebc2b55a97af54eba8e3f613ee1f7",
"assets/assets/images/musica.webp": "6ddbb08d2bd3e59d72cf362dd493385a",
"assets/assets/images/natacion.webp": "57fad9be7c6d0d0d740008f4dcfaae1c",
"assets/assets/images/Pilates.png": "83dbc5609168bb259a70a4cf5b67d5c0",
"assets/assets/images/pintura.webp": "366a9b8c869cae136d7e716449f91447",
"assets/assets/images/Tennis.png": "6efb1a18c1cadf943c1846d6999066d1",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.57%2520PM%2520(1).jpeg": "f1b84974932744810607b9b2fd605af2",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.57%2520PM%2520(2).jpeg": "a8596c92b077305972dd1282e3ff7577",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.57%2520PM%2520(3).jpeg": "21a9ebce3a80db2be12cc875b101b378",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.57%2520PM.jpeg": "f1b84974932744810607b9b2fd605af2",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.58%2520PM%2520(1).jpeg": "1c7d491602eb29a5b35d8a6b2e86e1a5",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.58%2520PM.jpeg": "7422318182570bd3e04a2ebe97acef88",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.59%2520PM%2520(1).jpeg": "3495a7d0a0ea8251ea9f1c328d5e74cc",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.59%2520PM%2520(2).jpeg": "5bc340e5aaeea7268ee04ac44b000aff",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.30.59%2520PM.jpeg": "eff5b047f1d99a261fd31ce9209abda3",
"assets/assets/images/WhatsApp%2520Image%25202025-02-02%2520at%252012.31.00%2520PM.jpeg": "c9d9f7bb0121d7941de31b2049c6f84b",
"assets/assets/images/WhatsApp%2520Video%25202025-02-02%2520at%25204.12.38%2520PM.mp4": "4d4d13b660bc7aa1b731c1b657a9ed39",
"assets/FontManifest.json": "5a32d4310a6f5d9a6b651e75ba0d7372",
"assets/fonts/MaterialIcons-Regular.otf": "e16b9ef1723ae74d9a4d45de9cee2268",
"assets/NOTICES": "3e2eb072e2f05c197739f713382db014",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/packages/fluttertoast/assets/toastify.css": "a85675050054f179444bc5ad70ffc635",
"assets/packages/fluttertoast/assets/toastify.js": "56e2c9cedd97f10e7e5f1cebd85d53e3",
"assets/packages/font_awesome_flutter/lib/fonts/fa-brands-400.ttf": "00a0d5a58ed34a52b40eb372392a8b98",
"assets/packages/font_awesome_flutter/lib/fonts/fa-regular-400.ttf": "112614b66790de22b73dba1cf997c1bf",
"assets/packages/font_awesome_flutter/lib/fonts/fa-solid-900.ttf": "64857017d74b506478c9fed97eb72ce0",
"assets/packages/wakelock_plus/assets/no_sleep.js": "7748a45cd593f33280669b29c2c8919a",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "26eef3024dbc64886b7f48e1b6fb05cf",
"canvaskit/canvaskit.js.symbols": "efc2cd87d1ff6c586b7d4c7083063a40",
"canvaskit/canvaskit.wasm": "e7602c687313cfac5f495c5eac2fb324",
"canvaskit/chromium/canvaskit.js": "b7ba6d908089f706772b2007c37e6da4",
"canvaskit/chromium/canvaskit.js.symbols": "e115ddcfad5f5b98a90e389433606502",
"canvaskit/chromium/canvaskit.wasm": "ea5ab288728f7200f398f60089048b48",
"canvaskit/skwasm.js": "ac0f73826b925320a1e9b0d3fd7da61c",
"canvaskit/skwasm.js.symbols": "96263e00e3c9bd9cd878ead867c04f3c",
"canvaskit/skwasm.wasm": "828c26a0b1cc8eb1adacbdd0c5e8bcfa",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"favicon.png": "7c0719ac9b9b3a8458e9c6768fef1c3b",
"flutter.js": "4b2350e14c6650ba82871f60906437ea",
"flutter_bootstrap.js": "26c40f33f974dc79c0b74bc7f61dfef0",
"icons/Icon-192.png": "8681a07ff2fc61e38ffc1b7e09b14fd2",
"icons/Icon-512.png": "566cd840bdfd323f2e5683bc7fd58cc6",
"icons/Icon-maskable-192.png": "8681a07ff2fc61e38ffc1b7e09b14fd2",
"icons/Icon-maskable-512.png": "566cd840bdfd323f2e5683bc7fd58cc6",
"index.html": "43af3dc21b7f8bc17f90608925ecc409",
"/": "43af3dc21b7f8bc17f90608925ecc409",
"main.dart.js": "d1d6a5829532a144c4b54b6b29448549",
"manifest.json": "04eca14618c7a79efa1376e83af7c3d4",
"version.json": "1a9b4b6fac4743e8de2bd1291171075d"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
