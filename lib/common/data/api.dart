// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// See https://github.com/derhuerst/bvg-rest/blob/master/docs/index.md
/// for api info
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:http/http.dart' as http;

/// Fetches data from a url over http
/// Throws a HttpException if 200 is not returned

Future<Response> fetchData(String url, Dio dio, Duration timeToCache,
    {Duration? timeToStale, forceRefresh = false}) async {
  final res = await dio.get(url,
      options: buildCacheOptions(
        timeToCache, //duration of cache
        forceRefresh: forceRefresh,
        maxStale: timeToStale ?? const Duration(seconds: 15), //to force refresh
      ));

  if (res.statusCode != 200) {
    // print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return res;
}

Future<bool> delete(String url) async {
  final res = await http.delete(Uri.parse(url));
  if (res.statusCode != 200 && res.statusCode != 404) {
    // print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return true;
}

Future<String> postData(String url, dynamic data) async {
  final res = await http.post(Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data));
  if (res.statusCode != 201) {
    // print('Error ${res.statusCode}: $url');
    throw HttpException(
      'Invalid response ${res.statusCode}',
      uri: Uri.parse(url),
    );
  }
  return res.body;
}
