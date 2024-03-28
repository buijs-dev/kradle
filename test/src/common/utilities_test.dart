// Copyright (c) 2021 - 2024 Buijs Software
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import "dart:io";

import "package:kradle/src/common/exception.dart";
import "package:kradle/src/common/utilities.dart";
import "package:test/test.dart";

void main() {
  test("Verify verifyExists throws exception if File does not exist", () {
    expect(
        () => File("BLABLA").verifyExists,
        throwsA(predicate((e) =>
            e is KradleException &&
            e.cause.startsWith("Path does not exist"))));
  });

  test("Verify _substitute correctly normalizes a path", () {
    expect(
        File("foo/bar/res/../../pikachu")
            .normalizeToFile
            .path
            .endsWith("foo${Platform.pathSeparator}pikachu"),
        true);
  });
}

class FakePlatformWrapper extends PlatformWrapper {
  String _os = Platform.operatingSystem;

  Map<String, String> _env = Platform.environment;

  @override
  String get operatingSystem => _os;

  set operatingSystem(String value) {
    _os = value;
  }

  @override
  Map<String, String> get environment => _env;

  set environment(Map<String, String> value) {
    _env = value;
  }
}
