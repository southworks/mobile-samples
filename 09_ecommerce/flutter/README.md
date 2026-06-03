# Ecommerce Flutter Samples

Base Flutter preparada para alojar ejemplos separados de `Shopify`, `BigCommerce` y `Stripe` dentro del mismo proyecto.

## Decision de arquitectura

No lo separe en apps distintas. En este punto conviene un solo shell con features aislados por proveedor:

- comparte tema, navegacion y convenciones de Flutter
- evita duplicar setup nativo de Android/iOS
- mantiene cada integracion desacoplada en su propia carpeta

Si en el futuro alguno de los ejemplos requiere dependencias nativas incompatibles o branding propio, ahi si conviene dividirlos en apps distintas.

## Estructura

- `lib/src/core`: configuracion compartida y pantallas base.
- `lib/src/features/home`: home con selector de ejemplos.
- `lib/src/features/shopify`: entrypoint del ejemplo de Shopify.
- `lib/src/features/catalog`: implementacion actual del catalogo Shopify.
- `lib/src/features/bigcommerce`: scaffold separado para BigCommerce.
- `lib/src/features/stripe`: scaffold separado para Stripe.

## Configuracion por proveedor

La app usa `dart-define` y no persiste secretos en el repo.

### Shopify

- `SHOPIFY_SHOP_DOMAIN`
- `SHOPIFY_STOREFRONT_ACCESS_TOKEN`
- `SHOPIFY_API_VERSION` opcional, default `2025-10`

### BigCommerce

- `BIGCOMMERCE_STORE_HASH`
- `BIGCOMMERCE_CHANNEL_ID`
- `BIGCOMMERCE_STOREFRONT_TOKEN`

### Stripe

- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_MERCHANT_IDENTIFIER`

## Ejemplo de ejecucion

```bash
flutter run ^
  --dart-define=SHOPIFY_SHOP_DOMAIN=tu-tienda.myshopify.com ^
  --dart-define=SHOPIFY_STOREFRONT_ACCESS_TOKEN=tu_token
```

## Build release Android

```bash
flutter build apk --release ^
  --dart-define=SHOPIFY_SHOP_DOMAIN=tu-tienda.myshopify.com ^
  --dart-define=SHOPIFY_STOREFRONT_ACCESS_TOKEN=tu_token
```

Salida:

- `build/app/outputs/flutter-apk/app-release.apk`

## Estado actual

- `Shopify`: funcional, lista productos por Storefront API.
- `BigCommerce`: scaffold listo para integrar catalogo y checkout.
- `Stripe`: scaffold listo para integrar pagos como feature separado.
