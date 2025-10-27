import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:vialidad_oxs/config/temp/temp_data.dart';

/// Controller for managing device information across different platforms
/// Uses device_info_plus package to gather platform-specific device data
class DeviceController {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get comprehensive device information for the current platform
  static Future<Map<String, dynamic>> getDeviceDetail() async {
    try {
      if (Platform.isAndroid) {
        return await _getAndroidDeviceInfo();
      } else if (Platform.isIOS) {
        return await _getIOSDeviceInfo();
      } else if (Platform.isMacOS) {
        return await _getMacOSDeviceInfo();
      } else if (Platform.isWindows) {
        return await _getWindowsDeviceInfo();
      } else if (Platform.isLinux) {
        return await _getLinuxDeviceInfo();
      } else if (kIsWeb) {
        return await _getWebDeviceInfo();
      } else {
        // Fallback for unknown platforms
        deviceData = {
          'platform': 'unknown',
          'name': 'Unknown Device',
          'version': 'Unknown',
          'identifier': 'unknown',
          'timestamp': DateTime.now().toIso8601String(),
        };
        return deviceData;
      }
    } catch (e) {
      // Error handling
      deviceData = {
        'platform': 'error',
        'name': 'Error Getting Device Info',
        'version': 'Unknown',
        'identifier': 'error',
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      return deviceData;
    }
  }

  /// Get Android device information
  static Future<Map<String, dynamic>> _getAndroidDeviceInfo() async {
    final AndroidDeviceInfo androidInfo = await _deviceInfo.androidInfo;

    deviceData = {
      'platform': 'Android',
      'name': androidInfo.model,
      'brand': androidInfo.brand,
      'manufacturer': androidInfo.manufacturer,
      'version': androidInfo.version.release,
      'sdk_version': androidInfo.version.sdkInt,
      'security_patch': androidInfo.version.securityPatch,
      'identifier': androidInfo.id,
      'device_id': androidInfo.device,
      'display': androidInfo.display,
      'fingerprint': androidInfo.fingerprint,
      'hardware': androidInfo.hardware,
      'host': androidInfo.host,
      'product': androidInfo.product,
      'tags': androidInfo.tags,
      'type': androidInfo.type,
      'is_physical_device': androidInfo.isPhysicalDevice,
      'board': androidInfo.board,
      'bootloader': androidInfo.bootloader,
      'supported_abis': androidInfo.supportedAbis,
      'supported_32bit_abis': androidInfo.supported32BitAbis,
      'supported_64bit_abis': androidInfo.supported64BitAbis,
      'system_features': androidInfo.systemFeatures,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get iOS device information
  static Future<Map<String, dynamic>> _getIOSDeviceInfo() async {
    final IosDeviceInfo iosInfo = await _deviceInfo.iosInfo;

    deviceData = {
      'platform': 'iOS',
      'name': iosInfo.name,
      'model': iosInfo.model,
      'localized_model': iosInfo.localizedModel,
      'version': iosInfo.systemVersion,
      'identifier': iosInfo.identifierForVendor,
      'system_name': iosInfo.systemName,
      'machine': iosInfo.utsname.machine,
      'sysname': iosInfo.utsname.sysname,
      'nodename': iosInfo.utsname.nodename,
      'release': iosInfo.utsname.release,
      'version_info': iosInfo.utsname.version,
      'is_physical_device': iosInfo.isPhysicalDevice,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get macOS device information
  static Future<Map<String, dynamic>> _getMacOSDeviceInfo() async {
    final MacOsDeviceInfo macInfo = await _deviceInfo.macOsInfo;

    deviceData = {
      'platform': 'macOS',
      'name': macInfo.computerName,
      'host_name': macInfo.hostName,
      'arch': macInfo.arch,
      'model': macInfo.model,
      'kernel_version': macInfo.kernelVersion,
      'major_version': macInfo.majorVersion,
      'minor_version': macInfo.minorVersion,
      'patch_version': macInfo.patchVersion,
      'os_release': macInfo.osRelease,
      'version':
          '${macInfo.majorVersion}.${macInfo.minorVersion}.${macInfo.patchVersion}',
      'identifier': macInfo.systemGUID,
      'cpu_frequency': macInfo.cpuFrequency,
      'memory_size': macInfo.memorySize,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get Windows device information
  static Future<Map<String, dynamic>> _getWindowsDeviceInfo() async {
    final WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;

    deviceData = {
      'platform': 'Windows',
      'name': windowsInfo.computerName,
      'user_name': windowsInfo.userName,
      'major_version': windowsInfo.majorVersion,
      'minor_version': windowsInfo.minorVersion,
      'build_number': windowsInfo.buildNumber,
      'platform_id': windowsInfo.platformId,
      'csd_version': windowsInfo.csdVersion,
      'service_pack_major': windowsInfo.servicePackMajor,
      'service_pack_minor': windowsInfo.servicePackMinor,
      'product_type': windowsInfo.productType,
      'reserved': windowsInfo.reserved,
      'build_lab': windowsInfo.buildLab,
      'build_lab_ex': windowsInfo.buildLabEx,
      'digital_product_id': windowsInfo.digitalProductId,
      'display_version': windowsInfo.displayVersion,
      'edition_id': windowsInfo.editionId,
      'install_date': windowsInfo.installDate,
      'product_id': windowsInfo.productId,
      'product_name': windowsInfo.productName,
      'registered_owner': windowsInfo.registeredOwner,
      'release_id': windowsInfo.releaseId,
      'device_id': windowsInfo.deviceId,
      'version': windowsInfo.displayVersion,
      'identifier': windowsInfo.deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get Linux device information
  static Future<Map<String, dynamic>> _getLinuxDeviceInfo() async {
    final LinuxDeviceInfo linuxInfo = await _deviceInfo.linuxInfo;

    deviceData = {
      'platform': 'Linux',
      'name': linuxInfo.name,
      'version': linuxInfo.version,
      'id': linuxInfo.id,
      'id_like': linuxInfo.idLike,
      'version_codename': linuxInfo.versionCodename,
      'version_id': linuxInfo.versionId,
      'pretty_name': linuxInfo.prettyName,
      'build_id': linuxInfo.buildId,
      'variant': linuxInfo.variant,
      'variant_id': linuxInfo.variantId,
      'machine_id': linuxInfo.machineId,
      'identifier': linuxInfo.machineId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get Web browser information
  static Future<Map<String, dynamic>> _getWebDeviceInfo() async {
    final WebBrowserInfo webInfo = await _deviceInfo.webBrowserInfo;

    deviceData = {
      'platform': 'Web',
      'name': webInfo.browserName.name,
      'app_code_name': webInfo.appCodeName,
      'app_name': webInfo.appName,
      'app_version': webInfo.appVersion,
      'device_memory': webInfo.deviceMemory,
      'language': webInfo.language,
      'languages': webInfo.languages,
      'platform_name': webInfo.platform,
      'product': webInfo.product,
      'product_sub': webInfo.productSub,
      'user_agent': webInfo.userAgent,
      'vendor': webInfo.vendor,
      'vendor_sub': webInfo.vendorSub,
      'hardware_concurrency': webInfo.hardwareConcurrency,
      'max_touch_points': webInfo.maxTouchPoints,
      'version': webInfo.appVersion,
      'identifier':
          'web_${webInfo.appName}_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
    };

    return deviceData;
  }

  /// Get simplified device info for API calls
  static Future<Map<String, dynamic>> getSimpleDeviceInfo() async {
    await getDeviceDetail();

    return {
      'platform': deviceData['platform'] ?? 'unknown',
      'name': deviceData['name'] ?? 'Unknown Device',
      'version': deviceData['version'] ?? 'Unknown',
      'identifier': deviceData['identifier'] ?? 'unknown',
    };
  }

  /// Get device identifier for unique identification
  static Future<String> getDeviceIdentifier() async {
    await getDeviceDetail();
    return deviceData['identifier'] ?? 'unknown';
  }

  /// Get platform name
  static Future<String> getPlatformName() async {
    await getDeviceDetail();
    return deviceData['platform'] ?? 'unknown';
  }

  /// Check if device is physical (not emulator/simulator)
  static Future<bool> isPhysicalDevice() async {
    await getDeviceDetail();
    return deviceData['is_physical_device'] ?? true;
  }
}

/// Legacy function for backward compatibility
Future<Map<String, dynamic>> getDeviceDetail() async {
  return await DeviceController.getDeviceDetail();
}
