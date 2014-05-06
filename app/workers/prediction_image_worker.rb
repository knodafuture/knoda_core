class PredictionImageWorker
  include Sidekiq::Worker
  @queue = :prediction_image_builder

  def perform(prediction_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Prediction.find(prediction_id).build_image()
      prediction = prediction.find(prediction_id)
      puts prediction.to_json
      puts prediction.user.to_json
    end
  end
end
