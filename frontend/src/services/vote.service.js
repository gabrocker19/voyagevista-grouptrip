import { api } from "./api";

export const voteService = {
  voter: (data) => api.post("/api/votes", data),
  resultats: (groupe_id, type) =>
    api.get(`/api/votes?groupe_id=${groupe_id}&type=${type}`),
  valider: (data) => api.post("/api/votes/valider", data),
};
