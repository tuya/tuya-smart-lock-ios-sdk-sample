source 'https://github.com/CocoaPods/Specs'
source 'https://github.com/tuya/TuyaPublicSpecs.git'
source 'https://github.com/tuya/tuya-pod-specs.git'

platform :ios, '11.0'

target 'tuya-smart-lock-ios-sdk-sample' do
  # Comment the next line if you don't want to use dynamic frameworks
  # use_frameworks!

  pod 'libextobjc'
  pod 'MBProgressHUD'
  pod 'Masonry'
  pod 'MJRefresh'
  
  pod 'ThingSmartResidenceBasicKit', '1.1.1'
  pod 'ThingSmartResidenceKit', '1.1.1'
  pod 'ThingSmartLockSDK', '~> 1.3.0'

  pod 'ThingBluetoothInterface'
  pod 'ThingSmartNetworkKit'
  pod 'ThingSmartMQTTChannelKit'
  pod 'ThingSmartUtil'
  pod 'ThingSmartBaseKit'
  pod 'YYModel', '1.0.4'
  pod 'ThingSmartDeviceCoreKit'
  pod 'ThingSmartShareKit'

  pod 'ThingSmartBLEMeshKit'
  pod 'ThingSmartBLEKit'
  pod 'ThingSmartBLECoreKit'

  
end
post_install do |installer|
  installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings["DEVELOPMENT_TEAM"] = "YU53J7686A"
               end
          end
        end
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
            config.build_settings["CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES"] = "YES"
        end
    end
end
