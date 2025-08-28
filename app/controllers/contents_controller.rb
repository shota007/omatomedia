# /app/controllers/contents_controller.rb
class ContentsController < ApplicationController
  before_action :logged_in_user, only:[:new, :edit, :update, :destroy]
  before_action :content_user, only:[:edit, :update, :destroy]
  before_action :set_categories, only: [:index]
  require 'google/apis/youtube_v3'
  require 'open-uri'
  require 'open3'

  def index
    scope = Content.all
    scope = scope.looks(params[:word]) if params[:word].present?
    scope = scope.where(category_id: params[:category_id]) if params[:category_id].present?
    @contents = scope.order(created_at: :desc)
  end

  def new
    @content       = Content.new
    @youtube_title = nil
    @thum_path     = nil

    if params[:youtube_url].present?
      @content.youtube_url = params[:youtube_url]
      @youtube_id, @youtube_title, @thum_path = load_youtube(@content.youtube_url)
    end
    @categories = Category.order(:position)
  end
  
  # ステップ2：要約を取得してプレビュー（保存しない）
  def preview_summary
    # ステップ1から来た入力（タイトル編集・カテゴリ・タグなど含む）
    permitted = params.require(:content).permit(:youtube_url, :youtube_id, :title, :category_id, :tag_list)
    @content  = Content.new(permitted) # 保存はしない
    ensure_default_category(@content)

    # サムネは表示用にURLだけ使う（attachしない）
    @thum_path = @content.youtube_id.present? ? "https://img.youtube.com/vi/#{@content.youtube_id}/hqdefault.jpg" : nil

    # ==== ここで音声DL→文字起こし→要約（attachはしない） ====
    transcript = nil
    summary    = nil
    begin
      Dir.mktmpdir do |dir|
        # SABR回避＆wavへ直接
        system(
          'yt-dlp',
          '--no-playlist',
          '--extract-audio',
          '--audio-format', 'wav',
          '--audio-quality', '0',
          '--output', File.join(dir, '%(id)s.%(ext)s'),
          '--extractor-args', 'youtube:player_client=android',
          @content.youtube_url
        )
        wav = Dir[File.join(dir, '*.wav')].first
        raise 'audio not downloaded' unless wav && File.exist?(wav)
        transcript = transcribe(wav)
        summary    = summarize(transcript)
      end
    rescue => e
      Rails.logger.warn("[preview_summary] #{e.class}: #{e.message}")
      flash.now[:danger] = "要約の取得に失敗しました。時間をおいて再度お試しください。"
      @categories = Category.order(:position)
      return render :new, status: :unprocessable_entity
    end

    # 画面表示用にインスタンスへセット（保存はしない）
    @content.transcribed_text = transcript
    @content.summarized_text  = summary

    # ステップ3へ渡すために hidden で保持する
    @categories = Category.order(:position)
    render :preview_summary
  end


  # ステップ3：実保存
def create
    # ステップ2で決まった値をそのまま受け取って保存
    @content = current_user.contents.new(content_params)
    ensure_default_category(@content)

    # サムネ attach
    begin
      if @content.youtube_id.present?
        io = URI.open("https://img.youtube.com/vi/#{@content.youtube_id}/hqdefault.jpg")
        @content.img_file.attach(io: io, filename: "#{@content.youtube_id}.jpg", content_type: "image/jpeg")
      end
    rescue => e
      Rails.logger.warn("[thumb] #{e.class}: #{e.message}")
    end

    # 音声 attach（本保存時にもう一度DLして紐付ける）
    begin
      Dir.mktmpdir do |dir|
        system(
          'yt-dlp',
          '--no-playlist',
          '--extract-audio',
          '--audio-format', 'wav',
          '--audio-quality', '0',
          '--output', File.join(dir, '%(id)s.%(ext)s'),
          '--extractor-args', 'youtube:player_client=android',
          @content.youtube_url
        )
        wav = Dir[File.join(dir, '*.wav')].first
        if wav && File.exist?(wav)
          @content.audio_file.attach(
            io: File.open(wav),
            filename: File.basename(wav),
            content_type: 'audio/wav'
          )
        end
      end
    rescue => e
      Rails.logger.warn("[audio] #{e.class}: #{e.message}")
    end

    if @content.save
      redirect_to @content, notice: '投稿しました'
    else
      # バリデーションNG時はステップ2に戻して再表示
      @thum_path  = @content.youtube_id.present? ? "https://img.youtube.com/vi/#{@content.youtube_id}/hqdefault.jpg" : nil
      @categories = Category.order(:position)
      render :preview_summary, status: :unprocessable_entity
    end
  end

  def show
    @content = Content.find(params[:id])
    @comment = Comment.new
    @comments = Comment.where(content_id: @content.id)
    @user = User.find(@content.user_id)
  end

  def share
    @content = Content.find(params[:id])
    @comment = Comment.new
    @comments = Comment.where(content_id: @content.id)
    @user = User.find(@content.user_id)
  end

  def edit
  end

  def update
    if @content.update(content_params)
        redirect_to content_path(@content), success:'更新しました'
    else
        flash.now[:danger] = '失敗しました'
        render :edit
    end
  end

  def destroy
    @content.destroy!
    redirect_to current_user, status: :see_other, success: '削除しました' 
  end

  private

  def summarize_request?
    params[:intent] == 'summarize'
  end

  def content_params
    permitted = params.require(:content).permit(
      :youtube_url, :youtube_id, :title, :category_id,
      :transcribed_text, :summarized_text, :tag_list
    )
    if permitted[:tag_list].present?
      raw  = permitted[:tag_list]
      tags = raw.is_a?(Array) ? raw : raw.split(/[,\s]+/)
      permitted[:tag_list] = tags.map { |t| t.to_s.sub(/\A#/, '') }.reject(&:blank?).uniq
    end
    permitted
  end

  def ensure_default_category(record)
    return if record.category_id.present?
    default = Category.order(:position).first || Category.first
    record.category_id = default&.id
  end

  def content_user
    @content = Content.find(params[:id])
    redirect_to current_user unless current_user.id == @content.user_id
  end

  def set_categories
    @categories = Category.order(:position)
  end

  def fetch_youtube_title(video_id)
    svc = Google::Apis::YoutubeV3::YouTubeService.new
    svc.key = ENV['GOOGLE_CLIENT_API_KEY']
    snippet = svc.list_videos(:snippet, id: video_id).items.first.snippet
    snippet.title
  end

  def load_youtube(url)
    youtube_id = CGI.parse(URI(url).query)["v"]&.first
    return [nil, nil, nil] unless youtube_id

    svc = Google::Apis::YoutubeV3::YouTubeService.new
    svc.key = ENV["GOOGLE_CLIENT_API_KEY"]
    snippet = svc.list_videos(:snippet, id: youtube_id).items.first&.snippet
    title   = snippet&.title
    thumb   = "https://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg"
    [youtube_id, title, thumb]
  rescue => e
    Rails.logger.warn("[load_youtube] #{e.class}: #{e.message}")
    [youtube_id, nil, "https://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg"]
  end
end