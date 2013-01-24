require 'thor'

module CloudwatchPoller
  class CLI < Thor
    desc :start, "Start the poller in the foreground"
    def start
      #TODO one per namespace
      namespaces = ["AWS/ELB"].collect do |namespace|
        MetricNamespace.supervise(namespace)
      end
      
      namespaces.each { |n| Celluloid::Actor.join(n) }
    end
  end
end
