# Uncomment the next line to define a global platform for your project
#platform :ios, '9.0'

target 'Sandsara' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Sandsara
  pod 'NVActivityIndicatorView'
  pod 'Kingfisher', '~> 5.0'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxDataSources', '~> 4.0'
  pod 'Moya'
  pod 'SwiftGen', '~> 6.0'
  pod 'BetterSegmentedControl', '~> 2.0'
  pod 'Bluejay', '~> 0.8'
  pod 'RxReachability'
  pod 'SVProgressHUD'
  pod 'RealmSwift', '~> 5.5.0'
  pod 'SnapKit', '~> 5.0.0'

  pod 'Firebase/Crashlytics'
  pod 'Firebase/Analytics'

  target 'SandsaraTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SandsaraUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=watchsimulator*]'] = 'arm64'
        config.build_settings['EXCLUDED_ARCHS[sdk=appletvsimulator*]'] = 'arm64'

      end
    end
  end

end
