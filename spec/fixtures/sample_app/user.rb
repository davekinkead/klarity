class User
  def create_order
    Order.new(self)
  end

  def send_welcome
    EmailService.send(email)
  end

  def process_payment
    PaymentService.process(self)
  end

  def self.find(id)
    Database.query(id)
  end
end
