class Token < ActiveRecord::Base
  belongs_to :tokenizable, :polymorphic => true
  serialize :data

  def to_s
    token
  end

  def expired?
    expires_at && expires_at < Time.now
  end

  def self.clean
    delete_all ["expires_at < ? AND expires_at IS NOT NULL", Time.now]
  end
end
