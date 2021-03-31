# frozen_string_literal: true

module WithdrawsHelper
  def payed(obj)
    if obj
      'Yes'
    else
      'No'
    end
  end
end
