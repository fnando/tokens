class Token < ActiveRecord::Base
  belongs_to :tokenizable, :polymorphic => true
  
  def hash
    token
  end
  
  def expired?
    return true if expires_at && expires_at < Time.now
    return false
  end
  
  def self.delete_expired
    delete_all ["expires_at < ? AND expires_at IS NOT NULL", Time.now] 
  end
end