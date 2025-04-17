# feed_finder

A Dart library for discovering RSS and Atom feeds on websites.

## Features

- Finds feed links in both HTML `<head>` and `<body>` sections
- Supports RSS, Atom, and other XML-based feeds
- Handles relative URLs automatically
- Optional verification of feed URLs
- Parallel processing for improved performance
- Control over concurrent connections

## Installation

Add `feed_finder` to your `pubspec.yaml`:

```yaml
dependencies:
  feed_finder: ^1.1.0
```

## Usage

Basic usage:

```dart
import 'package:feed_finder/feed_finder.dart';

void main() async {
  final url = 'https://example.com';
  
  try {
    // Find all feeds on the website
    final feeds = await FeedFinder.scrape(url);
    
    if (feeds.isEmpty) {
      print('No feeds found');
    } else {
      print('Found feeds:');
      for (final feed in feeds) {
        print('- $feed');
      }
    }
  } finally {
    // Always dispose resources when done
    FeedFinder.dispose();
  }
}
```

## Advanced Usage

```dart
// Only check <head> for feed links (faster)
final headFeeds = await FeedFinder.scrape(
  'https://example.com',
  parseBody: false
);

// Only check <body> for feed links
final bodyFeeds = await FeedFinder.scrape(
  'https://example.com',
  parseHead: false
);

// Get potential feed candidates without verification (faster but less accurate)
final candidateFeeds = await FeedFinder.scrape(
  'https://example.com',
  verifyCandidates: false
);

// Control number of concurrent connections when verifying feeds
final feeds = await FeedFinder.scrape(
  'https://example.com',
  maxConcurrentVerifications: 3
);
```

## Performance Considerations

- Setting `verifyCandidates: false` provides faster results but may include invalid feeds
- The `maxConcurrentVerifications` parameter controls parallel processing when verifying feeds
- For best performance with large sites, use a reasonable concurrency limit (3-5)
- Remember to call `FeedFinder.dispose()` when done to release resources

## Credits

Inspired and initially modelled after [python-3-feedfinder-rss-detection-from-url](https://alex.miller.im/posts/python-3-feedfinder-rss-detection-from-url/).
