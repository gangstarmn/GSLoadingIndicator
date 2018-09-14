 Pod::Spec.new do |s|
  s.name         = "GSLoadingIndicator"
  s.version      = "0.2.1"
  s.summary      = "GSLoadingIndicator is a loading indicator"
  s.description  = <<-DESC
                    GSLoadingIndicator is loading indicator. It's looks like android material design and cool.
                   DESC
  s.homepage     = "https://github.com/gangstarmn/GSLoadingIndicator"
  s.license      = "MIT"
  s.author             = { "Gantulga" => "gangstarmn@gmail.com" }
  s.platform = :ios, '8.0'
  s.source = { :git => 'https://github.com/gangstarmn/GSLoadingIndicator.git', :tag => "#{s.version}" }
  
  s.source_files = "GSLoadingIndicator/**/*.{h,m}"
    
  s.framework = 'UIKit'
  s.requires_arc = true
  end