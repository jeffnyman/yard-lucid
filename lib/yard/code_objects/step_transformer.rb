module YARD::CodeObjects
  class StepTransformerObject < Base

    include Lucid::LocationHelper

    attr_reader :constants, :keyword, :source, :value, :literal_value
    attr_accessor :steps, :pending, :substeps

    # This defines an escape pattern within a string or regex:
    #     /^the first #{CONSTANT} step$/
    #
    # This is used below in the value to process it if there happen to be
    # constants defined here. It's important to note that this will not
    # handle the result of method calls and it will not handle multiple
    # constants within the same escaped area.
    def escape_pattern
      /#\{\s*(\w+)\s*\}/
    end

    # The idea of this is method is that when requesting a step tranform object
    # value, process it, if it hasn't alredy been processed, replacing any
    # constants that may be escaped within the value.
    #
    # Processing here means looking for any escaped characters that happen to
    # be CONSTANTS that could be matched and then replaced. This needs to be
    # done recursively since CONSTANTS can be defined with more CONSTANTS.
    def value
      unless @processed
        @processed = true
        until (nested = constants_from_value).empty?
          nested.each { |n| @value.gsub!(value_regex(n),find_value_for_constant(n)) }
        end
      end

      @value
    end

    # Set the literal value and the value of the step definition.
    #
    # The literal value is as it appears in the step definition file with any
    # constants. The value, when retrieved will attempt to replace those
    # constants with their regex or string equivalents to hopefully match more
    # steps and step definitions.
    def value=(value)
      @literal_value = format_source(value)
      @value = format_source(value)

      @steps = []
      value
    end

    # Generate a regex with the step transform value.
    def regex
      @regex ||= /#{strip_regex_from(value)}/
    end

    # Look through the specified data for the escape pattern and return an
    # array of those constants found. This defaults to the @value within the
    # step transform as it is used internally, however, it can be called
    # externally if it's needed somewhere.
    def constants_from_value(data=@value)
      data.scan(escape_pattern).flatten.collect { |value| value.strip }
    end

    protected

    # This looks through all the constants in the registry and returns the value
    # with the regex items replaced from the constnat if present.
    def find_value_for_constant(name)
      constant = YARD::Registry.all(:constant).find { |c| c.name == name.to_sym }
      log.warn "StepTransformer#find_value_for_constant : Could not find the CONSTANT [#{name}] using the string value." unless constant
      constant ? strip_regex_from(constant.value) : name
    end

    # Return a regex of the value.
    def value_regex(value)
      /#\{\s*#{value}\s*\}/
    end

    # Strip the regex starting / and ending / from the value.
    def strip_regex_from(value)
      value.gsub(/^\/|\/$/,'')
    end
  end
end
