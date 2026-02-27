class ArrayIncludeCheck
  def check_permissions(object)
    # Check if object is one of several types
    do_something if [User, Order, PaymentService].include?(object.class)

    # Another array include with nested constant
    return unless [PaymentGateway, AuditService].include?(object.class)

    do_another_thing
  end

  private

  def do_something; end
  def do_another_thing; end
end
