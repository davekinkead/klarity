class UserService
  def initialize(user_repository: UserRepository.new, notifier: NotificationService.new)
    @user_repository = user_repository
    @notifier = notifier
  end

  def create(email, validator: EmailValidator.new)
    validator.validate(email)
    @user_repository.create(email)
    @notifier.send('Welcome!')
  end

  attr_writer :user_repository
end
