module CloudwatchPoller
  # stores a list of dimensions and queries them
  class Metric
    attr_accessor :namespace, :name, :dimensions
    attr_accessor :next_time, :period

    def initialize(namespace, name, dimensions=[], options={})
      @namespace = namespace
      @name = name
      @dimensions = dimensions
      @next_time = options[:start_time] || Time.now
      @period = options[:period] || 60
    end

    def advance(options={})
      datapoints(options).tap do
        @next_time = (options[:end_time] || next_time) + period
      end
    end

    def datapoints(options={})
      #TODO check for dimensions > 10 (cloudwatch max)

      begin
        datapoints = cw_metric.statistics(
          start_time: options[:start_time] || next_time - period,
          end_time: options[:end_time] || next_time,
          statistics: options[:statistics] || ['Sum', 'SampleCount', 'Minimum', 'Maximum'],
          dimensions: dimensions
        ).datapoints
      #TODO handle more errors
      rescue AWS::CloudWatch::Errors::InvalidParameterCombination => e
        if e.message =~ /exceeds the limit/
          #TODO if the time scale is longer than period, try again with a shorter time
          # can't decrease the number of dimensions because this is already an atomic metric
          raise e
        else
          raise e
        end
      end

      datapoints.collect { |point| Datapoint.new(self, point) }
    end
    
    # should this move to Datapoint?
    def cw_metric
      @cw_metric ||= AWS::CloudWatch::Metric.new(
        @namespace,
        @name,
        dimensions: @dimensions
      )
    end
  end
end
