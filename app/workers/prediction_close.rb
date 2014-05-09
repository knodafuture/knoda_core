class PredictionClose
  include Sidekiq::Worker

  def perform(prediction_id)
    puts "PERFORM PREDICTION CLOSE"
    ActiveRecord::Base.connection_pool.with_connection do
      Prediction.find(prediction_id).after_close
    end
  end
end
