class PaymentService
  def self.process(user)
    PaymentGateway.charge(user.amount)
    AuditService.log(user.id)
  end

  def self.charge(user)
    PaymentGateway.process(user)
  end
end

class EmailService
  def self.send(email)
    SMTPClient.deliver(email)
  end
end

class Database
  def self.query(id)
    Connection.execute(id)
  end

  def self.query_all
    Connection.execute_all
  end

  def self.persist(record)
    Connection.save(record)
  end
end
