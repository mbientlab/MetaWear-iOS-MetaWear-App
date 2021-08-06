# Uncomment this line to define a global platform for your project
use_frameworks!

target 'MetaWearApp' do
  platform :ios, '14.5'
  pod 'MetaWear', :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']
  pod 'AAInfographics', :git => 'https://github.com/AAChartModel/AAChartKit-Swift.git'
  pod 'StaticDataTableViewController'
end


target 'MetaWearMac' do
  platform :osx, '11.5'
  pod 'MetaWear', :subspecs => ['UI', 'AsyncUtils', 'Mocks', 'DFU']
end
