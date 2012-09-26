class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username, :api_key
  validates :name, :uniqueness => true, :presence => true

  def add_email(data)
    setup_constant_contact

    if contact = ConstantContact::Contact.find_by_email(data[:email])
      # Because Constant Contact doesn't return a full contact when searching by email
      contact = ConstantContact::Contact.find(contact.int_id)
      contact.contact_lists = contact_contact_lists | [list]
    else
      contact = ConstantContact::Contact.new(
        :email_address => data[:email],
        :first_name    => data[:first_name],
        :last_name     => data[:last_name],
        :postal_code   => data[:postal_code],
        :list_ids      => [list])
    end
    contact.save!
  end

  def setup_constant_contact
    ConstantContact::Base.user     = username
    ConstantContact::Base.api_key  = api_key
    ConstantContact::Base.password = password
    true
  end
end
