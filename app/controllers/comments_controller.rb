class CommentsController < ApplicationController

def create
    @comment = current_user.comments.new(comment_params)
    if @comment.save
      redirect_to content_path(@comment.content, anchor: "comments"), notice: 'コメントを投稿しました'
    else
      redirect_to content_path(@comment.content, anchor: "comment-form"), alert: 'コメントの投稿に失敗しました'
    end
end

def edit
  @comment = Comment.find(params[:id])
  @content = Content.find(@comment.content_id)
  @users = User.all
end

def update
  @comment = Comment.find(params[:id])
  @content = Content.find(@comment.content_id)  
  if @comment.update(comment_params)
      redirect_to @content, success:'更新しました'
  else
      flash.now[:danger] = '失敗しました'
      render :edit
  end
end

def destroy
  comment = Comment.find(params[:id])
  @content = Content.find(comment.content_id)
  comment.destroy!
  redirect_to @content, anchor: "comments", status: :see_other, success: '削除しました' 
end

private

def comment_params
  params.permit(:comment, :content_id)
end

end