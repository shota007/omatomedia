class Category < ApplicationRecord
    has_many :contents, dependent: :nullify
    belongs_to :category, optional: true
end
