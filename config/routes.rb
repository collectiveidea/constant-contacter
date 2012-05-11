ConstantContacter::Application.routes.draw do
  resources :emails, :only => :create
end
