module CloudwatchPoller
  # stores a list of dimensions and queries them
  class DimensionGroup
    attr_accessor :metric, :dimensions

    def initialize(metric, dimensions=[])
      @metric = metric
      @dimensions = dimensions
    end

    def datapoints(start_time, end_time, statistics)
      #TODO check for dimensions > 10
      #TODO if the time scale is longer than 60 seconds, split that if cloudwatch returns an error
      datapoints = cw_metric.statistics(
        start_time: start_time, 
        end_time: end_time, 
        statistics: statistics, 
        dimensions: dimensions
      ).datapoints

      datapoints.collect { |point| Datapoint.new(metric, dimensions, point) }
    end
    
    def cw_metric
      @cw_metric ||= AWS::CloudWatch::Metric.new(
        metric.namespace,
        metric.name,
        dimensions: dimensions
      )
    end
  end
end
