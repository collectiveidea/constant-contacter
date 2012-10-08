ConstantContacter::Application.routes.draw do
  resources :emails, :only => :create
  resources :lists

  match 'auth/constantcontact/callback' => 'oauth#callback'
end
