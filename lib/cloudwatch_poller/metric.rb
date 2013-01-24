module CloudwatchPoller
  class Metric
    attr_accessor :name, :namespace
    attr_accessor :dimension_groups

    def initialize(namespace, name)
      @namespace = namespace
      @name      = name
      @dimension_groups = []
    end

    def add_dimension_group(dimensions)
      @dimension_groups << DimensionGroup.new(self, dimensions)
    end

    # split the metric into multiple groups by dimension
    def split(factor)
      #TODO
    end
  end
end
