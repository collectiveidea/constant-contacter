class ConstantContact
  def initialize

  end

  def oauth_client
    OAuth2::Client.new(
      api_key,
      consumer_secret,
      :site => 'https://oauth2.constantcontact.com',
      :authorize_url => '/oauth2/oauth/siteowner/authorize',
      :token_url => '/oauth2/oauth/token')
  end

  def oauth_token
    OAuth2::AccessToken.new(oauth_client, authentication_code)
  end

  def find_contact_by_email(email)
    response = oauth_token.get("https://api.constantcontact.com/ws/customers/#{username}/contacts?email=#{email}")
    parsed = Hash.from_xml(response.body)
  end

  def find_contact(contact_id)
    response = oauth_token.get("https://api.constantcontact.com/ws/customers/#{username}/contacts/#{contact_id}")
    Hash.from_xml(response.body)
  end

  def new_contact(new_contact)
    oauth_token.post("https://api.constantcontact.com/ws/customers/#{username}/contacts/#{new_contact}")
  end

  def contact_id(response_hash)
    id_url = response_hash["feed"]["entry"]["content"]["Contact"]["id"]
    id_url.split('/').last
  end
end