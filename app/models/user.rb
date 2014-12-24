class User < ActiveRecord::Base
  has_and_belongs_to_many :reports

  before_save :ensure_authentication_token

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:persona, :cas, :github, :orcid]

  validates :name, presence: true
  validates :email, uniqueness: true, allow_blank: true

  def self.from_omniauth(auth)
    Rails.logger.debug auth
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
    end
  end

  # fetch additional user information for cas strategy
  def self.fetch_raw_info(uid)
    conn = Faraday.new(url: ENV["CAS_INFO_URL"]) do |faraday|
             faraday.request  :url_encoded
             faraday.response :logger
             faraday.response :json
             faraday.adapter  Faraday.default_adapter
           end
    profile = conn.get("/#{uid}").body || {}
    { name: profile.fetch("realName", uid),
      email: profile.fetch("email", nil) }
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    where(conditions).where(["lower(email) = :value", { :value => email.strip.downcase }]).first
  end

  protected

  def set_first_user
    # The first user we create has an admin role and uses the configuration
    # API key, unless it is in the test environment
    if User.count == 1 && !Rails.env.test?
      update_attributes(role: "admin", authentication_token: ENV['API_KEY'])
    end
  end

  # Don't require email or password, as we also use OAuth
  def email_required?
    false
  end

  def password_required?
    false
  end

  # Attempt to find a user by it's email. If a record is found, send new
  # password instructions to it. If not user is found, returns a new user
  # with an email not found error.
  def self.send_reset_password_instructions(attributes={})
    recoverable = find_recoverable_or_initialize_with_errors(reset_password_keys, attributes, :not_found)
    recoverable.send_reset_password_instructions if recoverable.persisted?
    recoverable
  end

  def self.find_recoverable_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    (case_insensitive_keys || []).each { |k| attributes[k].try(:downcase!) }

    attributes = attributes.slice(*required_attributes)
    attributes.delete_if { |key, value| value.blank? }

    if attributes.size == required_attributes.size
      record = where(attributes).first
    end

    unless record
      record = new

      required_attributes.each do |key|
        value = attributes[key]
        record.send("#{key}=", value)
        record.errors.add(key, value.present? ? error : :blank)
      end
    end
    record
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
