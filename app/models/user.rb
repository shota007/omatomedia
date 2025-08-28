class User < ApplicationRecord
    has_many :contents, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :favorites, dependent: :destroy
    has_one_attached :avatar
    has_secure_password validations: false
    validates :email, presence: true, length: { maximum: 300 }, uniqueness: true,
    format: {
      with: URI::MailTo::EMAIL_REGEXP,
      message: "は有効なメールアドレス形式で入力してください"
    }
    validates :email, presence: true, length: { maximum: 300 }, uniqueness: true
    validates :password, confirmation: { message: '新しいパスワードと新しいパスワード（確認）が一致しません' }, length: { in: 6..20 }, allow_nil: true, presence: true, on: :create, unless: -> { uid.present? }
    before_validation :ensure_password_for_oauth, on: :create

    private

    # uid がある場合、password_digest が nil ならランダム生成して埋める
    def ensure_password_for_oauth
        return if password_digest.present?
        return unless uid.present?

        random_pw = SecureRandom.hex(16)
        self.password              = random_pw
        self.password_confirmation = random_pw
    end
end
