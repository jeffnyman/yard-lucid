module YARD::CodeObjects::Lucid

  class NamespaceObject < YARD::CodeObjects::NamespaceObject
    include LocationHelper
    def value ; nil ; end
  end

  class Specifications < NamespaceObject ; end
  class FeatureTags < NamespaceObject ; end
  class StepTransformersObject < NamespaceObject ; end

  class FeatureDirectory < YARD::CodeObjects::NamespaceObject
    attr_accessor :description

    def initialize(namespace,name)
      super(namespace,name)
      @description = ""
    end

    def location
      files.first.first if files && !files.empty?
    end

    def expanded_path
      to_s.split('::')[1..-1].join('/')
    end

    def value ; name ; end

    def features
      children.find_all { |d| d.is_a?(Feature) }
    end

    def subdirectories
      subdirectories = children.find_all { |d| d.is_a?(FeatureDirectory) }
      subdirectories + subdirectories.collect { |s| s.subdirectories }.flatten
    end
  end

  LUCID_NAMESPACE = Specifications.new(:root, "specifications") unless defined?(LUCID_NAMESPACE)
  LUCID_TAG_NAMESPACE = FeatureTags.new(LUCID_NAMESPACE, "tags") unless defined?(LUCID_TAG_NAMESPACE)
  LUCID_STEPTRANSFORM_NAMESPACE = StepTransformersObject.new(LUCID_NAMESPACE, "step_transformers") unless defined?(LUCID_STEPTRANSFORM_NAMESPACE)
end
