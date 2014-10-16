Factory.define :node, :class => Dradis::Core::Node do |f|
  f.label "Node-#{Time.now.to_i}"
  f.parent_id nil 
end

Factory.define :note, :class => Dradis::Core::Note do |f|
  f.text "Note text at #{Time.now}"
  f.author "factory-girl"
  f.association :category
  f.association :node
end

Factory.define :issue, :class => Dradis::Core::Issue do |f|
  f.text "Issue text at #{Time.now}"
  f.author "factory-girl"
  f.association :category
  f.node { Dradis::Core::Node.issue_library }
end

Factory.define :evidence, :class => Dradis::Core::Evidence do |f|
  f.content "Evidence text at #{Time.now}"
  f.author "factory-girl"
  f.association :node
  f.association :issue
end

Factory.define :category, :class => Dradis::Core::Category do |f|
  f.sequence(:name){ |n| "Category ##{n}" }
end
 
