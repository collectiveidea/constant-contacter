class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username, :api_key, :authentication_code
  validates :name, :uniqueness => true, :presence => true

  def save_authentication_code(code)
    self.authentication_code = code
    self.save!
  end

  def authorized?
    !authentication_code.nil?
  end

  def list_id
    "http://api.constantcontact.com/ws/customers/#{username}/lists/#{list}"
  end

  def add_email(data)
    cc = ConstantContact.new(self)
    if contact_id = cc.find_contact_id_by_email(data[:email])
      # Because Constant Contact doesn't return a full contact when searching by email
      contact_xml = cc.find_contact(contact_id)
      cc.add_list_to_contact(contact_xml, list_id)
    else
      new_contact_xml = cc.generate_new_contact(
        data[:email],
        data[:first_name],
        data[:last_name],
        data[:postal_code],
        username,
        [list_id])
      cc.new_contact(new_contact_xml)
    end
  end
end
