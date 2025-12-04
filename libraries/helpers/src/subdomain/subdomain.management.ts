import { parse } from 'tldts';

export function getCookieUrlFromDomain(domain: string) {
  try {
    const url = new URL(domain);
    const hostname = url.hostname;
    
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return hostname;
    }
    
    const parsed = parse(domain);
    return parsed.domain! ? '.' + parsed.domain! : hostname;
  } catch (e) {
    const parsed = parse(domain);
    return parsed.domain! ? '.' + parsed.domain! : domain;
  }
}
