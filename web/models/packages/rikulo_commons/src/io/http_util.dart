//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Wed, Apr 10, 2013  5:29:00 PM
// Author: tomyeh
part of rikulo_io;

/**
 * HTTP related utilities
 */
class HttpUtil {
  /** Decodes the parameters of the POST request.
   *
   * * [parameters] - the map to put the decoded parameters into.
   * If null, this method will instantiate a new map.
   * To merge the parameters found in the query string, you can do:
   *
   *     final params = HttpUtil.decodePostedParameters(
   *       request, request.queryParameters);
   */
  static Future<Map<String, String>> decodePostedParameters(
      Stream<List<int>> request, [Map<String, String> parameters])
  => IOUtil.readAsString(request)
      .then((String data) => decodeQuery(data, parameters));

  /** Decodes the query string into a map of name-value pairs (aka., parameters).
   *
   * * [queryString] - the query string shall not contain `'?'`.
   * * [parameters] - the map to put the decoded parameters into.
   * If null, this method will instantiate a new map.
   */
  static Map<String, String> decodeQuery(
      String queryString, [Map<String, String> parameters]) {
    if (parameters == null)
      parameters = new LinkedHashMap();

    int i = 0, len = queryString.length;
    while (i < len) {
      int j = i;
      bool eqFound = false;
      for (; j < len; ++j) {
        final cc = queryString[j];
        if (cc == '=') {
          eqFound = true;
          break;
        }
        if (cc == '&')
          break;
      }

      String name = queryString.substring(i, j);
      i = eqFound ? j + 1: j;
      j = queryString.indexOf("&", i);
      String value;
      if (j == -1) {
        value = queryString.substring(i);
        i = queryString.length;
      } else {
        value = queryString.substring(i, j);
        i = j + 1;
      }
      parameters[decodeUriComponent(name)] = decodeUriComponent(value);
    }
    return parameters;
  }
  /** Encodes the given paramters into a query string.
   * Notice the returned string won't start with `'?'`.
   *
   * The value of a parameter will be converted to a string first.
   * If it is null, an empty string is generated.
   */
  static String encodeQuery(Map<String, dynamic> parameters) {
    final buf = new StringBuffer();
    for (final name in parameters.keys) {
      if (!buf.isEmpty)
        buf.write('&');
      buf..write(encodeUriComponent(name))..write('=');
      var value = parameters[name];
      if (value != null)
        value = value.toString();
      if (value != null && !value.isEmpty)
        buf.write(encodeUriComponent(value));
    }
    return buf.toString();
  }
}
