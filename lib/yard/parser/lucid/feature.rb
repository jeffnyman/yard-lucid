require "yard"

module YARD::Parser::Lucid
  class FeatureParser < YARD::Parser::Base
    # Each feature found creates a new FeatureParser.
    #
    # A Gherkin "builder" is created that will store a representation of the
    # feature file. That feature file is then sent to the Gherkin parser.
    # The Lucid::Parser::GherkinRepr is being used to parse the elements of
    # the faeture file into YARD::CodeObjects.
    def initialize(source, file = '(stdin)')
      @builder = Lucid::Parser::GherkinRepr.new(file)
      @tag_counts = {}
      @parser = Gherkin::Parser.new(@builder)

      @source = source
      @file = file

      @feature = nil
    end

    # When parse is called, the Gherkin parser is executed and all the feature
    # elements that are found are sent to the various methods in the
    # Lucid::Parser::GherkinRepr. The result of this is a syntax tree
    # representation of the feature that contains all the scenarios and steps.
    def parse
      begin
        @parser.parse(@source)
        @feature = @builder.ast
        return nil if @feature.nil?

        # The parser used the following keywords when parsing the feature
        # @feature.language = @parser.i18n_language.get_code_keywords.map {|word| word }

      rescue Gherkin::ParserError => e
        e.message.insert(0, "#{@file}: ")
        warn e
      end

      self
    end

    # While the method is necessary, nothing actually happens here because all
    # of the work is done in the parse method.
    def tokenize
    end

    # The only enumeration that can be done at this level is the feature
    # itself. There is no construct higher than a feature wherein a feature
    # can be enumerated.
    def enumerator
      [@feature]
    end
  end

  # Register all feature files to be processed with the above FeatureParser
  YARD::Parser::SourceParser.register_parser_type :feature, FeatureParser, 'feature'
end
