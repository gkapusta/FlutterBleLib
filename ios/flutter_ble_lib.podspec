#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_ble_lib'
  s.version          = '2.3.2'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h' 
  s.dependency 'Flutter'
  s.swift_versions = ['4.0', '4.2', '5.0']
  s.dependency 'MultiplatformBleAdapter', '~> 0.1.8'

  s.ios.deployment_target = '8.0'
end

