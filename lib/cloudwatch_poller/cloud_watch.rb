module CloudWatch
  def cw
    @cw ||= AWS::CloudWatch.new
  end
end
