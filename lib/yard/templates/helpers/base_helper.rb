module YARD::Templates::Helpers
  module BaseHelper
    def format_object_title(object)
      if object.is_a?(YARD::CodeObjects::Lucid::FeatureTags)
        "Tags"
      elsif object.is_a?(YARD::CodeObjects::Lucid::StepTransformersObject)
        "Steps and Transforms"
      elsif object.is_a?(YARD::CodeObjects::Lucid::NamespaceObject)
        "#{format_object_type(object)}#{object.value ? ": #{object.value}" : ''}"
      elsif object.is_a?(YARD::CodeObjects::Lucid::FeatureDirectory)
        "Feature Directory: #{object.name}"
      else
        case object
        when YARD::CodeObjects::RootObject
          "Top Level Namespace"
        else
          format_object_type(object) + ": " + object.path
        end
      end
    end
  end
end
