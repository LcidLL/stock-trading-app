module AdminPanel
  class TraderCommentsController < ApplicationController
    def create
      @trader = Trader.find(params[:trader_id])
      @comment = @trader.comments.build(comment_params)
      @comment.admin_user = current_admin_user
      if @comment.save
        redirect_to admin_trader_path(@trader), notice: "Comment added successfully."
      else
        redirect_to admin_trader_path(@trader), alert: "Failed to add comment."
      end
    end

    private

    def comment_params
      params.require(:comment).permit(:body)
    end
  end
end