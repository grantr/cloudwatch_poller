class MetricPoller
  include Celluloid

  attr_accessor :namespace, :metric_name
  attr_reader :refresh_interval, :poll_interval
  attr_reader :refresh_timer, :poll_timer

  #TODO optional dimensions, etc
  def initialize(namespace=nil, metric_name=nil, options={})
    @namespace = namespace
    @metric_name = metric_name
    @refresh_interval = options[:refresh_interval] || 300
    @poll_interval    = options[:poll_interval] || 60

    @refresh_timer = every(@refresh_interval) { refresh }
    @poll_timer    = every(@poll_interval) { poll }
  end

  def refresh
    Logger.debug "refreshing"
    metrics = []
    query = cw.metrics
    query = query.with_namespace(@namespace) if @namespace
    query = query.with_metric_name(@metric_name) if @metric_name

    # metric collection doesn't define #all or #collect
    query.each do |metric|
      metrics << metric
    end
    @metrics = metrics
  end

  def poll
    Logger.debug "polling"
    #TODO poll all metrics
    #batch them up
    #  if cloudwatch returns an error, split metrics into multiple arrays by dimension
    #  continue splitting the arrays until cloudwatch returns no error
    # 
    # also if the time scale is longer than 60 seconds, split that if cloudwatch returns an error
    # roll this behavior up into a class (this could also be an actor)
    # 
    # is the cloudwatch 'too meny metrics' error separate from transient retryable errors?
    # if cloudwatch returns an error
  end

  def metrics
    @metrics ||= []
  end

  def cw
    @cw ||= AWS::CloudWatch.new
  end

  def refresh_interval=(interval)
    @refresh_interval = interval
    @refresh_timer.cancel
    @refresh_timer = every(@refresh_interval) { refresh }
  end

  def poll_interval=(interval)
    @poll_interval = interval
    @poll_timer.cancel
    @poll_timer = every(@poll_interval) { poll }
  end
end
