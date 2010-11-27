class Payments::WebmoneyController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:payment_result, :payment_success, :payment_fail]
  before_filter :parse_payment_params, :only => [:payment_result, :payment_success, :payment_fail]
  before_filter :valid_payment, :only => [:payment_result]

  # Результат платежа
  def payment_result
    raise GatewayError, "Not found order" unless @order
    @order.checkout.one_click = true
    raise GatewayError, "Not pay" unless @order.checkout.next!
    @order.reload
    @order.checkout.one_click = true
    raise GatewayError, "Not complete" unless @order.checkout.completed_at
    raise "Not pay" unless @order.pays.create(:amount => payment_params[:payment_amount],
                                              :kind_of_payment => @gateway.name,
                                              :payment_information =>
                         {
                          "Внутренний номер счета в WM" =>  payment_params[:sys_invs_no],
                          "Внутренний номер платежа в WM" => payment_params[:sys_trans_no],
                          "Дата и время платежа" => payment_params[:sys_trans_date]
                         },
                                              :comment => "Платеж выполнен через Webmoney Merchant"
                                              )

    logi "result payment OK"
    render :text => "YES"
  rescue GatewayError => ex
    loge "result payment No #{ex.message}"
    render :text => "No :#{ex.message}"
  end

  # Подтвержение успешной оплаты
  def payment_success
    @order = Order.find_by_id @payment_params[:payment_no]

    if @order && @order.checkout_complete
      shop_md5 ||= @order.shop.to_md5.to_sym
      session[shop_md5] ||= { }
      session[shop_md5][:order_id] = nil
      flash[:notice] = t('order_processed_successfully')
      order_params = {:checkout_complete => true}
      @order_host = @order.try(:shop).try(:domain) || MAIN_DOMAIN
      redirect_to order_url(@order, {:checkout_complete => true, :order_token => @order.token, :host => @order_host})
    else
      flash[:error] =  t("payment_fail")
      redirect_to root_url
    end

  end

  # Платеж отменен
  # перенаправляем покупателя на страницу заказа или главную страницу
  def payment_fail
    @order = Order.find_by_id @payment_params[:payment_no]
    flash.now[:error] = t("payment_fail")
    redirect_to @order.blank? ? root_url : order_url(@order)
  end


  private


  # разбираем параметры
  def parse_payment_params
    @payment_params = HashWithIndifferentAccess.new
    params.each do |key, value|
      if key.starts_with?('LMI_')
        @payment_params[key.gsub(/^LMI_/, "").downcase] = value
      end
    end
  end


  # Проверяем верен ли платеж
  def valid_payment

    @order = Order.find_by_id @payment_params[:payment_no]
    @gateway = Gateway.find_by_id(@payment_params[:GW])
    # @gateway ||= Gateway.by_shop(@order.shop).active.find_by_type "Gateway::Webmoney"
    @gateway ||= Gateway.active.find_by_type "Gateway::Webmoney"
    raise "invalid gateway" unless @gateway
    @secret = @gateway.options[:secret]

    if @payment_params[:prerequest] == "1"
      render :text => "YES"
    elsif  @secret.blank?  # если не указан секретный ключ
      raise ArgumentError.new("WebMoney secret key is not provided")
    elsif !valid_hash?(@payment_params, @secret)
      raise "not valid payment"
    end
  rescue
    loge "not valid payment #{ex.message}"
    render :text => "not valid payment"
  end



  def valid_hash?(payment_params, secret)
    payment_params[:hash] ==
      Digest::MD5.hexdigest([
                             payment_params[:payee_purse],    payment_params[:payment_amount],
                             payment_params[:payment_no],     payment_params[:mode],
                             payment_params[:sys_invs_no],    payment_params[:sys_trans_no],
                             payment_params[:sys_trans_date], secret,
                             payment_params[:payer_purse],    payment_params[:payer_wm]
                            ].join("")).upcase
  end


  def logi message
    logger.info "[ webmoney ]"+'-'*90
    logger.info "[ webmoney ]"+ message.to_s
    logger.info "[ webmoney ]"+'-'*90
  end
  def loge message
    logger.error "[ webmoney ]"+'-'*90
    logger.error "[ webmoney ]"+ message.to_s
    logger.error "[ webmoney ]"+'-'*90
  end

end
