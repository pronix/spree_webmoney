class Gateway::Webmoney < Gateway
  preference :secret, :string
  preference :wallet, :string
  cattr_accessor :one_click

  # при создание делаем не активным
  after_create :inactive
  def inactive
    self.active = false
    save!
  end

  # проверяем чтоб были заполнены все параметры
  validate :valid_params
  def valid_params
    if !new_record? && self.active
      errors.add_to_base("Кошелек обязательное поле заполните его пожалуйста.") if  self.preferences["wallet"].blank?
      errors.add_to_base("Ключевое слово обязательное поле, оно необходимо для проверки платежей.") if  self.preferences["secret"].blank?
    end
  end

  def one_click?
    true
  end

  def provider_class
    self.class
  end

  # имя хелпера для формирования формы оплаты
  # вызываеться через send(:payment_helper)
  def payment_helper
    :webmoney_payment
  end

  # имя хелпера для пока помощи настройки для этой платежной системы
  def help_text
    :webmoney_help_text
  end
end
