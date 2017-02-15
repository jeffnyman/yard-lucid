module YARD
  module Handlers
    module Lucid
      class FeatureHandler < Base
        handles CodeObjects::Lucid::Feature

        # This method is currently not needed. It would be needed if there was
        # further processing to be done on the features.
        def process
        end

        # Register, once, when all files are finished. This will trigger the
        # final matching of feature steps to step definitions and steps to
        # transforms.
        YARD::Parser::SourceParser.after_parse_list do |files,globals|
          YARD::Registry.all(:feature).each do |feature|
            FeatureHandler.match_steps_to_step_definitions(feature)
          end
        end

        class << self
          @@step_definitions = nil
          @@step_transforms = nil

          def match_steps_to_step_definitions(statement)
            # Create a cache of all of the steps and the transforms.
            @@step_definitions = cache(:stepdefinition) unless @@step_definitions
            @@step_transforms = cache(:steptransform) unless @@step_transforms

            if statement
              # For the background and the scenario, find the steps that have
              # definitions.
              process_scenario(statement.background) if statement.background

              statement.scenarios.each do |scenario|
                if scenario.outline?
                  scenario.scenarios.each_with_index do |example,index|
                    process_scenario(example)
                  end
                else
                  process_scenario(scenario)
                end
              end
            else
              log.warn "Empty feature file. A feature failed to process correctly or contains no feature"
            end

          rescue YARD::Handlers::NamespaceMissingError
          rescue Exception => exception
            log.error "Skipping feature because an error has occurred."
            log.debug "\n#{exception}\n#{exception.backtrace.join("\n")}\n"
          end

          # The cache is used to store all comparable items with their
          # compare_value as the key and the item as the value. This will
          # reject any compare values that contain escapes -- #{} -- because
          # that means the values have unpacked constants.
          def cache(type)
            YARD::Registry.all(type).inject({}) do |hash,item|
              hash[item.regex] = item if item.regex
              hash
            end
          end

          def process_scenario(scenario)
            scenario.steps.each {|step| process_step(step) }
          end

          def process_step(step)
            match_step_to_step_definition_and_transforms(step)
          end

          # Given a step object, attempt to match that step to a transform.
          def match_step_to_step_definition_and_transforms(step)
            @@step_definitions.each_pair do |stepdef,stepdef_object|
              stepdef_matches = step.value.match(stepdef)

              if stepdef_matches
                step.definition = stepdef_object
                stepdef_matches[-1..1].each do |match|
                  @@step_transforms.each do |steptrans,steptransform_object|
                    if steptrans.match(match)
                      step.transforms << steptransform_object
                      steptransform_object.steps << step
                    end
                  end
                end

                # A this point the step has been matched to the definition and
                # to any transforms. As a design note, if the step were to
                # match again, it would be possible to display any steps that
                # are considered ambiguous.
                # This would be a nice to have.
                break
              end
            end
          end
        end
      end
    end
  end
end
