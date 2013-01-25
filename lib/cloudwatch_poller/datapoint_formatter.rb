module CloudwatchPoller
  #TODO define subclasses of this for custom formatting needs
  class DatapointFormatter
    attr_accessor :datapoints

    #TODO maybe this should be part of a datapoint class?
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
        dimension: formatted_dimension(point),
        period: 60,
        #value
        minimum: point.minimum,
        maximum: point.maximum,
        sum: point.sum,
        sample_count: point.sample_count,
        metric: formatted_metric_name(point)
      }
    end

    def formatted_dimension(point)
      point.dimensions.sort_by { |d| d[:name] }.collect do |d|
        escape(d[:value])
      end.join(".").downcase
    end

    def formatted_metric_name(point)
      "#{escape(point.namespace)}.#{escape(point.name)}".downcase
    end

    def escape(string)
      string.gsub(/[^\w-]/, "_")
    end
  end
end
