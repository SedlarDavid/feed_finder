import 'dart:async';
import 'package:feed_finder/feed_finder.dart';

Future<void> main() async {
  final urls = [
    'http://www.braziltravelblog.com/',
    'https://www.protocol.com/',
    'https://www.dcrainmaker.com/',
    'https://rikatillsammans.se/',
    'https://strengthrunning.com/',
    'http://www.europe-v-facebook.org/',
    'https://www.hotelnewsresource.com/',
    'https://www.traveldailynews.com',
    'https://blog.chromium.org/',
    'https://daringfireball.net/'
  ];
  
  try {
    for (final url in urls) {
      final header = 'Looking for feeds in $url';
      final border = '=' * header.length;

      print('');
      print(border);
      print(header);
      print(border);
      print('');

      // Basic usage - scrape head and body, verify feeds
      print('Scrape head and body; and verify potential feeds');
      final results1 = await FeedFinder.scrape(url);
      print(results1.isEmpty ? 'No feeds found' : results1.join('\n'));
      print('');

      // Faster results without verification
      print('Scrape head and body; but disable verification for faster results');
      final results2 = await FeedFinder.scrape(url, verifyCandidates: false);
      print(results2.isEmpty ? 'No feeds found' : results2.join('\n'));
      print('');

      // Scrape only head tags (<link> elements)
      print('Scrape only head');
      final results3 = await FeedFinder.scrape(url, parseBody: false);
      print(results3.isEmpty ? 'No feeds found' : results3.join('\n'));
      print('');

      // Scrape only body (<a> elements)
      print('Scrape only body');
      final results4 = await FeedFinder.scrape(url, parseHead: false);
      print(results4.isEmpty ? 'No feeds found' : results4.join('\n'));
      print('');
      
      // Optimized parallel verification (limit concurrent connections)
      print('Optimized verification (max 3 concurrent requests)');
      final results5 = await FeedFinder.scrape(
        url, 
        maxConcurrentVerifications: 3
      );
      print(results5.isEmpty ? 'No feeds found' : results5.join('\n'));
      print('');
    }
  } finally {
    // Always dispose the HTTP client when done
    FeedFinder.dispose();
  }
}
