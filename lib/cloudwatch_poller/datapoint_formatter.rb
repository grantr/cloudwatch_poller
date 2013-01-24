module CloudwatchPoller
  class DatapointFormatter
    attr_accessor :datapoints

    def initialize(*datapoints)
      @datapoints = datapoints.flatten
    end

    def format
      @datapoints.collect do |point|
        format_point(point)
      end.join
    end

    def format_point(point)
      point_to_hash(point).collect do |k, v|
        "#{k}=#{v}"
      end.join(" ") + "\n"
    end


    def point_to_hash(point)
      {
        unit: point.unit,
        timestamp: point.timestamp.to_i,
        dimension: formatted_dimension(point.dimensions),
        period: 60,
        #value
        minimum: point.minimum,
        maximum: point.maximum,
        sum: point.sum,
        sample_count: point.sample_count,
        metric: formatted_metric_name(point.metric)
      }
    end

    def formatted_dimension(dimensions)
      dimensions.sort_by { |d| d[:name] }.collect do |d|
        escape(d[:value])
      end.join(".").downcase
    end

    def formatted_metric_name(metric)
      "#{escape(metric.namespace)}.#{escape(metric.name)}".downcase
    end

    def escape(string)
      string.gsub(/[^\w-]/, "_")
    end
  end
end
