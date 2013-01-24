module CloudwatchPoller
  class Datapoint

    attr_accessor :namespace, :name
    attr_accessor :dimensions, :point

    def initialize(metric, point)
      @namespace = metric.namespace
      @name = metric.name
      @dimensions = metric.dimensions
      @point = point
    end

    def unit
      point[:unit]
    end

    def timestamp
      point[:timestamp]
    end

    def sample_count
      point[:sample_count]
    end

    def minimum
      point[:minimum]
    end

    def maximum
      point[:maximum]
    end

    def sum
      point[:sum]
    end

    def average
      point[:average]
    end
  end
end
