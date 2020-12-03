import 'package_data.dart';

class UserAgentData {
  const UserAgentData({
    required this.platform,
    required this.platformVersion,
    required this.architecture,
    required this.model,
    required this.brand,
    required this.version,
    required this.mobile,
    required this.package,
    required this.device,
  });

  final String platform;
  final String platformVersion;
  final String architecture;
  final String model;
  final String brand;
  final String version;
  final bool mobile;
  final String device;

  final PackageData package;
}
