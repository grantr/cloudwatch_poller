require 'logger'
require 'benchmark'
require 'cloudwatch_poller/datapoint_formatter'

module CloudwatchPoller
  class MetricPoller
    include Celluloid
    include CloudWatch

    attr_accessor :metrics
    attr_reader :options
    attr_reader :poll_interval
    attr_reader :poll_timer
    attr_reader :start_timer

    attr_reader :start_time

    attr_accessor :period, :split_factor, :growth_factor

    def self.output
      # threadsafe logger
      @output ||= ::Logger.new(STDOUT)
    end

    def initialize(options={})
      @metrics = []
      @options = options
      @start_time = options[:start_time]
      @period = options[:period] || 60
      @growth_factor = options[:growth_factor] || 2

      # This is an unusually small split_factor just for the demo. 
      # I would set it at more like 0.5 in production.
      @split_factor = options[:split_factor] || 0.3
    end

    def add_metric(metric)
      if @split
        #if we have subpollers, distribute to them
        @subpollers.sample.add_metric(metric)
      else
        @metrics << metric
      end
    end

    def start(run_immediately=true)
      unless running?
        async.poll if run_immediately
        self.poll_interval = (@options[:poll] || @period)
      end
    end

    def running?
      !@poll_timer.nil?
    end

    #because datapoints need dimension information, we cannot poll multiple metrics at once. we must poll every dimension group individually.
    def poll
      Logger.debug "polling #{metrics.size} metrics"

      elapsed = Benchmark.realtime do
        metrics.each do |metric|
          datapoints = metric.advance

          dump(datapoints)
        end
      end

      Logger.debug "polling took #{elapsed} seconds"

      # if elapsed gets too close to the period, split into multiple pollers
      #TODO if polling takes too little time, shrink
      # shrinking is harder because it must be recursive
      if elapsed > (@period * @split_factor)
        Logger.debug("polling took longer than #{@period * @split_factor} seconds, splitting")
        split
      end
    end

    def dump(datapoints)
      self.class.output << DatapointFormatter.new(datapoints).format
    end

    def split
      unless @split
        Logger.debug("Splitting into #{@growth_factor} pollers")
        @split = true

        # stop the poll timer
        @poll_timer.cancel

        # split metrics into N subgroups
        metric_subgroups = @growth_factor.times.collect { [] }
        @metrics.each_with_index { |e, i| metric_subgroups[i % @growth_factor] << e }

        # assign each subgroup to a subpoller
        @subpollers = metric_subgroups.collect do |subgroup|
          self.class.new_link(@options).tap do |poller|
            subgroup.each { |group| poller.add_metric(group) }
          end
        end

        # start pollers, but don't start polling until the next cycle
        @subpollers.each { |p| p.start(false) }

        @metrics.clear
      else
        Logger.debug("Tried to split, but already did")
        @split = true
      end

    end

    def poll_interval=(interval)
      @poll_interval = interval
      @poll_timer.cancel if @poll_timer
      @poll_timer = every(@poll_interval) { async.poll } if @poll_interval
    end
  end
end
