Pod::Spec.new do |s|
  s.name         = "PageSegmentView"
  s.version      = "1.0.4"
  s.summary      = "页面滑动转换器"
  s.description  = "左右滑动切换页面，TabBar支持小红点显示。"
  s.homepage     = "https://github.com/HaiTeng-Wang/PageSegment"
  s.license      = { :type => 'MIT'}
  s.author       = { "Hunter" => "https://HaiTeng-Wang.github.io" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/HaiTeng-Wang/PageSegment.git", :tag => s.version }
  s.source_files = "PageSegment/PageSegment/PageSegmentView/*.{h,m}"
  s.resource     = 'PageSegment/PageSegment/PageSegmentView/PageSegmentView.bundle'
  s.requires_arc = true
end
