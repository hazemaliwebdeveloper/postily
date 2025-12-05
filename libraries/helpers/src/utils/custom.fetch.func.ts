export interface Params {
  baseUrl: string;
  beforeRequest?: (url: string, options: RequestInit) => Promise<RequestInit>;
  afterRequest?: (
    url: string,
    options: RequestInit,
    response: Response
  ) => Promise<boolean>;
}
export const customFetch = (
  params: Params,
  auth?: string,
  showorg?: string,
  secured: boolean = true
) => {
  return async function newFetch(url: string, options: RequestInit = {}) {
    const baseUrl = params.baseUrl;
    try {
      
      // CRITICAL FIX: Validate baseUrl is a function property
      if (typeof params.baseUrl === 'function') {
        throw new Error('baseUrl should be a string, not a function. Check fetchBackend configuration.');
      }
      
      console.log('🌐 [POZMIXAL] Starting fetch request:', {
        url: baseUrl + url,
        method: options.method || 'GET',
        hasBody: !!options.body,
        baseUrl: baseUrl
      });
      
      if (!baseUrl) {
        console.error('❌ [POZMIXAL] CRITICAL: Backend URL not configured!');
        throw new Error('Could not establish connection - Backend URL not configured. Check NEXT_PUBLIC_BACKEND_URL environment variable.');
      }

      const loggedAuth =
        typeof window === 'undefined'
          ? undefined
          : new URL(window.location.href).searchParams.get('loggedAuth');
      
      const newRequestObject = await params?.beforeRequest?.(url, options);
      
      const authNonSecuredCookie =
        typeof document === 'undefined'
          ? null
          : document.cookie
              .split(';')
              .find((p) => p.includes('auth='))
              ?.split('=')[1]?.trim();

      const authNonSecuredOrg =
        typeof document === 'undefined'
          ? null
          : document.cookie
              .split(';')
              .find((p) => p.includes('showorg='))
              ?.split('=')[1]?.trim();

      const authNonSecuredImpersonate =
        typeof document === 'undefined'
          ? null
          : document.cookie
              .split(';')
              .find((p) => p.includes('impersonate='))
              ?.split('=')[1]?.trim();

      const headersMerged: any = {
        'Accept': 'application/json',
        ...(options.body instanceof FormData
          ? {}
          : { 'Content-Type': 'application/json' }),
        ...(showorg ? { showorg } : authNonSecuredOrg ? { showorg: authNonSecuredOrg } : {}),
        ...(loggedAuth ? { auth: loggedAuth } : {}),
        ...(auth ? { auth } : authNonSecuredCookie ? { auth: authNonSecuredCookie } : {}),
        ...(authNonSecuredImpersonate ? { impersonate: authNonSecuredImpersonate } : {}),
      };

      if (options?.headers && typeof options.headers === 'object' && !(options.headers instanceof Headers)) {
        Object.assign(headersMerged, options.headers);
      }

      const headers: Record<string, string> = headersMerged;

      const fullUrl = baseUrl + url;
      
      const fetchRequest = await fetch(fullUrl, {
        ...(secured ? { credentials: 'include' } : {}),
        ...(newRequestObject || options),
        headers,
        // @ts-ignore
        ...(!options.next && options.cache !== 'force-cache'
          ? { cache: options.cache || 'no-store' }
          : {}),
      });

      console.log('[POZMIXAL] Response:', {
        status: fetchRequest.status,
        statusText: fetchRequest.statusText,
        url: fetchRequest.url
      });

      if (
        !params?.afterRequest ||
        (await params?.afterRequest?.(url, options, fetchRequest))
      ) {
        return fetchRequest;
      }

      // @ts-ignore
      return new Promise((res) => {}) as Response;
    } catch (error: any) {
      console.error('💥 [POZMIXAL] Fetch error details:', {
        message: error.message,
        stack: error.stack,
        url: baseUrl + url,
        method: options.method || 'GET'
      });
      
      if (error.message.includes('Could not establish connection')) {
        throw error;
      }
      
      if (error.message.includes('Failed to fetch') || error.message.includes('ERR_FAILED_CONNECTION')) {
        throw new Error('Failed to fetch - Could not establish connection to backend. Ensure backend is running on http://localhost:3000');
      }
      
      if (error.message.includes('CORS') || error.message.includes('Cross-Origin')) {
        throw new Error('CORS policy error - Check FRONTEND_URL environment variable on backend matches your access URL.');
      }
      
      if (error.message.includes('network') || error.message.includes('Network request failed')) {
        throw new Error('Network error - Check your internet connection and backend availability.');
      }
      
      throw new Error(`Network request failed: ${error.message}`);
    }
  };
};

// FIXED fetchBackend configuration - ensures baseUrl is always available
function getBackendUrl(): string {
  try {
    if (typeof window !== 'undefined') {
      // Browser environment
      const url = process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000';
      if (!url) {
        console.error('❌ NEXT_PUBLIC_BACKEND_URL is not set. Defaulting to http://localhost:3000');
        return 'http://localhost:3000';
      }
      console.log('🌐 [POZMIXAL] Browser baseUrl resolved to:', url);
      return url;
    } else {
      // Server environment - check all possible env vars
      const url = process.env.BACKEND_URL || process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000';
      if (!process.env.BACKEND_URL && !process.env.NEXT_PUBLIC_BACKEND_URL) {
        console.warn('⚠️ Neither BACKEND_URL nor NEXT_PUBLIC_BACKEND_URL set. Using default http://localhost:3000');
      }
      console.log('🖥️ [POZMIXAL] Server baseUrl resolved to:', url);
      return url;
    }
  } catch (error) {
    console.error('❌ Error resolving backend URL:', error);
    return 'http://localhost:3000';
  }
}

export const fetchBackend = customFetch({
  baseUrl: getBackendUrl(),
});
