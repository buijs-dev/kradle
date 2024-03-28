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
import "../common/exception.dart";
import "../common/utilities.dart";

/// Wrapper for [Platform] to access Operating System properties.
PlatformWrapper platform = PlatformWrapper();

/// Property used in kradle.env to retrieve the user home directory.
const kradleEnvPropertyUserHome = "{{system.user.home}}";

/// Helper methods to find configuration files used by kradle.
extension ProjectFile on Directory {
  /// Find the cache folder.
  ///
  /// Get cache property from [kradleEnv] file or default to {{system.user.home}}/.kradle/cache (see [kradleEnvPropertyUserHome]).
  Directory get kradleCache {
    final envFile = kradleEnv;

    if (!envFile.existsSync()) {
      return defaultKradleCache;
    }

    final cacheProperty = envFile.findCacheProperty;

    return cacheProperty == null
        ? envFile.defaultKradleCache
        : envFile.configuredKradleCache(cacheProperty);
  }

  /// File kradle.yaml which contains klutter project data.
  File get kradleYaml => resolveFile("kradle.yaml");

  /// File kradle.env which contains user-specific klutter project data.
  File get kradleEnv => resolveFile("kradle.env");
}

/// Error message indicating the user home directory could not be determined
/// by [userHomeOrError] and no kradle.env file is found.
String _defaultKradleCacheErrorMessage(String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "$envError and there is no kradle.env in $pathToRoot. "
    "Fix this issue by creating a kradle.env file in "
    "$pathToRoot with property 'cache=/path/to/your/cache/folder'";

/// Error message indicating the user home directory could not be determined
/// by [userHomeOrError] and the kradle.env file does not have the cache property.
String _defaultKradleCacheBecauseCachePropertyNotFoundErrorMessage(
        String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "property 'cache' is not found in $pathToRoot and $envError. "
    "Fix this issue by adding property "
    "'cache=/path/to/your/cache/folder' to $pathToRoot";

/// Error message indicating the user home directory could not be determined
/// by [userHomeOrError] and the kradle.env has a cache property which points
/// to the user home directory.
String _configuredKradleHomeErrorMessage(String pathToRoot, String envError) =>
    "Unable to determine kradle cache directory, because "
    "property 'cache' in $pathToRoot "
    "contains system.user.home variable "
    "and $envError. Fix this issue by "
    "replacing $kradleEnvPropertyUserHome variable with "
    "an absolute path in $pathToRoot";

extension on Directory {
  /// Get the default kradle home directory
  /// which is the user home [userHomeOrError]
  /// directory resolved by .kradle.
  ///
  /// Throws [KradleException] if the directory
  /// is not resolved or does not exist.
  Directory get defaultKradleCache {
    final userHome = userHomeOrError;

    final kradleHome = _kradleCacheFromEnvironmentPropertyOrNull(
      userHome.$1,
    );

    final errorMessage = _defaultKradleCacheErrorMessage(
      absolutePath,
      userHome.$2,
    );

    return _kradleCacheDirectoryOrThrow(
        kradleHome, () => throw KradleException(errorMessage));
  }
}

extension on File {
  /// Get the default kradle home directory
  /// which is the user home [userHomeOrError]
  /// directory resolved by .kradle, because
  /// the kradle.env file does not contain a
  /// cache property.
  ///
  /// Throws [KradleException] if the directory
  /// is not resolved or does not exist.
  Directory get defaultKradleCache {
    final userHome = userHomeOrError;
    return _kradleCacheDirectoryOrThrow(
        _kradleCacheFromEnvironmentPropertyOrNull(userHome.$1), () {
      throw KradleException(
          _defaultKradleCacheBecauseCachePropertyNotFoundErrorMessage(
              absolutePath, userHome.$2));
    });
  }

  /// Get the kradle home directory from the kradle.env
  /// file and resolve {{user.home}} variable with [userHomeOrError].
  ///
  ///
  /// Throws [KradleException] if the directory
  /// is not resolved or does not exist.
  Directory configuredKradleCache(String cacheProperty) {
    if (cacheProperty.contains(kradleEnvPropertyUserHome)) {
      final userHome = userHomeOrError;
      final cachePropertyResolved = userHome.$1 != null
          ? cacheProperty.replaceAll(kradleEnvPropertyUserHome, userHome.$1!)
          : null;

      return _kradleCacheDirectoryOrThrow(
        cachePropertyResolved,
        () => throw KradleException(
          _configuredKradleHomeErrorMessage(
            absolutePath,
            userHome.$2,
          ),
        ),
      );
    }

    return _kradleCacheDirectoryOrThrow(cacheProperty, () {});
  }

  /// Return value of property cache or null.
  String? get findCacheProperty => readAsLinesSync()
      .where(_startsWithCache)
      .map(_extractPropertyValue)
      .firstOrNull;
}

bool _startsWithCache(String test) => test.startsWith("cache=");

String _extractPropertyValue(String line) =>
    line.substring(line.indexOf("=") + 1, line.length).trim();

String? _kradleCacheFromEnvironmentPropertyOrNull(String? userHomeOrNull) =>
    userHomeOrNull == null ? null : "$userHomeOrNull/.kradle/cache".normalize;

/// Returns the kradle cache directory or throws a [KradleException]
/// if the directory could not be determined or if it does not exist.
Directory _kradleCacheDirectoryOrThrow(
  String? pathToKradleCache,
  void Function() onNullValue,
) {
  if (pathToKradleCache == null) {
    onNullValue();
  }

  return Directory(pathToKradleCache!.normalize).normalizeToFolder
    ..verifyFolderExists;
}

/// Determine the user home directory by checking environment variables.
///
/// For linux and macos the value of 'HOME' is returned.
/// For windows the value of 'USERPROFILE' is returned.
/// Will return an error message if
/// the operating systems is unsupported
/// or if the mentioned variables are not set.
(String? userHome, String errorMessage) get userHomeOrError =>
    switch (platform.operatingSystem) {
      "linux" || "macos" => (
          platform.environment["HOME"],
          "environment variable 'HOME' is not defined"
        ),
      "windows" => (
          platform.environment["USERPROFILE"],
          "environment variable 'USERPROFILE' is not defined"
        ),
      _ => (
          null,
          "method 'userHome' is not supported on ${platform.operatingSystem}"
        ),
    };
