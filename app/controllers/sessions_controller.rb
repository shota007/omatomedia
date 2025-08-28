class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    user_email = params[:session][:email].downcase
    user = User.find_by(email: user_email)
    if user.present? && user.authenticate(params[:session][:password])
      log_in user
      # redirect_to user
      render json: {
        status:  'ok',
        redirect_url: user_url(user)
      }

    elsif !user.present?
      @user = User.new(email: user_email)
      flash[:warning] = 'ユーザーが存在しません。'
      redirect_to login_path(session: {email: user_email})
      # render 'new', status: :unprocessable_entity
    else
      @user = User.new(email: user_email)
      flash[:warning] = 'パスワードが一致しません。'
      redirect_to login_path
      # render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, status: :see_other, data: { turbo: false }, success: 'ログアウトしました'
  end

end
