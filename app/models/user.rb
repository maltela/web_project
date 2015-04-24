class User < ActiveRecord::Base
  has_many :messages, :class_name => 'Message', :foreign_key => 'recipient_id'
end
