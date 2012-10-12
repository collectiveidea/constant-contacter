class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username, :api_key, :authentication_code
  validates :name, :uniqueness => true, :presence => true

  def save_authentication_code(code)
    self.authentication_code = code
    self.save!
  end

  def authorized?
    !authentication_code.empty?
  end

  def add_email(data)
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
end
