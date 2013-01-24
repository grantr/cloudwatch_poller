require 'logger'
require 'cloudwatch_poller/datapoint_formatter'

module CloudwatchPoller
  class MetricPoller
    include Celluloid
    include CloudWatch

    attr_accessor :namespace, :metric_name
    attr_reader :poll_interval
    attr_reader :poll_timer

    def self.output
      # threadsafe logger
      @output ||= ::Logger.new(STDOUT)
    end

    #TODO optional dimensions
    def initialize(namespace, metric_name, options={})
      @namespace     = namespace
      @metric_name   = metric_name
      @poll_interval = options[:poll_interval] || 60
      @poll_timer    = every(@poll_interval) { async.poll }
      async.poll
    end

    def poll
      Logger.debug "polling"
      datapoints = metric.statistics(start_time: Time.now - 3600, end_time: Time.now, statistics: ['SampleCount', 'Minimum', 'Maximum', 'Sum']).datapoints

      dump(datapoints)
      #TODO poll all metrics
      # if the time scale is longer than 60 seconds, split that if cloudwatch returns an error
      # 
      # if cloudwatch returns a 'too many metrics' error, split metrics into multiple arrays by dimension
      # spin up a metric poller for each dimension slice
      # stop the poll timer (let the subpollers handle it)
      # 
      # is the cloudwatch 'too many metrics' error separate from transient retryable errors?
    end

    def dump(datapoints)
      datapoints.each do |point|
        self.class.output << formatter.format(point)
      end
    end

    def formatter
      @formatter ||= DatapointFormatter.new(metric)
    end

    def metric
      @metric ||= AWS::CloudWatch::Metric.new(@namespace, @metric_name)
    end

    def poll_interval=(interval)
      @poll_interval = interval
      @poll_timer.cancel
      @poll_timer = every(@poll_interval) { async.poll }
    end
  end
end
