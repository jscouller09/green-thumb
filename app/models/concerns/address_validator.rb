class AddressValidator < ActiveModel::Validator
  def validate(record)
    unless record.geocode_address!
      record.errors.add(:address, "'#{record.address}' is not a valid address")
    end
  end
end
