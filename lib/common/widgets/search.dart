// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:watcher/regio/data/data.dart';
import 'package:watcher/regio/search/search.dart';

Future<Location?> showPlacesSearch(BuildContext context) async =>
    await showSearch<Location>(
      context: context,
      delegate: PlacesSearchDelegate(context),
    );
