class Plan < ApplicationRecord
    enum :interval, { monthly: 0, yearly: 1, lifetime: 2 }

    validates :name, presence: true
    validates :name, uniqueness: { case_sensitive: false }
    validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :description, presence: true
    validates :interval, presence: true
    validates :client_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :professional_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
    validates :appointments_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

    def price
        price_cents / 100.0
    end
end
