class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username, :api_key, :authentication_code
  validates :name, :uniqueness => true, :presence => true

  attr_accessor :client, :token

  require 'net/http'
  require 'oauth2'

  def add_email(data)
    authenticate

    if contact = ConstantContact.find_contact_by_email(data[:email])
      # Because Constant Contact doesn't return a full contact when searching by email
      contact = ConstantContact.find_contact(contact.int_id)
      contact.contact_lists = contact_contact_lists | [list]
    else
      contact = ConstantContact.new_contact(
        :email_address => data[:email],
        :first_name    => data[:first_name],
        :last_name     => data[:last_name],
        :postal_code   => data[:postal_code],
        :list_ids      => [list])
    end
  end

  def authenticate
    @client = OAuth2::Client.new(api_key, consumer_secret, :site => 'https://oauth2.constantcontact.com', :authorize_url => '/oauth2/oauth/siteowner/authorize')
  end

  def authorize_url
    @client.auth_code.authorize_url(:redirect_uri => "https://constant-contacter.herokuapp.com/oauth/callback")
  end

  def create_token(code)
    @token = @client.auth_code.get_token(code, :redirect_uri => 'https://constant-contacter.herokuapp.com/oauth/callback')
  end

  def find_contact_by_email(email)
    @access_token.get('', :params => { '' => '' })
  end

end
