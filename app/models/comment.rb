class Comment < ApplicationRecord
    belongs_to :content
    belongs_to :user
    validates :comment,  presence: true 
end
