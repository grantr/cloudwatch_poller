require 'logger'
require 'cloudwatch_poller/datapoint_formatter'

module CloudwatchPoller
  class MetricPoller
    include Celluloid
    include CloudWatch

    attr_accessor :metric
    attr_reader :poll_interval
    attr_reader :poll_timer
    attr_reader :start_timer

    attr_reader :start_time

    def self.output
      # threadsafe logger
      @output ||= ::Logger.new(STDOUT)
    end

    def initialize(metric, options={})
      @metric = metric
      @options = options
      @start_time = options[:start_time]
      @period = options[:period] || 60
      self.poll_interval = options[:poll].nil? ? @period : options[:poll]
      async.poll unless options[:poll] == false
    end

    def add_dimension_group(dimensions)
      #TODO if we have subpollers, distribute to them
      metric.add_dimension_group(dimensions, @options)
    end

    #because datapoints need dimension information, we cannot poll multiple dimensions at once. we must poll every dimension group individually.
    # we can still use the recursion thing by specifying a maximum number of dimensions per poller.
    #
    # maximum data points returned: 1440
    # maximum data points queried: 50850
    def poll
      Logger.debug "polling #{metric.dimension_groups.size} dimension groups"

      metric.dimension_groups.each do |dimension_group|
        datapoints = dimension_group.datapoints

        dump(datapoints)
      end

      # if cloudwatch returns a 'too many metrics' error, split metrics into multiple arrays by dimension
      # spin up a metric poller for each dimension slice
      # stop the poll timer (let the subpollers handle it)
      # 
      # is the cloudwatch 'too many metrics' error separate from transient retryable errors?
    end

    def dump(datapoints)
      self.class.output << DatapointFormatter.new(datapoints).format
    end

    def poll_interval=(interval)
      @poll_interval = interval
      @poll_timer.cancel if @poll_timer
      @poll_timer = every(@poll_interval) { async.poll } if @poll_interval
    end
  end
end
