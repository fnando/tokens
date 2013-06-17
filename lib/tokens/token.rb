class Token < ActiveRecord::Base
  belongs_to :tokenizable, polymorphic: true
  serialize :data, JSON

  attr_readonly :tokenizable_id, :tokenizable_type

  def self.clean
    where("expires_at < ? AND expires_at IS NOT NULL", Time.now).delete_all
  end

  def data
    read_attribute(:data) || {}
  end

  def to_s
    token
  end

  def expired?
    expires_at && expires_at < Time.now
  end
end
