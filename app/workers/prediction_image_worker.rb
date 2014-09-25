class PredictionImageWorker
  include Sidekiq::Worker

  def perform(prediction_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Prediction.find(prediction_id).build_image()
    end
  end
end
