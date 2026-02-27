class Order
  def initialize(user)
    @user = user
  end

  def process
    PaymentService.charge(@user)
    NotificationService.notify(@user)
  end

  def validate
    Validator.check(self)
  end

  def save
    Database.persist(self)
  end

  def self.all
    Database.query_all
  end
end
