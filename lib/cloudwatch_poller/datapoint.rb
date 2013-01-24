module CloudwatchPoller
  class Datapoint < Struct.new(:metric, :dimensions, :point)

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
