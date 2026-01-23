import FlutterMacOS
import Foundation

public class UAClientHintsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ua_client_hints", binaryMessenger: registrar.messenger)
    let instance = UAClientHintsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if (call.method == "getInfo") {
      let processInfo = ProcessInfo.processInfo
      let systemVersion = processInfo.operatingSystemVersion
      let platformVersion = "\(systemVersion.majorVersion).\(systemVersion.minorVersion).\(systemVersion.patchVersion)"
      
      result([
        // UserAgentData
        "platform": "macOS",
        "platformVersion": platformVersion,
        "architecture": cpuType(),
        "model": "Mac",
        "brand": "Apple",
        "version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "",
        "mobile": false,
        "device": device(),

        // PackageData
        "appName": Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") ?? "",
        "appVersion": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "",
        "packageName": Bundle.main.bundleIdentifier ?? "",
        "buildNumber": Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? "",
      ])
    } else {
      result(FlutterMethodNotImplemented)
    }
  }

  func device() -> String {
    var sysInfo = utsname()
    uname(&sysInfo)
    let machine = withUnsafePointer(to: &sysInfo.machine) {
        $0.withMemoryRebound(to: Int8.self, capacity: Int(_SYS_NAMELEN)) {
            String(cString: $0)
        }
    }
    return machine
  }

  func cpuType() -> String {
    var type = cpu_type_t()
    var cpuSize = MemoryLayout<cpu_type_t>.size
    sysctlbyname("hw.cputype", &type, &cpuSize, nil, 0)

    var subType = cpu_subtype_t()
    var subTypeSize = MemoryLayout<cpu_subtype_t>.size
    sysctlbyname("hw.cpusubtype", &subType, &subTypeSize, nil, 0)

    switch type {
    case CPU_TYPE_X86_64:
      switch subType {
      case CPU_SUBTYPE_X86_64_H: return "x86_64h"
      case CPU_SUBTYPE_X86_ARCH1: return "x86_arch1"
      case CPU_SUBTYPE_X86_64_ALL: return "x86_64"
      default: return "x86_64"
      }
    case CPU_TYPE_X86: return "x86"

    case CPU_TYPE_ARM:
      switch subType {
      case CPU_SUBTYPE_ARM_V8: return "armv8"
      case CPU_SUBTYPE_ARM_V7: return "armv7"
      case CPU_SUBTYPE_ARM_V7EM: return "armv7em"
      case CPU_SUBTYPE_ARM_V7F: return "armv7f"
      case CPU_SUBTYPE_ARM_V7K: return "armv7k"
      case CPU_SUBTYPE_ARM_V7M: return "armv7m"
      case CPU_SUBTYPE_ARM_V7S: return "armv7s"
      case CPU_SUBTYPE_ARM_V6: return "armv6"
      case CPU_SUBTYPE_ARM_V6M: return "armv6m"
      case CPU_SUBTYPE_ARM_V4T: return "armv4t"
      case CPU_SUBTYPE_ARM_V5TEJ: return "armv5"
      case CPU_SUBTYPE_ARM_XSCALE: return "xscale"
      case CPU_SUBTYPE_ARM_ALL: return "arm"
      default: return "arm"
      }

    case CPU_TYPE_ARM64:
      switch subType {
      case CPU_SUBTYPE_ARM64_V8: return "arm64v8"
      case CPU_SUBTYPE_ARM64E: return "arm64e"
      case CPU_SUBTYPE_ARM64_ALL: return "arm64"
      default: return "arm64"
      }

    case CPU_TYPE_ARM64_32: return "arm64_32"

    case CPU_TYPE_POWERPC: return "ppc"
    case CPU_TYPE_POWERPC64: return "ppc64"
    case CPU_TYPE_VAX: return "vax"
    case CPU_TYPE_I860: return "i860"
    case CPU_TYPE_I386: return "i386"
    case CPU_TYPE_HPPA: return "hppa"
    case CPU_TYPE_SPARC: return "sparc"
    case CPU_TYPE_MC88000: return "m88k"

    case CPU_TYPE_ANY: return "any"
    default: return "unknown"
    }
  }
}
