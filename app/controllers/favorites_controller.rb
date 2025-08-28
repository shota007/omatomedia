# app/controllers/favorites_controller.rb
class FavoritesController < ApplicationController
  before_action :require_login
  before_action :set_content

  def create
    current_user.favorites.find_or_create_by!(content: @content)
    respond_to do |f|
      f.html { redirect_back fallback_location: @content }
      f.turbo_stream
    end
  end

  def destroy
    current_user.favorites.where(content: @content).destroy_all
    respond_to do |f|
      f.html { redirect_back fallback_location: @content }
      f.turbo_stream
    end
  end

  private
  def set_content
    @content = Content.find(params[:content_id])
  end
end