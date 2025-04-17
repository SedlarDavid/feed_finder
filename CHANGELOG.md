## 1.1.0

- Optimized URL handling and normalization
- Added parallel feed verification for improved performance
- Added `maxConcurrentVerifications` parameter to control concurrent connections
- Added proper HTTP client management with timeout support
- Improved feed detection with Atom feed support
- Fixed URL normalization for protocol-relative URLs
- Added content type verification for more accurate feed detection
- Updated example with comprehensive usage patterns
- Updated README with improved documentation
- Added resource disposal with `dispose()` method

## 1.0.9

- Null-safety

## 1.0.8

- Implemented some configuration options per input from mjablecnik

## 1.0.7

- Updated dependencies

## 1.0.6

- Removed dependency on webfeed, which relies on a very old XML lib.

## 1.0.5

- Fix for naked URLs in <body>

## 1.0.4

- Fix for relative URLs found in <head>

## 1.0.3

- Fixed an issue with returning List<dynamic> instead of List<String>

## 1.0.2

- Missing return type

## 1.0.1

- Doc fixes for better score on pub.dev

## 1.0.0

- Initial version, created by Stagehand
