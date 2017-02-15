module Lucid
  module Parser
    class GherkinRepr < Gherkin::AstBuilder
      # This class serves as the Gherkin representation for each feature file
      # that is found. Specifically, the top level Feature object of each such
      # file is given a representation. The Gherkin parser calls the various
      # methods within in this class as it finds Gherkin-style elements.
      #
      # This process is similar to how most Gherkin tools generate an Abstract
      # Syntax Tree. Here what gets generated are various YARD::CodeObjects.
      #
      # A namespace is specified and that is the place in the YARD namespacing
      # where all features generated will reside. The namespace specified
      # is the root namespace. This is the equivalent of the top-level
      # directory holding all of the feature files.
      def initialize(file)
        super()
        @namespace = YARD::CodeObjects::Lucid::LUCID_NAMESPACE
        find_or_create_namespace(file)
        @file = file
      end

      # This method returns the feature that has been defined. This is the
      # final method that is called when all the work is done. What gets
      # returned is the complete Feature object that was built.
      def ast
        feature(get_result) unless @feature
        @feature
      end

      # Features that are found in sub-directories are considered to be in
      # another namespace. The rationale is that with Gherkin-supporting test
      # tools, when you execute a test run on a directory, any sub-directories
      # of features will be executed with that directory.
      #
      # Part of the process involves the discovery of a README.md file within
      # the specified directory of the feature file and loads that file as the
      # description for the namespace. This is useful if you want to give a
      # particular directory some supporting documentation.
      def find_or_create_namespace(file)
        @namespace = YARD::CodeObjects::Lucid::LUCID_NAMESPACE

        File.dirname(file).split('/').each do |directory|
          @namespace = @namespace.children.find { |child| child.is_a?(YARD::CodeObjects::Lucid::FeatureDirectory) && child.name.to_s == directory } ||
            @namespace = YARD::CodeObjects::Lucid::FeatureDirectory.new(@namespace,directory) { |dir| dir.add_file(directory) }
        end

        if @namespace.description == "" && File.exists?("#{File.dirname(file)}/README.md")
          @namespace.description = File.read("#{File.dirname(file)}/README.md")
        end
      end

      # A given tag can be searched for, within the YARD Registry, to see if it
      # exists and, if it doesn't, to create it. The logic will note that the
      # tag was used in the given file at whatever the current line is and then
      # add the tag to the current scenario or feature. It's also necessary to
      # add the feature or scenario to the tag.
      def find_or_create_tag(tag_name, parent)
        tag_code_object = YARD::Registry.all(:tag).find { |tag| tag.value == tag_name } ||
          YARD::CodeObjects::Lucid::Tag.new(YARD::CodeObjects::Lucid::LUCID_TAG_NAMESPACE,tag_name.gsub('@','')) { |t| t.owners = [] ; t.value = tag_name }

        tag_code_object.add_file(@file,parent.line)

        parent.tags << tag_code_object unless parent.tags.find { |tag| tag == tag_code_object }
        tag_code_object.owners << parent unless tag_code_object.owners.find { |owner| owner == parent }
      end

      # Each feature found will call this method, generating the feature object.
      # This happens only once, as the Gherkin parser does not allow for
      # multiple features per feature file.
      def feature(document)
        #log.debug "FEATURE"
        feature = document[:feature]
        return unless document[:feature]
        return if has_exclude_tags?(feature[:tags].map { |t| t[:name].gsub(/^@/, '') })

        @feature = YARD::CodeObjects::Lucid::Feature.new(@namespace,File.basename(@file.gsub('.feature','').gsub('.','_'))) do |f|
          f.comments = feature[:comments] ? feature[:comments].map{|comment| comment[:text]}.join("\n") : ''
          f.description = feature[:description] || ''
          f.add_file(@file,feature[:location][:line])
          f.keyword = feature[:keyword]
          f.value = feature[:name]
          f.tags = []

          feature[:tags].each {|feature_tag| find_or_create_tag(feature_tag[:name],f) }
        end
        feature[:children].each { |s|
          case s[:type]
            when :Background
              background(s)
            when :ScenarioOutline
              scenario_outline(s)
            when :Scenario
              scenario(s)
          end
      }
      end

      # Called when a Background has been found. Note that to Gherkin a
      # Background is really just another type of Scenario. The difference is
      # that backgrounds get special processing during execution.
      def background(background)
        @background = YARD::CodeObjects::Lucid::Scenario.new(@feature,"background") do |b|
          b.comments = background[:comments] ? background[:comments].map{|comment| comment.value}.join("\n") : ''
          b.description = background[:description] || ''
          b.keyword = background[:keyword]
          b.value = background[:name]
          b.add_file(@file,background[:location][:line])
        end

        @feature.background = @background
        @background.feature = @feature
        @step_container = @background
        background[:steps].each { |s| step(s) }
      end

      # Called when a scenario has been found. This will create a scenario
      # object, assign the scenario object to the feature object (and also
      # assigne the feature object to the scenario object), as well as find
      # or create tags that are associated with the scenario.
      #
      # The scenario is set as a type called a @step_container. This means
      # that any steps found before another scenario is defined belong to this
      # scenario.
      def scenario(statement)
        return if has_exclude_tags?(statement[:tags].map { |t| t[:name].gsub(/^@/, '') })

        scenario = YARD::CodeObjects::Lucid::Scenario.new(@feature,"scenario_#{@feature.scenarios.length + 1}") do |s|
          s.comments = statement[:comments] ? statement[:comments].map{|comment| comment.value}.join("\n") : ''
          s.description = statement[:description] || ''
          s.add_file(@file,statement[:location][:line])
          s.keyword = statement[:keyword]
          s.value = statement[:name]

          statement[:tags].each {|scenario_tag| find_or_create_tag(scenario_tag[:name],s) }
        end

        scenario.feature = @feature
        @feature.scenarios << scenario
        @step_container = scenario
        statement[:steps].each { |s| step(s) }
      end

      # Called when a scenario outline is found. This is very similar to a
      # scenario but, to Gherkin, the ScenarioOutline is still a distinct
      # object. The reason for this is because it can contain multiple
      # different example groups that can contain different values.
      def scenario_outline(statement)
        return if has_exclude_tags?(statement[:tags].map { |t| t[:name].gsub(/^@/, '') })

        outline = YARD::CodeObjects::Lucid::ScenarioOutline.new(@feature,"scenario_#{@feature.scenarios.length + 1}") do |s|
          s.comments = statement[:comments] ? statement[:comments].map{|comment| comment.value}.join("\n") : ''
          s.description = statement[:description] || ''
          s.add_file(@file,statement[:location][:line])
          s.keyword = statement[:keyword]
          s.value = statement[:name]

          statement[:tags].each {|scenario_tag| find_or_create_tag(scenario_tag[:name],s) }
        end

        outline.feature = @feature
        @feature.scenarios << outline
        @step_container = outline
        statement[:steps].each { |s| step(s) }
        statement[:examples].each { |e| examples(e) }
      end

      # Examples for a scenario outline are found. From a parsing perspective,
      # the logic differs here from how a Gherkin-supporting tool parses for
      # execution. For the needs of being lucid, each of the examples are
      # expanded out as individual scenarios and step definitions. This is done
      # so that it is possible to ensure that all variations of the scenario
      # outline defined are displayed.
      def examples(examples)
        example = YARD::CodeObjects::Lucid::ScenarioOutline::Examples.new(:keyword => examples[:keyword],
                                                                             :name => examples[:name],
                                                                             :line => examples[:location][:line],
                                                                             :comments => examples[:comments] ? examples.comments.map{|comment| comment.value}.join("\n") : '',
                                                                             :rows => []
          )
        example.rows = [examples[:tableHeader][:cells].map{ |c| c[:value] }] if examples[:tableHeader]
        example.rows += matrix(examples[:tableBody]) if examples[:tableBody]

        @step_container.examples << example

        # For each example data row, a new scenario must be generated using the
        # current scenario as the template.

        example.data.length.times do |row_index|

          # Generate a copy of the scenario.

          scenario = YARD::CodeObjects::Lucid::Scenario.new(@step_container,"example_#{@step_container.scenarios.length + 1}") do |s|
            s.comments = @step_container.comments
            s.description = @step_container.description
            s.add_file(@file,@step_container.line_number)
            s.keyword = @step_container.keyword
            s.value = "#{@step_container.value} (#{@step_container.scenarios.length + 1})"
          end

          # Generate a copy of the scenario steps.

          @step_container.steps.each do |step|
            step_instance = YARD::CodeObjects::Lucid::Step.new(scenario,step.line_number) do |s|
              s.keyword = step.keyword.dup
              s.value = step.value.dup
              s.add_file(@file,step.line_number)

              s.text = step.text.dup if step.has_text?
              s.table = clone_table(step.table) if step.has_table?
            end

            # Look at the particular data for the example row and do a simple
            # find and replace of the <key> with the associated values. It's
            # necessary ot handle empty cells in an example table.

            example.values_for_row(row_index).each do |key,text|
              text ||= ""
              step_instance.value.gsub!("<#{key}>",text)
              step_instance.text.gsub!("<#{key}>",text) if step_instance.has_text?
              step_instance.table.each{ |row| row.each { |col| col.gsub!("<#{key}>",text) } } if step_instance.has_table?
            end

            # Connect the steps that have been created to the scenario that was
            # created and then add the steps to the scenario.

            step_instance.scenario = scenario
            scenario.steps << step_instance
          end

          # Add the scenario to the list of scenarios maintained by the feature
          # and add the feature to the scenario.

          scenario.feature = @feature
          @step_container.scenarios << scenario
        end
      end

      # Called when a step is found. The logic here is that each step is
      # referred to a table owner. This is the case even though not all steps
      # have a table or multliline arguments associated with them.
      #
      # If a multiline string is present with the step it is included as the
      # text of the step. If the step has a table it is added to the step using
      # the same method used by the standard Gherkin model.
      def step(step)
        @table_owner = YARD::CodeObjects::Lucid::Step.new(@step_container,"#{step[:location][:line]}") do |s|
          s.keyword = step[:keyword]
          s.value = step[:text]
          s.add_file(@file,step[:location][:line])
        end

        @table_owner.comments = step[:comments] ? step[:comments].map{|comment| comment.value}.join("\n") : ''

        multiline_arg = step[:argument]

        case(multiline_arg[:type])
        when :DocString
          @table_owner.text = multiline_arg[:content]
        when :DataTable
          @table_owner.table = matrix(multiline_arg[:rows])
        end if multiline_arg

        @table_owner.scenario = @step_container
        @step_container.steps << @table_owner
      end

      # This is necessary because it is defined in many of the tooling that
      # supports Gherkin, but there are no events for the end-of-file.
      def eof
      end

      # This method exists when there is a syntax error. That matters for
      # Gherkin execution but not for the parsing being done here.
      def syntax_error(state, event, legal_events, line)
      end

      private

      def matrix(gherkin_table)
        gherkin_table.map {|gherkin_row| gherkin_row[:cells].map{ |cell| cell[:value] } }
      end

      # This helper method is used to deteremine what class is the current
      # Gherkin class.
      def gherkin_multiline_string_class
        if defined?(Gherkin::Formatter::Model::PyString)
          Gherkin::Formatter::Model::PyString
        elsif defined?(Gherkin::Formatter::Model::DocString)
          Gherkin::Formatter::Model::DocString
        else
          raise "Unable to find a suitable class in the Gherkin Library to parse the multiline step data."
        end
      end

      def clone_table(base)
        base.map {|row| row.map {|cell| cell.dup }}
      end

      def has_exclude_tags?(tags)
        if YARD::Config.options["yard-lucid"] and YARD::Config.options["yard-lucid"]["exclude_tags"]
          return true unless (YARD::Config.options["yard-lucid"]["exclude_tags"] & tags).empty?
        end
      end
    end
  end
end
