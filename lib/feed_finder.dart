import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

/// A convenience class for finding feeds on a website
///
/// FeedFinder is looking for both RSS and Atom feeds, both as structured
/// elements in <head> and as unstructured links in the <body>.
class FeedFinder {
  static const _timeout = Duration(seconds: 5);
  static final _client = http.Client();
  
  /// Returns feeds found on `url`
  static Future<List<String>> scrape(String url, {
    bool parseHead = true,
    bool parseBody = true,
    bool verifyCandidates = true,
    int? maxConcurrentVerifications,
  }) async {
    var results = <String>[];
    var candidates = <String>{};  // Using a Set directly to avoid duplicates later

    // Get and parse website
    http.Response? response;
    try {
      response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode != 200) {
        return results;
      }
    } catch (e) {
      return results;
    }

    final document = parse(response.body);
    final uri = Uri.parse(url).removeFragment();
    final base = '${uri.scheme}://${uri.host}';
    final basePath = uri.path.endsWith('/') ? uri.path : '${uri.path}/';

    // Look for feed candidates in head
    if (parseHead) {
      for (final link in document.querySelectorAll("link[rel='alternate']")) {
        final type = link.attributes['type'];
        if (type != null && (type.contains('rss') || type.contains('xml') || type.contains('atom'))) {
          final href = link.attributes['href'];
          if (href != null) {
            candidates.add(_normalizeUrl(href, base, basePath));
          }
        }
      }
    }

    // Look for feed candidates in body
    if (parseBody) {
      final feedKeywords = ['rss', 'xml', 'feed', 'atom', 'syndication'];
      
      for (final a in document.querySelectorAll('a')) {
        final href = a.attributes['href'];
        if (href == null) continue;
        
        // Check if any keyword is in the href or text content
        final hrefLower = href.toLowerCase();
        final textLower = a.text.toLowerCase();
        
        if (feedKeywords.any((keyword) => hrefLower.contains(keyword)) || 
            feedKeywords.any((keyword) => textLower.contains(keyword))) {
          candidates.add(_normalizeUrl(href, base, basePath));
        }
      }
    }

    // Verify candidates
    if (!verifyCandidates) {
      return candidates.toList();
    }

    // Verify candidate URLs in parallel
    if (maxConcurrentVerifications != null && maxConcurrentVerifications > 0) {
      final batches = _createBatches(candidates.toList(), maxConcurrentVerifications);
      for (final batch in batches) {
        final futures = batch.map(_verifyCandidate);
        final batchResults = await Future.wait(futures);
        results.addAll(batchResults.where((url) => url != null).map((url) => url!));
      }
    } else {
      // Verify all concurrently
      final futures = candidates.map(_verifyCandidate);
      final verifiedResults = await Future.wait(futures);
      results = verifiedResults.where((url) => url != null).map((url) => url!).toList();
    }

    return results;
  }
  
  /// Helper method to normalize URLs (handle relative, protocol-relative, etc.)
  static String _normalizeUrl(String href, String base, String basePath) {
    // Convert protocol-relative URLs
    if (href.startsWith('//')) {
      return 'https:$href';
    }
    
    // Convert relative URLs
    if (href.startsWith('/')) {
      return '$base$href';
    }
    
    // Handle URLs without protocol
    if (!href.startsWith('http://') && !href.startsWith('https://')) {
      // If it's a root-relative path, append to base
      if (href.startsWith('/')) {
        return '$base$href';
      }
      // Otherwise, append to base path
      return '$base$basePath$href';
    }
    
    // Handle trailing slashes consistently
    if (href.endsWith('/')) {
      return href.substring(0, href.length - 1);
    }
    
    return href;
  }
  
  /// Verify if a URL is a valid feed
  static Future<String?> _verifyCandidate(String candidate) async {
    try {
      final response = await _client.get(Uri.parse(candidate)).timeout(_timeout);
      if (response.statusCode == 200 && 
          (response.headers['content-type']?.contains('xml') ?? false || 
           response.body.trim().startsWith('<?xml'))) {
        return candidate;
      }
    } catch (e) {
      // Invalid feed
    }
    return null;
  }
  
  /// Split a list into batches for controlled parallel execution
  static List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (var i = 0; i < items.length; i += batchSize) {
      final end = (i + batchSize < items.length) ? i + batchSize : items.length;
      batches.add(items.sublist(i, end));
    }
    return batches;
  }
  
  /// Dispose the HTTP client when done
  static void dispose() {
    _client.close();
  }
}
