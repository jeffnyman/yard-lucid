def init
  super
  sections.push :specifications
  @namespace = object
end

def features
  @features ||= Registry.all(:feature)
end

def tags
  @tags ||= Registry.all(:tag).sort_by { |l| l.value.to_s }
end

def feature_directories
  @feature_directories ||= YARD::CodeObjects::Lucid::LUCID_NAMESPACE.children.find_all { |child| child.is_a?(YARD::CodeObjects::Lucid::FeatureDirectory) }
end

def feature_subdirectories
  @feature_subdirectories ||= Registry.all(:featuredirectory) - feature_directories
end

def step_transformers
  YARD::CodeObjects::Lucid::LUCID_STEPTRANSFORM_NAMESPACE
end

def step_definitions
  @step_definitions ||= YARD::Registry.all(:stepdefinition)
end

def transformers
  @transformers ||= YARD::Registry.all(:steptransform)
end

def undefined_steps
  @undefined_steps ||= Registry.all(:step).reject { |s| s.definition || s.scenario.outline? }
end

def alpha_table(objects)
  @elements = Hash.new

  objects = run_verifier(objects)
  objects.each { |o| (@elements[o.value.to_s[0,1].upcase] ||= []) << o }
  @elements.values.each { |v| v.sort! {|a,b| b.value.to_s <=> a.value.to_s } }
  @elements = @elements.sort_by { |l,o| l.to_s }

  @elements.each { |letter,objects| objects.sort! {|a,b| b.value.to_s <=> a.value.to_s } }
  erb(:alpha_table)
end
