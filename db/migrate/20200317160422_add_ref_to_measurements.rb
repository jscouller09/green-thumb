class AddRefToMeasurements < ActiveRecord::Migration[5.2]
  def change
    add_reference :measurements, :daily_summary, foreign_key: true
  end
end
