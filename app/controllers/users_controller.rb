# users_controller.rb
class UsersController < ApplicationController
  require 'google/apis/youtube_v3'
  before_action :require_login, only: [:edit, :update, :destroy, :remove_avatar, :edit_password, :update_password]
  before_action :set_user,      only: [:show, :edit, :update, :destroy, :remove_avatar]
  before_action :correct_user,  only: [:edit, :update, :destroy, :remove_avata]

  def new
    @user = User.new
  end

  def signup_sent
    
  end


  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      respond_to do |format|
        format.html { redirect_to root_path, success: 'ユーザーを作成しました' }
        format.json { head :see_other, location: root_path }
      end
    else
      respond_to do |format|
        format.html {
          flash.now[:alert] = @user.errors.full_messages.join("、")
          render :new, status: :unprocessable_entity}
        format.json { render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def index
    # @users = User.all
  end

  def show
    @user = User.find(params[:id])
    @my_contents   = @user.contents.order(created_at: :desc)
    @my_favorites = current_user.favorites.includes(:content).map(&:content).compact
  end

  def edit
    @user = User.find(params[:id])
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user
    # 1) 現在のパスワードが合っているか
    unless @user.authenticate(params[:user][:current_password])
      @user.errors.add(:base, "現在のパスワードが正しくありません")
      return render :edit_password, status: :unprocessable_entity
    end

    # 2) 新しいパスワードで更新
    if params[:user][:password] != params[:user][:password_confirmation]
      @user.errors.add(:base, "新しいパスワードと新しいパスワード（確認）が一致しません")
      return render :edit_password, status: :unprocessable_entity
    end

   # 3) 新しいパスワードが「現在のパスワード」と同じでないか
   if @user.authenticate(params[:user][:password])
    @user.errors.add(:base, "新しいパスワードは現在のパスワードと同じにはできません")
    return render :edit_password, status: :unprocessable_entity
    end

    # 4) すべて OK なら更新
    if @user.update(password: params[:user][:password], password_confirmation: params[:user][:password_confirmation])
      redirect_to @user, notice: "パスワードを変更しました"
    else
      render :edit_password, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to @user, success:'更新しました'
    else
      flash.now[:danger] = '失敗しました'
      render :edit
    end
  end

  def list_channels
    # channel_id = #youtube URLをtrim
  end

  # 仮登録フォームで入力されたメールがすでに DB にあるかを返す
  def check_email
    exists = User.exists?(email: params[:email].to_s.downcase)
    render json: { exists: exists }
  end

  def remove_avatar
    @user.avatar.purge_later
    respond_to do |format|
      format.html { redirect_to edit_user_path(@user), notice: "アイコンを削除しました" }
      format.turbo_stream
    end
  end

  def finish_sign_up
    
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def correct_user
    unless current_user?(@user)
      redirect_to root_path, alert: "アクセス権限がありません"
    end
  end

  def user_params
    params.require(:user).permit(:uid, :name, :email, :password, :password_confirmation, :youtube_url, :avatar)
  end

end
