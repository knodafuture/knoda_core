class PredictionClose
  include SuckerPunch::Job
  @queue = :prediction_close

  def perform(prediction_id)
    ActiveRecord::Base.connection_pool.with_connection do
      Prediction.find(prediction_id).after_close
    end
  end
end