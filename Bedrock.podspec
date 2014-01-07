Pod::Spec.new do |s|
  s.name      = 'Bedrock'
  s.version   = '0.0.2'
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.summary   = 'Bedrock is a collection of useful Mac and iOS utilities.'
  s.homepage  = 'https://github.com/nickbolton/Bedrock'
  s.requires_arc = true 
  s.author    = { 'nickbolton' => 'nick@deucent.com' }             
  s.source    = { :git => 'https://github.com/nickbolton/Bedrock.git',
                  :branch => 'master'}
  s.osx.source_files  = 'Shared/**/*.{h,m}', 'Mac/**/*.{h,m}'
  s.ios.source_files  = 'Shared/**/*.{h,m}', 'iOS-Core/**/*.{h,m}'
  s.prefix_header_file = 'Bedrock.h'
  s.license = 'MIT'

  s.subspec 'AutoLayout' do |al|
    al.ios.source_files  = 'AutoLayout/**/*.{h,m}'
  end

  s.subspec 'Emitter' do |em|
    em.ios.source_files  = 'Emitter/**/*.{h,m}'
    em.ios.resources = 'Emitter/EmitterList/PBListCell.xib', 'Emitter/EmitterList/PBTitleCell.xib'
  end
end
