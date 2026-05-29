import { api } from "./api";

export const catalogueService = {
  destinations: (params = {}) => {
    const q = new URLSearchParams(params);
    return api.get(`/api/destinations?${q}`);
  },
  transports: (params = {}) => {
    const q = new URLSearchParams(params);
    return api.get(`/api/transports?${q}`);
  },
  hebergements: (params = {}) => {
    const q = new URLSearchParams(params);
    return api.get(`/api/hebergements?${q}`);
  },
  activites: (params = {}) => {
    const q = new URLSearchParams(params);
    return api.get(`/api/activites?${q}`);
  },
};
