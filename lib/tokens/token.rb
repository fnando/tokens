class Token < ActiveRecord::Base
  belongs_to :tokenizable, polymorphic: true
  serialize :data, JSON

  attr_readonly :tokenizable_id, :tokenizable_type

  def to_s
    token
  end

  def expired?
    expires_at && expires_at < Time.now
  end

  def self.clean
    where("expires_at < ? AND expires_at IS NOT NULL", Time.now).delete_all
  end
end
