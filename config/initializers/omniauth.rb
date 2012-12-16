Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, Constants::FACEBOOK_APP_ID, Constants::FACEBOOK_SECRET, :scope => 'email, user_education_history, friends_education_history'
end
