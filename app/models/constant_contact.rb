class ConstantContact
  def initialize(list)
    @api_key             = list.api_key
    @consumer_secret     = list.consumer_secret
    @authentication_code = list.authentication_code
    @username            = list.username
  end

  def oauth_client
    OAuth2::Client.new(
      @api_key,
      @consumer_secret,
      :site => 'https://oauth2.constantcontact.com',
      :authorize_url => '/oauth2/oauth/siteowner/authorize',
      :token_url => '/oauth2/oauth/token')
  end

  def oauth_token
    OAuth2::AccessToken.new(oauth_client, @authentication_code)
  end

  def find_contact(contact_id, output = :xml)
    xml_response = oauth_token.get("https://api.constantcontact.com/ws/customers/#{@username}/contacts/#{contact_id}")
    Hash.from_xml(response.body) if output == :hash
    xml_response.body if output == :xml
  end

  def find_contact_by_email(email)
    response = oauth_token.get("https://api.constantcontact.com/ws/customers/#{@username}/contacts?email=#{email}")
    hash = Hash.from_xml(response.body)
    if hash['entry'].nil?
      nil
    else
      hash
    end
  end

  def contact_id_from_hash(response_hash)
    id_url = response_hash["entry"]["content"]["Contact"]["id"]
    id_url.split('/').last
  end

  def contact_list_ids_from_hash(response_hash)
    (response_hash["entry"]["content"]["Contact"]["ContactLists"] || {}).map do |key, value|
      value["id"]
    end
  end

  def new_contact(new_contact)
    oauth_token.post("https://api.constantcontact.com/ws/customers/#{@username}/contacts", {:body => new_contact, :headers => {'Content-Type' => 'application/atom+xml;type=entry'}})
  end

  def add_list_to_contact(contact_xml, list)
    document = Nokogiri.XML(contact_xml)
  end

  def generate_new_contact(email_address, first_name, last_name, postal_code, list_ids, username)
    builder = Builder::XmlMarkup.new
    builder.entry(:xmlns => "http://www.w3.org/2005/Atom") do |entry|
      entry.title(:type => :text)
      entry.updated("2008-07-23T14:21:06.407Z")
      entry.author
      entry.id("data:,none")
      entry.summary("Contact", :type => :text)
      entry.content(:type => "application/vnd.ctct+xml") do |content|
        content.Contact(:xmlns => "http://ws.constantcontact.com/ns/1.0/") do |contact|
          contact.EmailAddress(email_address)
          contact.FirstName(first_name)
          contact.LastName(last_name)
          contact.OptInSource("ACTION_BY_CONTACT")
          contact.ContactLists do |list|
            list_ids.each do |list_id|
              list << "<ContactList id=\"#{list_id}\" />"
            end
          end
        end
      end
    end
  end
end