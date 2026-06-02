import { api } from "./api";

export const groupService = {
  getAll: () => api.get("/api/groupes"),
  getOne: (id) => api.get(`/api/groupes/${id}`),
  create: (data) => api.post("/api/groupes", data),
  update: (id, data) => api.put(`/api/groupes/${id}`, data),
  delete: (id) => api.delete(`/api/groupes/${id}`),
  inviter: (id, data) => api.post(`/api/groupes/${id}/inviter`, data),
  rejoindre: (id, statut) =>
    api.post(`/api/groupes/${id}/rejoindre`, { statut }),
};
