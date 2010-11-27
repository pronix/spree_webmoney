module Payments::WebmoneyHelper
  def webmoney_help_text
    <<TXT
<div>
Для приема платежей в настройках Webmoney нужно указать следущющие адреса:
<p>
<em>Secret Key - такой же как в настройках платежной системы</em>
</p>
<p>
<strong>Success url: </strong>
<span>#{payment_success_payments_webmoney_url }</span>
<strong> метод вызова POST </strong>
<br/>
<strong>Fail url: </strong>
<span>#{payment_fail_payments_webmoney_url}</span>
<strong> метод вызова POST </strong>
<br/>
<strong>Result url: </strong>
<span>#{payment_result_payments_webmoney_url }</span>
<br/>
</p>
</div>
TXT
  end

  def webmoney_payment(order, gateway, *args, &block)
    options = args.extract_options!
    raise ArgumentError.new("Webmoney wallet is not provided") if gateway.options[:wallet].blank?
    @result = form_tag("https://merchant.webmoney.ru/lmi/payment.asp", :method => "POST")
    @result << hidden_field_tag(:LMI_PAYEE_PURSE, gateway.options[:wallet])
    @result << hidden_field_tag(:LMI_PAYMENT_AMOUNT, order.total)
    @result << hidden_field_tag(:GW, gateway.id)
    @result << hidden_field_tag(:LMI_SIM_MODE, 0) if gateway.test_mode
    @result << hidden_field_tag(:LMI_PAYMENT_NO, order.id)
    @result << hidden_field_tag(:LMI_PAYMENT_DESC_BASE64, [options[:desc]].pack("m")) if options.has_key? :desc

    options.except(:desc).each do |key, value|
        @result << hidden_field_tag("LMI_#{key.to_s.upcase}", value.to_s.strip)
    end

    @result << capture(&block) if block_given?
    @result << "<button class='button_buy fl'>"
    @result << "<span class='left_b'></span>"
    @result << "<span class='line_b'>"
    @result << "<span class='text_z_1'>#{I18n.t("payment_button.webmoney")}</span>"
    @result << "<span class='text_z_2'>#{I18n.t("payment_button.webmoney")}</span>"
    @result << "</span>"
    @result << "<span class='right_b'></span>"
    @result << "</a>"
    @result << "<div class='clear'></div>"
    @result << "<div class='rozdil_9'></div>"
    @result << "</form>"
    # @result << submit_tag("Webmoney", :class => "button" ) unless block_given?
    block_given? ? concat(@result) : @result

   end
end
