module CloudwatchPoller
  class MetricNamespace
    include Celluloid
    include CloudWatch

    attr_accessor :namespace
    attr_reader :refresh_interval
    attr_reader :refresh_timer

    # options[:refresh] = false will disable refresh
    def initialize(namespace, options={})
      @namespace = namespace
      self.refresh_interval = options[:refresh].nil? ? 300 : options[:refresh]
      async.refresh unless options[:refresh] == false
    end

    def refresh
      Logger.debug "refreshing"
      query = cw.metrics.with_namespace(@namespace)

      query.each do |metric|
        #TODO might be better to link and trap_exit
        poller = metric_pollers[metric.metric_name] ||= MetricPoller.supervise(Metric.new(@namespace, metric.metric_name))

        poller.add_dimension_group(metric.dimensions)
      end
    end

    def refresh_interval=(interval)
      @refresh_interval = interval
      @refresh_timer.cancel if @refresh_timer
      @refresh_timer = every(@refresh_interval) { async.refresh } if @refresh_interval
    end

    def metric_pollers
      @metric_pollers ||= {}
    end
  end
end
