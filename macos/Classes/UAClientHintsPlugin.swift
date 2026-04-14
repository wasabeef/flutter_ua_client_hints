import Cocoa
import Darwin
import FlutterMacOS

public class UAClientHintsPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ua_client_hints", binaryMessenger: registrar.messenger)
    let instance = UAClientHintsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "getInfo" else {
      result(FlutterMethodNotImplemented)
      return
    }

    result([
      "platform": "macOS",
      "platformVersion": platformVersion(),
      "architecture": cpuArchitecture(),
      "model": "Mac",
      "brand": "Apple",
      "version": bundleString(for: "CFBundleShortVersionString"),
      "mobile": false,
      "device": deviceIdentifier(),
      "appName": appName(),
      "appVersion": bundleString(for: "CFBundleShortVersionString"),
      "packageName": Bundle.main.bundleIdentifier ?? "",
      "buildNumber": bundleString(for: "CFBundleVersion"),
    ])
  }

  private func appName() -> String {
    let displayName = bundleString(for: "CFBundleDisplayName")
    return displayName.isEmpty ? bundleString(for: "CFBundleName") : displayName
  }

  private func bundleString(for key: String) -> String {
    Bundle.main.object(forInfoDictionaryKey: key) as? String ?? ""
  }

  private func platformVersion() -> String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
  }

  private func deviceIdentifier() -> String {
    let hardwareModel = sysctlString(named: "hw.model")
    return hardwareModel.isEmpty ? machineIdentifier() : hardwareModel
  }

  private func machineIdentifier() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    return withUnsafePointer(to: &systemInfo.machine) { pointer in
      pointer.withMemoryRebound(to: CChar.self, capacity: Int(_SYS_NAMELEN)) { machine in
        String(cString: machine)
      }
    }
  }

  private func sysctlString(named name: String) -> String {
    var size: size_t = 0
    guard sysctlbyname(name, nil, &size, nil, 0) == 0, size > 0 else {
      return ""
    }

    var value = [CChar](repeating: 0, count: Int(size))
    guard sysctlbyname(name, &value, &size, nil, 0) == 0 else {
      return ""
    }

    return String(cString: value)
  }

  private func cpuArchitecture() -> String {
    var type = cpu_type_t()
    var cpuSize = MemoryLayout<cpu_type_t>.size
    sysctlbyname("hw.cputype", &type, &cpuSize, nil, 0)

    var subType = cpu_subtype_t()
    var subTypeSize = MemoryLayout<cpu_subtype_t>.size
    sysctlbyname("hw.cpusubtype", &subType, &subTypeSize, nil, 0)

    switch type {
    case CPU_TYPE_X86_64:
      switch subType {
      case CPU_SUBTYPE_X86_64_H:
        return "x86_64h"
      case CPU_SUBTYPE_X86_ARCH1:
        return "x86_arch1"
      case CPU_SUBTYPE_X86_64_ALL:
        return "x86_64"
      default:
        return "x86_64"
      }
    case CPU_TYPE_X86:
      return "x86"
    case CPU_TYPE_ARM:
      switch subType {
      case CPU_SUBTYPE_ARM_V8:
        return "armv8"
      case CPU_SUBTYPE_ARM_V7:
        return "armv7"
      case CPU_SUBTYPE_ARM_V7EM:
        return "armv7em"
      case CPU_SUBTYPE_ARM_V7F:
        return "armv7f"
      case CPU_SUBTYPE_ARM_V7K:
        return "armv7k"
      case CPU_SUBTYPE_ARM_V7M:
        return "armv7m"
      case CPU_SUBTYPE_ARM_V7S:
        return "armv7s"
      case CPU_SUBTYPE_ARM_V6:
        return "armv6"
      case CPU_SUBTYPE_ARM_V6M:
        return "armv6m"
      case CPU_SUBTYPE_ARM_V4T:
        return "armv4t"
      case CPU_SUBTYPE_ARM_V5TEJ:
        return "armv5"
      case CPU_SUBTYPE_ARM_XSCALE:
        return "xscale"
      case CPU_SUBTYPE_ARM_ALL:
        return "arm"
      default:
        return "arm"
      }
    case CPU_TYPE_ARM64:
      switch subType {
      case CPU_SUBTYPE_ARM64_V8:
        return "arm64v8"
      case CPU_SUBTYPE_ARM64E:
        return "arm64e"
      case CPU_SUBTYPE_ARM64_ALL:
        return "arm64"
      default:
        return "arm64"
      }
    case CPU_TYPE_ARM64_32:
      return "arm64_32"
    case CPU_TYPE_POWERPC:
      return "ppc"
    case CPU_TYPE_POWERPC64:
      return "ppc64"
    case CPU_TYPE_VAX:
      return "vax"
    case CPU_TYPE_I860:
      return "i860"
    case CPU_TYPE_I386:
      return "i386"
    case CPU_TYPE_HPPA:
      return "hppa"
    case CPU_TYPE_SPARC:
      return "sparc"
    case CPU_TYPE_MC88000:
      return "m88k"
    case CPU_TYPE_ANY:
      return "any"
    default:
      return "unknown"
    }
  }
}
