module YARD::CodeObjects::Lucid
  class Step < Base
    attr_accessor :comments, :definition, :examples, :keyword, :scenario, :table, :text, :transforms, :value

    def initialize(namespace,name)
      super(namespace,name.to_s.strip)
      @comments = @definition = @description = @keyword = @table = @text = @value = nil
      @examples = {}
      @transforms = []
    end

    def has_table?
      !@table.nil?
    end

    def has_text?
      !@text.nil?
    end

    def definition=(stepdef)
      @definition = stepdef

      unless stepdef.steps.map(&:files).include?(files)
        stepdef.steps << self
      end
    end

    def transformed?
      !@transforms.empty?
    end
  end
end
