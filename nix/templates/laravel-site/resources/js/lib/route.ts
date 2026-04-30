import { router } from '@inertiajs/react';
import { route as generatedRoute } from '@/generated/helpers/route';

type RouteName = Parameters<typeof generatedRoute>[0];
type RouteParametersFor<T extends RouteName> = Parameters<
  typeof generatedRoute<T>
>[1];
type DynamicRouteParameters = Record<string, string | number>;
type QueryParameters = Record<
  string,
  string | number | boolean | null | undefined | Array<string | number>
>;

const nonLocalizedPrefixes = ['lang.'];

function isNonLocalized(name: string): boolean {
  return nonLocalizedPrefixes.some((prefix) => name.startsWith(prefix));
}

let currentLocale = '';
let currentDefaultLocale = '';

/**
 * Seed locale from the initial page embedded in the DOM, then register the
 * Inertia navigate listener to keep it in sync on subsequent navigations.
 */
export function initRouteLocale(): void {
  const script = document.querySelector(
    'script[data-page][type="application/json"]',
  );

  if (script?.textContent) {
    try {
      const page = JSON.parse(script.textContent);
      currentLocale = page.props?.locale ?? '';
      currentDefaultLocale = page.props?.defaultLocale ?? '';
    } catch {
      // Ignore parse errors; navigate listener will pick it up.
    }
  }

  router.on('navigate', (event) => {
    currentLocale = event.detail.page.props.locale as string;
    currentDefaultLocale = event.detail.page.props.defaultLocale as string;
  });
}

function buildQueryString(query: QueryParameters | undefined): string {
  if (!query) {
    return '';
  }

  const params = new URLSearchParams();

  for (const [key, value] of Object.entries(query)) {
    if (value === null || value === undefined) {
      continue;
    }

    if (Array.isArray(value)) {
      for (const item of value) {
        params.append(`${key}[]`, String(item));
      }

      continue;
    }

    params.append(key, String(value));
  }

  const search = params.toString();

  return search ? `?${search}` : '';
}

function buildUrl(
  name: RouteName,
  parameters: DynamicRouteParameters | undefined,
  query: QueryParameters | undefined,
  absolute: boolean,
): string {
  const raw = generatedRoute(name as never, parameters as never, absolute);

  let url: string;

  if (absolute) {
    url = raw;
  } else {
    url = '/' + raw.replace(/^\/+/, '');
  }

  const queryString = buildQueryString(query);

  if (isNonLocalized(name)) {
    return url + queryString;
  }

  if (!currentLocale || currentLocale === currentDefaultLocale) {
    return url + queryString;
  }

  const prefix = `/${currentLocale}`;

  if (absolute) {
    const parsed = new URL(url);
    parsed.pathname = `${prefix}${parsed.pathname}`;

    return parsed.toString() + queryString;
  }

  return `${prefix}${url}${queryString}`;
}

export function route<T extends RouteName>(
  name: T,
  parameters?: RouteParametersFor<T>,
  query?: QueryParameters,
  absolute?: boolean,
): string;
export function route(
  name: RouteName,
  parameters?: DynamicRouteParameters,
  query?: QueryParameters,
  absolute?: boolean,
): string;
export function route(
  name: RouteName,
  parameters?: DynamicRouteParameters,
  query?: QueryParameters,
  absolute: boolean = false,
): string {
  return buildUrl(name, parameters, query, absolute);
}

export type { RouteName };
