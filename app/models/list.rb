class List < ActiveRecord::Base
  attr_accessible :list, :name, :password, :username
  validates :name, :uniqueness => true, :presence => true
  
  include ConstantContact

  def add_email(data)
    setup_constant_contact
    contact = Contact.search_by_email(data[:email]) || Contact.add(
      :email_address => data[:email],
      :first_name => data[:first_name],
      :last_name => data[:last_name])
    contact.add_to_list!(list)
  end

  def setup_constant_contact
    ConstantContact.setup(username, password)
  end
end
