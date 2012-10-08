Rails.application.config.middleware.use OmniAuth::Builder do
  provider :constantcontact, ENV['CC_KEY'], ENV['CC_SECRET']
end