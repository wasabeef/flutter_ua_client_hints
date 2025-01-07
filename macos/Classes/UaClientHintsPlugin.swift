import FlutterMacOS
import Foundation

public class UaClientHintsPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ua_client_hints", binaryMessenger: registrar.messenger)
        let instance = UaClientHintsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "getPlatformVersion":
            let version = ProcessInfo.processInfo.operatingSystemVersion
            result("\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)")
        case "getUserAgentData":
            var data: [String: Any] = [:]
            data["platform"] = "macOS"
            data["platformVersion"] = "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)"
            data["architecture"] = getArchitecture()
            data["model"] = getModel()
            data["mobile"] = false
            data["brand"] = "Apple"
            data["device"] = Host.current().localizedName ?? ""
            
            if let packageInfo = getPackageInfo() {
                data["package"] = packageInfo
            }
            
            result(data)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getArchitecture() -> String {
        #if arch(x86_64)
        return "x86_64"
        #elseif arch(arm64)
        return "arm64"
        #else
        return "unknown"
        #endif
    }
    
    private func getModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var model = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &model, &size, nil, 0)
        return String(cString: model)
    }
    
    private func getPackageInfo() -> [String: Any]? {
        guard let bundle = Bundle.main.infoDictionary else { return nil }
        
        var packageInfo: [String: Any] = [:]
        packageInfo["appName"] = bundle["CFBundleName"] as? String ?? ""
        packageInfo["appVersion"] = bundle["CFBundleShortVersionString"] as? String ?? ""
        packageInfo["packageName"] = bundle["CFBundleIdentifier"] as? String ?? ""
        packageInfo["buildNumber"] = bundle["CFBundleVersion"] as? String ?? ""
        
        return packageInfo
    }
} 