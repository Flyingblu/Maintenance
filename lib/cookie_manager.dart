import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:io';

class NBCookieManager extends Interceptor {
  /// Cookie manager for http requests。Learn more details about
  /// CookieJar please refer to [cookie_jar](https://github.com/flutterchina/cookie_jar)
  final CookieJar cookieJar;

  static const invalidCookieValue = "_invalid_";

  /// Dart SDK will cause an exception When response cookie's value is empty,
  /// eg. 'Set-Cookie: session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:00 GMT'
  ///
  /// This is a bug of Dart SDK: https://github.com/dart-lang/sdk/issues/35804
  /// So, we should normalize the cookie value before this bug is fixed.
  bool needNormalize = false;

  NBCookieManager(this.cookieJar) {
    // Set `needNormalize` value by Duck test
    try {
      Cookie.fromSetCookieValue("k=;");
    } catch (e) {
      needNormalize = true;
    }
  }

  @override
  onRequest(RequestOptions options) {
    var cookies = cookieJar.loadForRequest(options.uri);
    cookies.removeWhere((cookie) =>
        cookie.value == invalidCookieValue &&
        cookie.expires.isBefore(DateTime.now()));
    cookies.addAll(options.cookies);
    String cookie = getCookies(cookies);
    if (cookie.isNotEmpty) options.headers[HttpHeaders.cookieHeader] = cookie;
  }

  @override
  onResponse(Response response) => _saveCookies(response);

  @override
  onError(DioError err) => _saveCookies(err.response);

  _saveCookies(Response response) {
    if (response != null && response.headers != null) {
      List<String> cookies = response.headers[HttpHeaders.setCookieHeader];
      if (cookies != null) {
        if (needNormalize) {
          var _cookies = normalizeCookies(cookies);
          cookies
            ..clear()
            ..addAll(_cookies);
        }
        cookieJar.saveFromResponse(
          response.request.uri,
          cookies.map((str) {
            var origin = str.split(';').first.split('=').last;
            str = str.replaceFirst(origin, Uri.encodeComponent(origin));
            return Cookie.fromSetCookieValue(str);
          }).toList(),
        );
      }
    }
  }

  static String getCookies(List<Cookie> cookies) {
    return cookies
        .map((cookie) => "${cookie.name}=${Uri.decodeComponent(cookie.value)}")
        .join('; ');
  }

  static List<String> normalizeCookies(List<String> cookies) {
    if (cookies != null) {
      const String expires = " Expires=Thu, 01 Jan 1970 00:00:00 GMT";
      return cookies.map((cookie) {
        var _cookie = cookie.split(";");
        var kv = _cookie.first?.split("=");
        if (kv != null && kv[1].isEmpty) {
          kv[1] = invalidCookieValue;
          _cookie[0] = kv.join('=');
          if (_cookie.length > 1) {
            int i = 1;
            while (i < _cookie.length) {
              if (_cookie[i].trim().toLowerCase().startsWith("expires")) {
                _cookie[i] = expires;
                break;
              }
              ++i;
            }
            if (i == _cookie.length) {
              _cookie.add(expires);
            }
          }
        }
        return _cookie.join(";");
      }).toList();
    }
    return [];
  }
}
