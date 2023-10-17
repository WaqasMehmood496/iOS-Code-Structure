platform :ios, '13.0'

target 'Evexia Staging' do
  use_frameworks!

  #Constraints
  pod 'SnapKit'
  
  #UI
  pod 'Atributika', '4.10.1'
  pod 'NBBottomSheet', '~> 1.2'
  pod 'Kingfisher'
  #pod 'Charts' , '~> 3.6'
  pod 'Charts', '4.1.0'
  pod 'Segmentio'
  pod 'JTAppleCalendar'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'SwiftEntryKit', '1.2.7'
  
  #Other
  pod 'IQKeyboardManagerSwift'
  pod 'Swinject'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'CRRefresh'
  pod 'ReachabilitySwift'
  pod 'ActiveLabel', '~> 1.1'
  pod 'HCVimeoVideoExtractor', "0.0.3"
  pod 'FirebaseMessaging', '~> 8.8'
  pod 'Periphery'
  pod 'KeychainSwift', '~> 20.0'
  pod 'BiometricAuthentication'
  
end

target 'Evexia Production' do
  use_frameworks!

  #Constraints
  pod 'SnapKit'

  #UI
  pod 'Atributika', '4.10.1'
  pod 'NBBottomSheet', '~> 1.2'
  pod 'Kingfisher'
  #pod 'Charts' , '~> 3.6'
  pod 'Charts', '4.1.0'
  pod 'Segmentio'
  pod 'JTAppleCalendar'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'SwiftEntryKit', '1.2.7'

  #Other
  pod 'IQKeyboardManagerSwift'
  pod 'Swinject'
  pod 'Firebase/Analytics'
  pod 'Firebase/DynamicLinks'
  pod 'CRRefresh'
  pod 'ReachabilitySwift'
  pod 'ActiveLabel', '~> 1.1'
  pod 'HCVimeoVideoExtractor', "0.0.3"
  pod 'FirebaseMessaging', '~> 8.8'
  pod 'Periphery'
  pod 'KeychainSwift', '~> 20.0'
  pod 'BiometricAuthentication'
  
end

post_install do |installer|
   installer.pods_project.targets.each do |target|
     target.build_configurations.each do |config|
       config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
       config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
       config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
       config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = "YES"
       config.build_settings['SWIFT_SUPPRESS_WARNINGS'] = "YES"
     end
   end
 end
