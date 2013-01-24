require 'thor'

module CloudwatchPoller
  class CLI < Thor
    desc :start, "Start the poller in the foreground"
    def start
      app = Celluloid::SupervisionGroup.new do |group|
        #TODO configurable namespaces
        ["AWS/ELB"].collect do |namespace|
          group.supervise MetricNamespace, namespace
        end
      end
      Celluloid::Actor.join(app)
    end
  end
end
