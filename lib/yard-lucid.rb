require "gherkin/parser"

require "yard-lucid/version"

require "lucid/gherkin_repr"

require "yard/parser/lucid/feature"

require "yard/code_objects/lucid/base"
require "yard/code_objects/lucid/namespace_object"
require "yard/code_objects/lucid/feature"
require "yard/code_objects/lucid/scenario_outline"
require "yard/code_objects/lucid/scenario"
require "yard/code_objects/lucid/step"
require "yard/code_objects/lucid/tag"
require "yard/code_objects/step_transformer"
require "yard/code_objects/step_definition"
require "yard/code_objects/step_transform"

require "yard/handlers/lucid/base"
require "yard/handlers/lucid/feature_handler"
require "yard/handlers/step_definition_handler"
require "yard/handlers/step_transform_handler"

require "yard/templates/helpers/base_helper"

# This registered template works for yardoc
YARD::Templates::Engine.register_template_path File.dirname(__FILE__) + '/templates'
