3.times do |n|
  restaurant = Restaurant.new(
    name: "testレストラン_#{n+1}",
    fee: 100,
    time_required:10,
  )

  12.times do |m|
    restaurant.foods.build(
      name: "フード名_#{m+1}",
      price: 500,
      description: "フード_#{m+1}の説明文です。"
    )
  end

  restaurant.save!
end
