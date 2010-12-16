class Gateway::Webmoney < Gateway
  preference :secret, :string
  preference :wallet, :string

  def provider_class
    self.class
  end

  def method_type
    "webmoney"
  end
  def test?
    options[:test_mode] == true
  end

  def desc
    "<p>
      <label> #{I18n.t('webmoney.success_url')}: </label> htpp://[domain]/gateway/webmoney/success<br />
      <label> #{I18n.t('webmoney.result_url')}: </label> http://[domain]/gateway/webmoney/result<br />
      <label> #{I18n.t('webmoney.fail_url')}: </label> http://[domain]/gateway/webmoney/fails<br />
    </p>"
  end
end
