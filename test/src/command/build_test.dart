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

import "package:kradle/src/command/build.dart";
import "package:kradle/src/common/utilities.dart";
import "package:test/test.dart";

import "../common/executor_test.dart";

void main() {
  test("Verify build command executes gradlew clean build", () {
    final pathToRoot =
        Directory("${Directory.systemTemp.absolute.path}/build_test".normalize)
          ..createSync();

    final executor = FakeExecutor(
        expectedPathToWorkingDirectory: pathToRoot.absolutePath,
        expectedCommand: "gradlew clean build -p platform");

    BuildCommand(pathToRoot.absolutePath, executor: executor).run();

    expect(executor.run().stdout, "Test OK!");
  });
}
