Pod::Spec.new do |spec|
  spec.name         = "DataProcessFlow"
  spec.version      = "0.1.0"
  spec.license      = "Apache License, Version 2.0"
  spec.summary      = "This is the submovule for data collection of Hopes app."
  spec.homepage     = "https://github.com/Zainab-Fahim/hopes-ios-data-process-flow"
  spec.author       = "Azeem Muzammil"
  spec.source          = { :git => "https://github.com/Zainab-Fahim/hopes-ios-data-process-flow.git", :tag => "#{spec.version}" }
  spec.platform     = :ios, "14.0"
  spec.source_files  = "Sources/DataProcessFlow/**/*.{h,swift}"

  spec.dependency "Valet", "~> 4.2.0"
end
