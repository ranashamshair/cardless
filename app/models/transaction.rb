class Transaction < ApplicationRecord

    enum action: {transfer: 0, issue: 1, retire: 2}
    enum status: {pending: 0, success: 1}
    enum main_type: {sale: 0, withdraw: 1, customer_issue: 2, reserve: 3, reserve_return: 4, sale_fee: 5, withdraw_fee: 6}

    belongs_to :sender, class_name: "User", foreign_key: :sender_id, optional: true
    belongs_to :receiver, class_name: "User", foreign_key: :receiver_id, optional: true
end
