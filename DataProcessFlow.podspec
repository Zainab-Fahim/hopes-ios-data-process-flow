Pod::Spec.new do |s|
  s.name     = 'DataProcessFlow'
  s.version  = '0.1.0'
  s.license  = 'Apache License, Version 2.0'
  s.summary  = 'This is the submovule for data collection of Hopes app.'
  s.homepage = 'https://github.com/Zainab-Fahim/hopes-ios-data-process-flow'
  s.authors  = 'Azeem Muzammil'
  s.source   = { :git => 'https://github.com/Zainab-Fahim/hopes-ios-data-process-flow.git', :tag => s.version }
  s.swift_version = '5.0'
  s.source_files = 'Sources/DataProcessFlow/**/*.{swift,h}'
  s.ios.deployment_target = '14.0'

  s.dependency "Valet", "~> 4.2.0"
end
