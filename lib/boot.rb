require 'aws-sdk'
require 'celluloid'

require File.expand_path('../cloud_watch', __FILE__)
require File.expand_path('../metric_namespace', __FILE__)
require File.expand_path('../metric_poller', __FILE__)

AWS.config(
  access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
)

m = MetricNamespace.new("AWS/ELB")
Celluloid::Actor.join(m)
