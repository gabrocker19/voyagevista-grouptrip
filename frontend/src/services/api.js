const API_URL = import.meta.env.VITE_API_URL || "http://localhost/voyagevista-grouptrip/backend";

async function request(endpoint, options = {}) {
  const t0 = performance.now();
  const method = options.method || "GET";
  const res = await fetch(`${API_URL}${endpoint}`, {
    headers: { "Content-Type": "application/json" },
    credentials: "include",
    ...options,
  });
  const data = await res.json();
  const ms = Math.round(performance.now() - t0);
  // Chrono de diagnostic : visible dans la console du navigateur (F12).
  const tag = ms > 500 ? "🐢" : "⚡";
  console.log(`${tag} [API ${ms}ms] ${method} ${endpoint}`);
  if (!res.ok) throw new Error(data.error || "Erreur serveur");
  return data;
}

export const api = {
  get: (url) => request(url),
  post: (url, body) =>
    request(url, { method: "POST", body: JSON.stringify(body) }),
  put: (url, body) =>
    request(url, { method: "PUT", body: JSON.stringify(body) }),
  delete: (url) => request(url, { method: "DELETE" }),
};
