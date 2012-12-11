Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, '281924215243523', 'ba907877eccfdbd398237954040191d0'
end
