module CloudwatchPoller
  module CloudWatch
    def cw
      @cw ||= AWS::CloudWatch.new
    end
  end
end
