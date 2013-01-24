require 'aws-sdk'
require 'celluloid'

require 'cloudwatch_poller/cloud_watch'

require 'cloudwatch_poller/metric_namespace'
require 'cloudwatch_poller/metric_poller'

AWS.config(
  access_key_id:     ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
)
