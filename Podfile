# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'PortraitCamera' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'CropViewController'
  pod 'ELCImagePickerController'
  pod 'DKImagePickerController'

  # Pods for PortraitCamera

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
        end
    end
end