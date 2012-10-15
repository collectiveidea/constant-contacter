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

  def find_contact_id_by_email(email)
    response = oauth_token.get("https://api.constantcontact.com/ws/customers/#{@username}/contacts?email=#{email}")
    hash = Hash.from_xml(response.body)
    if hash['feed'].nil?
      nil
    else
      hash['feed']['entry']['id'].split('/').last
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

  def add_list_to_contact(contact_xml, list_id)
    document      = Nokogiri::XML(contact_xml)
    contact       = document.at_xpath('//Contact:Contact', 'Contact' => 'http://ws.constantcontact.com/ns/1.0/')

    contact_lists = document.at_xpath('//Contact:ContactLists', 'Contact' => 'http://ws.constantcontact.com/ns/1.0/')
    unless contact_lists
      contact_lists = Nokogiri::XML::Node.new "ContactLists", document
      contact_lists.parent=(contact)
    end

    new_contact_list            = Nokogiri::XML::Node.new "ContactList", document
    new_contact_list['id']      = list_id
    new_contact_list.parent=(contact_lists)

    contact_list_link           = Nokogiri::XML::Node.new "link", document
    contact_list_link['xmlns']  = "http://www.w3.org/2005/Atom"
    contact_list_link['href']   = list_id
    contact_list_link['rel']    = "self"
    contact_list_link.parent=(new_contact_list)

    contact_list_source         = Nokogiri::XML::Node.new "OptInSource", document
    contact_list_source.content = "ACTION_BY_CONTACT"
    contact_list_source.parent=(new_contact_list)

    contact_list_time           = Nokogiri::XML::Node.new "OptInTime", document
    contact_list_time.content   = DateTime.now.iso8601
    contact_list_time.parent=(new_contact_list)

    document.to_xml
    # oauth_token.put("https://api.constantcontact.com/ws/customers/#{@username}/contacts/#{contact_id}", {:body => document.to_xml, :headers => {'Content-Type' => 'application/atom+xml;type=entry'}})
  end

  def generate_new_contact(email_address, first_name, last_name, postal_code, username, list_ids)
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