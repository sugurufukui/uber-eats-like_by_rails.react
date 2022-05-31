module Api
  module V1
    class LineFoodsController < ApplicationController

      before_action :set_food, only: %i[create replace]

      def index
        line_foods = LineFood.active
        if line_foods.exists?
          render json: {
            line_food_ids: line_foods.map { |line_food| line_food.id },
            restaurant: line_foods.first.restaurant,
            count: line_foods.sum { |line_food| line_food[:count] },
            amount: line_foods.sum { |line_food| line_food.total_amount}
          }, status: :ok
          else
            render json: {}, status: :no_content
        end
      end

      def create
        if LineFood.active.other_restaurant(@ordered_food.restaurant.id).exists?
          return render json: {
            #他の店舗名を取得
            existing_restaurant: LineFood.other_restaurant(@ordered_food).first.restaurant.name,
            #今の店舗名を取得
            #Food.find(params[:food_id])を@ordered_foodに置き換えてみた
            new_restaurant: @ordered_food.restaurant.name,
          }, status: :not_acceptable
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food,
          }, status: :created
        else
          render json: {}, status: :internal_server_error
        end
      end

      def replace
        LineFood.active.other_restaurant(@ordered_food.restaurant.id).each do |line_food|
          #update_attribute(:active, false)をupdate!(active: false)にしてみた
          line_food.update!(active: false)
        end

        set_line_food(@ordered_food)

        if @line_food.save
          render json: {
            line_food: @line_food,
          }, status: :created
        else
          render json {}, status: :internal_server_error
        end
      end

        private
        def set_food
          @ordered_food = Food.find(params[:food_id])
        end

        def set_line_food(ordered_food)
          if ordered_food.line_food.present?
            #既に仮注文が有る場合
            @line_food = ordered_food.line_food
            @line_food.attributes = {
              count: ordered_food.line_food.count + params[:count],
              active: true
            }
          else
            #新しく仮注文に入れるときの処理
            @line_food = ordered_food.build_line_food(
              count: params[:count],
              restaurant: ordered_food.restaurant,
              active: true
            )
          end
        end
    end
  end
end
