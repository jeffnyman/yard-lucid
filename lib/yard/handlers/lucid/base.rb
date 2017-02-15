module YARD
  module Handlers
    module Lucid
      class Base < Handlers::Base
        class << self
          include Parser::Lucid
          def handles?(node)
            handlers.any? do |a_handler|
              node.class == a_handler
            end
          end
          include Parser::Lucid
        end
      end

      Processor.register_handler_namespace :feature, Lucid
    end
  end
end
