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
        case "getInfo":
            let packageInfo = getPackageInfo()
            var data: [String: Any] = [:]
            data["platform"] = "macOS"
            data["platformVersion"] = "\(ProcessInfo.processInfo.operatingSystemVersion.majorVersion).\(ProcessInfo.processInfo.operatingSystemVersion.minorVersion)"
            data["architecture"] = getArchitecture()
            data["model"] = getModel()
            data["mobile"] = false
            data["brand"] = "Apple"
            data["device"] = Host.current().localizedName ?? ""
            data["version"] = packageInfo["appVersion"] ?? ""
            data["appName"] = packageInfo["appName"] ?? ""
            data["appVersion"] = packageInfo["appVersion"] ?? ""
            data["packageName"] = packageInfo["packageName"] ?? ""
            data["buildNumber"] = packageInfo["buildNumber"] ?? ""
            
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
    
    private func getPackageInfo() -> [String: String] {
        let bundle = Bundle.main.infoDictionary ?? [:]
        
        return [
            "appName": bundle["CFBundleName"] as? String ?? "Unknown",
            "appVersion": bundle["CFBundleShortVersionString"] as? String ?? "0.0.0",
            "packageName": bundle["CFBundleIdentifier"] as? String ?? "unknown",
            "buildNumber": bundle["CFBundleVersion"] as? String ?? "0"
        ]
    }
} 