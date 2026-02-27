module UserManagement
  class Profile
    def update
      Storage.save(self)
      Logger.log('Updated profile')
    end
  end

  def self.find_by_email(email)
    Database.query(email)
  end
end

class Administrator
  include UserManagement

  def create_user
    User.new
    NotificationService.notify('User created')
  end
end
