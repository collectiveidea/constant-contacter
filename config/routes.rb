ConstantContacter::Application.routes.draw do
  resources :emails, :only => :create
  match 'oauth/callback' => 'oauth#callback'
end
