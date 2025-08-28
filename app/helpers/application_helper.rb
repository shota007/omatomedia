module ApplicationHelper
    def up_time(content)
        @today = Date.today
        @now = Time.now
        if (@now - content.created_at) <= 60 * 60
            ((@now - content.created_at) / 60).to_i.to_s + "mins ago"
        elsif (@now - content.created_at) <= 60 * 60 * 24
            ((@now - content.created_at) / 3600).to_i.to_s + "hr ago"
        elsif (@today - content.created_at.to_date) <= 30
            (@today - content.created_at.to_date).to_i.to_s + "days ago"
        else
            content.created_at.strftime('%F')
        end
    end

end
