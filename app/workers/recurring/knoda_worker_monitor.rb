class Recurring::KnodaWorkerMonitor
  include Sidekiq::Worker

  def perform
    retry_queue = Sidekiq::RetrySet.new
    if retry_queue.size > 0
      MonitoringMailer.retryQueue.deliver
    end
  end
end
