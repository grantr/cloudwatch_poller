module CloudwatchPoller
  class DatapointFormatter
    attr_accessor :metric

    def initialize(metric)
      @metric = metric
    end

    def format(point)
      point_to_hash(point).collect do |k, v|
        "#{k}=#{v}"
      end.join(" ") + "\n"
    end

    def point_to_hash(point)
      {
        unit: point[:unit],
        timestamp: point[:timestamp].to_i,
        dimension: formatted_dimension,
        period: 60,
        #value
        minimum: point[:minimum],
        maximum: point[:maximum],
        sum: point[:sum],
        sample_count: point[:sample_count],
        metric: formatted_metric_name
      }
    end

    #TODO dimensions are empty because amazon doesn't return dimensions with datapoints
    def formatted_dimension
      metric.dimensions.sort_by { |d| d[:name] }.collect do |d|
        escape(d[:value])
      end.join(".").downcase
    end

    def formatted_metric_name
      "#{escape(metric.namespace)}.#{escape(metric.name)}".downcase
    end

    def escape(string)
      string.gsub(/[^\w-]/, "_")
    end
  end
end
