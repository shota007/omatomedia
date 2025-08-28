class ApplicationController < ActionController::Base
  before_action :load_categories
  include SessionsHelper
  require 'streamio-ffmpeg'

    def create_tempfile(content)
        client = Aws::S3::Client.new(region: "ap-northeast-1", access_key_id: ENV["AWS_ACCESS_KEY_ID"], secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"])
        file = client.get_object(bucket: "omatomedia", :key => content.audio_file.key).body.read
        tempfile = Tempfile.open(["temp", ".mp3"])
        tempfile.binmode
        tempfile.write(file)
        tempfile.rewind
        return tempfile
    end
        
    def split_audio(tempfile)
        movie = FFMPEG::Movie.new(tempfile.path)
        parts = (movie.duration / chunk_seconds).ceil
        Array.new(parts) do |i|
          out = Tempfile.new(["chunk#{i}", ".mp3"])
          out.binmode
          FFMPEG::Transcoder.new(tempfile.path, out.path, seek_time: i*chunk_seconds, duration: chunk_seconds).run
          out
        end
      end
  
    def transcribe(transfile)
      client = OpenAI::Client.new(
        access_token: ENV['OPENAI_API_KEY'],
      )
  
      response = client.audio.transcribe(
        parameters: {
            model: "whisper-1",
            file: File.open(transfile, "rb"),
        })
  
      @transcribe_res = response.dig("text")
      return @transcribe_res
    end
    
    def summarize(sum_file)
      return "" if sum_file.blank?
       client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])

    prompt = <<~PROMPT
    次の文章を要約してください：#{sum_file}
    PROMPT

    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
        { role: "system", content: "あなたは優秀な要約アシスタントです。" },
        { role: "user",   content: prompt }
      ]})
    
    response.dig("choices", 0, "message", "content") || ""
    rescue => e
    Rails.logger.error "[summarize] #{e.class}: #{e.message}"
    ""
    end

    def auto_login
    end

    # 例外処理
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
   
    def render_404(exception = nil)
      respond_to do |format|
        format.html { render 'errors/error_404', status: :not_found, layout: 'application' }
        format.json { head :not_found }
        format.any  { head :not_found }
      end
    end

    # def render_500
    # render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
    # end

    private
    def logged_in_user
      unless logged_in?
        redirect_to login_url
      end
    end

    def require_login
      unless current_user
        redirect_to login_path, alert: "ログインしてください"
      end
    end

    def load_categories
      # @categories = Category.order(:id)
      @categories = Category.reorder(:position)
    end
     
end
