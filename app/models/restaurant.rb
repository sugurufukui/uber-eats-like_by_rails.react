class Restaurant < ApplicationRecord
  has_many :foods
  #特定の店舗がどんな仮注文を持っているか、Restaurantモデルから直接Orderモデルを参照することがないのでコメントアウト
  # has_many :line_foods, through: :foods

  validates :name, :fee, :time_required, presence: true
  validates :name, length: { maximum: 30 }
  validates :fee, numericality: { greater_than: 0 }
end
