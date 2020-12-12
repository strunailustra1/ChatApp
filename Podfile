platform :ios, '12.0'

target 'ChatApp' do
    use_frameworks!

    pod 'Firebase/Firestore', '~> 6.32'
    pod 'SwiftLint', '~> 0.40'

    target 'ChatAppTests' do
        inherit! :search_paths
        pod 'Firebase/Firestore', '~> 6.32'
    end

    target 'ChatAppUITests' do
        use_frameworks!
        pod 'Firebase/Firestore', '~> 6.32'
        pod 'iOSSnapshotTestCase', '~> 6.2'
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end
