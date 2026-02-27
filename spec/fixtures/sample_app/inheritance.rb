class ApplicationRecord
  def self.abstract_class?
    true
  end
end

class Person < ApplicationRecord
  include ActiveModel::Validations
  extend ActiveModel::Naming

  def save
    Database.persist(self)
  end
end

class Admin < Person
  prepend Auditable
  include Auth::Permissions

  def delete_user(user)
    AuditService.log(user.id)
    user.destroy
  end
end
