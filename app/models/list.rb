class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username, :api_key, :authentication_code
  validates :name, :uniqueness => true, :presence => true

  def save_authentication_code(code)
    authentication_code = code
    self.save!
  end

  def authorized?
    !authentication_code.empty?
  end

  def constant_contact_list_id
    "http://api.constantcontact.com/ws/customers/#{username}/lists/#{list}"
  end

  def add_email(data)
    constant_contact = ConstantContact.new(self)
    if contact_hash = constant_contact.find_contact_by_email(data[:email])
      # Because Constant Contact doesn't return a full contact when searching by email
      contact_xml = constant_contact.find_contact(constant_contact.contact_id_from_hash(contact_hash))
      constant_contact.add_list_to_contact(contact_xml, constant_contact_list_id)
    else
      constant_contact.new_contact(
        data[:email],
        data[:first_name],
        data[:last_name],
        data[:postal_code],
        username,
        [constant_contact_list_id])
    end
  end
end
