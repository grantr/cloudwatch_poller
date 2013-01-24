module CloudwatchPoller
  # stores a list of dimensions and queries them
  class DimensionGroup
    attr_accessor :metric, :dimensions
    attr_accessor :next_time, :period

    def initialize(metric, dimensions=[], options={})
      @metric = metric
      @dimensions = dimensions
      @next_time = options[:start_time] || Time.now
      @period = options[:period] || 60
    end

    def advance(options={})
      datapoints(options).tap do
        @next_time = end_time + period
      end
    end

    def datapoints(options={})
      #TODO check for dimensions > 10
      #TODO if the time scale is longer than period, split that if cloudwatch returns an error

      datapoints = cw_metric.statistics(
        start_time: options[:start_time] || next_time - period, 
        end_time: options[:end_time] || next_time, 
        statistics: options[:statistics] || ['Sum', 'SampleCount', 'Minimum', 'Maximum'], 
        dimensions: dimensions
      ).datapoints

      datapoints.collect { |point| Datapoint.new(metric, dimensions, point) }
    end
    
    # should this move to Datapoint?
    def cw_metric
      @cw_metric ||= AWS::CloudWatch::Metric.new(
        metric.namespace,
        metric.name,
        dimensions: dimensions
      )
    end
  end
end
