# tmd
class Queries::Projects::Orders::DoneRatioOrder < Queries::BaseOrder
  self.model = Project

  def self.key
    :done_ratio
  end

  private

  def order
     attribute = Project.order_by_done_ratio

     model.order("#{attribute} #{direction}")
  end
end

