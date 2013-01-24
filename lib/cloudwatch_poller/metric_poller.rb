class MetricPoller
  include Celluloid
  include CloudWatch

  attr_accessor :namespace, :metric_name
  attr_reader :poll_interval
  attr_reader :poll_timer

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
    datapoints = metric.statistics(start_time: Time.now - 3600, end_time: Time.now, statistics: ['SampleCount']).datapoints

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
      #TODO thread safety
      puts format_datapoint(point)
    end
  end

  def format_datapoint(point)
    {
      unit: point[:unit],
      timestamp: point[:timestamp].to_i,
      #dimension: 
      period: 60,
      #value
      #minimum
      #maximum
      #sum
      sample_count: point[:sample_count],
      metric: "elb.#{metric_name}", #TODO metric name prefix, translator/underscore
    }.collect do |k, v|
      "#{k}=#{v}"
    end.join(" ")
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
