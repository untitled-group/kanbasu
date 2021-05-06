//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import native_pdf_renderer
import path_provider_macos
import pdf_render
import shared_preferences_macos
import sqflite
import url_launcher_macos
import wakelock_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  NativePdfRendererPlugin.register(with: registry.registrar(forPlugin: "NativePdfRendererPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  SwiftPdfRenderPlugin.register(with: registry.registrar(forPlugin: "SwiftPdfRenderPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  SqflitePlugin.register(with: registry.registrar(forPlugin: "SqflitePlugin"))
  UrlLauncherPlugin.register(with: registry.registrar(forPlugin: "UrlLauncherPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
}
