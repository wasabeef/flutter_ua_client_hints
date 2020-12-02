package jp.wasabeef.ua.client_hints

import android.app.UiModeManager
import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class UAClientHintsPlugin : FlutterPlugin, MethodCallHandler {
	private lateinit var channel: MethodChannel
	private lateinit var context: Context

	override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
		context = flutterPluginBinding.applicationContext
		channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ua_client_hints")
		channel.setMethodCallHandler(this)
	}

	override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
		if (call.method == "getInfo") {
			val info: PackageInfo? = try {
				context.packageManager.getPackageInfo(context.packageName, 0)
			} catch (e: PackageManager.NameNotFoundException) {
				null
			}
			val uiManager = context.getSystemService(Context.UI_MODE_SERVICE) as UiModeManager

			result.success(mapOf(
          // UserAgentData
          "platform" to "Android",
          "platformVersion" to Build.VERSION.RELEASE, // e.g.. 10
          "architecture" to Build.SUPPORTED_ABIS[0], // e.g.. armv7
          "model" to Build.MODEL, // e.g.. Pixel 4 XL
          "brand" to info?.applicationInfo?.loadLabel(context.packageManager)?.toString(), // e.g.. Sample App
          "version" to info?.versionName, // e.g.. 1.0.0
          "mobile" to (uiManager.currentModeType == Configuration.UI_MODE_TYPE_NORMAL), // true/false

          // AppData
          "appName" to info?.applicationInfo?.loadLabel(context.packageManager)?.toString(), // e.g.. Sample App
          "appVersion" to info?.versionName, // e.g.. 1.0.0
          "packageName" to info?.applicationInfo?.packageName, // e.g..  jp.wasabeef.ua
          "buildNumber" to getVersionCode(context), // e.g.. 1
          "device" to Build.DEVICE, // e.g.. coral
      ))
		} else {
			result.notImplemented()
		}
	}

	override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
		channel.setMethodCallHandler(null)
	}

	@Suppress("DEPRECATION")
	private fun getVersionCode(context: Context): String {
		val packageInfo = context.packageManager.getPackageInfo(context.packageName, 0)
		return if (Build.VERSION.SDK_INT >= 28) packageInfo.longVersionCode.toString() else packageInfo.versionCode.toString()
	}
}
