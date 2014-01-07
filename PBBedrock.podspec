Pod::Spec.new do |s|
  s.name      = 'PBBedrock'
  s.version   = '0.0.2'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.summary   = 'PBBedrock is a collection of useful Mac and iOS utilities.'
  s.homepage  = 'https://github.com/nickbolton/PBBedrock'
  s.requires_arc = true 
  s.author    = { 'nickbolton' => 'nick@deucent.com' }             
  s.source    = { :git => 'https://github.com/nickbolton/PBBedrock.git',
                  :branch => 'master'}
  s.osx.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'Mac', 'Mac/**/*.{h,m}'
  s.ios.source_files  = '*.{h,m}', 'Shared', 'Shared/**/*.{h,m}', 'iOS', 'iOS/**/*.{h,m}'
  s.ios.resources = 'iOS/ListView/PBListCell.xib', 'iOS/ListView/PBTitleCell.xib'
  s.prefix_header_file = 'PBBedrock.h'
  s.license = 'MIT'
end
