ConstantContacter::Application.routes.draw do
  resources :lists

  match 'emails/:list_id' => 'emails#create'
  match 'auth/constantcontact/callback' => 'oauth#callback'
end
