Pod::Spec.new do |spec|
  spec.name         = "DataProcessFlow"
  spec.version      = "0.1.0"
  spec.license      = "Apache License, Version 2.0"
  spec.summary      = "A short description of YourLibraryName."
  spec.homepage     = "https://gitlab.com/mohts/mental-health/hopes-study/hopes-ios-data-process-flow"
  spec.author       = "Azeem Muzammil"
  s.source          = { :git => "https://gitlab.com/mohts/mental-health/hopes-study/hopes-ios-data-process-flow.git", :branch => "fb-implement-data-process-flow" }
  spec.platform     = :ios, "14.0"
  spec.source_files  = "Sources/DataProcessFlow/**/*.{h,swift}"

  spec.dependency "Valet", "~> 4.2.0"
end
