/**
 * Centralized API configuration for the Astrolabe Admin Dashboard.
 *
 * Decouples the frontend's networking layer from specific local IP subnets.
 * By setting useLocalTunnel to false, all dashboard requests route directly to localhost.
 */

// 1. اجعلها false لأننا نشغل السيرفر محلياً الآن بدون نفق خارجي
const useLocalTunnel = false;

// 2. اجعل الرابط المحلي يشير مباشرة إلى البورت 3000 على جهازك
const fallbackLocalUrl = 'http://localhost:3000';
const localTunnelUrl = 'https://astrolabe-cafe.loca.lt';

export const API_BASE_URL = useLocalTunnel ? localTunnelUrl : fallbackLocalUrl;