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
    #TODO poll all metrics
    # if the time scale is longer than 60 seconds, split that if cloudwatch returns an error
    # 
    # if cloudwatch returns a 'too many metrics' error, split metrics into multiple arrays by dimension
    # spin up a metric poller for each dimension slice
    # stop the poll timer (let the subpollers handle it)
    # 
    # is the cloudwatch 'too meny metrics' error separate from transient retryable errors?
  end

  def poll_interval=(interval)
    @poll_interval = interval
    @poll_timer.cancel
    @poll_timer = every(@poll_interval) { async.poll }
  end
end
