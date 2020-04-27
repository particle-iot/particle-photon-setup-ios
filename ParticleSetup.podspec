Pod::Spec.new do |s|
    s.name             = "ParticleSetup"
    s.version          = "1.0.4"
    s.summary          = "Particle iOS Photon Setup library for easy integration of setup process for Particle Photon devices in your app"
    s.description      = <<-DESC
                        Particle (formerly Spark) Photon Setup library for integrating a customized setup process of Particle Photon (Wifi) devices in your app
                        This library will allow you to easily invoke a standalone setup wizard UI for setting up
                        Particle devices (photon/P1) from within your app. Setup UI look & feel can be easily customized with custom brand
                        logos/colors/fonts/texts and instructional video. Further customization can be done by directly modifying the setup.storyboard file.
                        DESC
    s.homepage         = "https://github.com/particle-iot/particle-photon-setup-ios"
    s.screenshots      = "https://github.com/particle-iot/particle-photon-setup-ios/raw/master/particle-mark.png"
    s.license          = 'Apache 2.0'
    s.author           = { "Particle" => "ido@particle.io" }
    s.source           = { :git => "https://github.com/particle-iot/particle-photon-setup-ios.git", :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/particle'

    s.platform     = :ios, '9.0'
    s.requires_arc = true

    s.public_header_files = 'ParticleSetup/*.h'
    s.source_files  = 'ParticleSetup/*.h'

    s.resource_bundle = {'ParticleSetup' => 'ParticleSetupResources/**/*.{xcassets,storyboard,strings}'}

    s.subspec 'Core' do |core|
        core.source_files  = 'ParticleSetup/User/**/*.{h,m}', 'ParticleSetup/UI/**/*'
        core.dependency 'Particle-SDK'
        core.dependency '1PasswordExtension'
        core.dependency 'ParticleSetup/Comm'
        core.ios.frameworks    = 'UIKit'
    end

    s.subspec 'Comm' do |comm|
        comm.source_files  = 'ParticleSetup/Comm/**/*'
        comm.ios.frameworks    = 'SystemConfiguration', 'Security'
    end



end
