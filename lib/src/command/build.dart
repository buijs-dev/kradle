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

import "package:args/command_runner.dart";

import "../common/executor.dart";

/// Build the klutter application by running a gradle build. Running
/// this command does everything which is required to start a klutter
/// app on a device.
///
/// This command uses the project gradle wrapper distribution to
/// run clean and build tasks in the ./platform module. The platform
/// module applies the klutter gradle plugin which handles the code
/// analysis, code generation and copying of artifacts to android
/// and ios sub modules.
///
/// {@category gradle}.
class BuildCommand extends Command<dynamic> {
  /// Create a new instance of [BuildCommand]
  /// which will run the command
  /// in the [pathToRoot] directory.
  BuildCommand(this.pathToRoot, {Executor? executor})
      : _executor = executor ?? Executor();

  @override
  final name = "build";

  @override
  final description =
      "Build the application by running a gradle build in the platform module";

  /// The directory in which the build command should be executed.
  final String pathToRoot;

  final Executor _executor;

  @override
  void run() {
    _executor
      ..workingDirectory = Directory(pathToRoot)
      ..arguments = ["clean", "build", "-p", "platform"]
      ..executable = "gradlew"
      ..run();
  }
}
