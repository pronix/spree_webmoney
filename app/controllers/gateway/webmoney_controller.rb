class Gateway::WebmoneyController < Spree::BaseController
  skip_before_filter :verify_authenticity_token, :only => [:result, :success, :fail]
  before_filter :parse_payment_params,           :only => [:result, :success, :fail]
  before_filter :valid_payment,                  :only => [:result]

  def show
    @order =  Order.find(params[:order_id])
    @gateway = @order.available_payment_methods.find{|x| x.id == params[:gateway_id].to_i }
    @order.payments.destroy_all
    payment = @order.payments.create!(:amount => 0,  :payment_method_id => @gateway.id)

    if @order.blank? || @gateway.blank?
      flash[:error] = I18n.t("Invalid arguments")
      redirect_to :back
    else
      render :action => :show
    end
  end

  def result
    raise GatewayError, "Not found order" unless @order
    payment = @order.payments.first
    payment.state = "completed"
    payment.amount = @payment_params[:payment_amount].to_f
    payment.save
    @order.save!
    @order.next! until @order.state == "complete"

    render :text => "YES"
  end

  def success
    @order =  Order.find_by_id(@payment_params[:payment_no])
    if @order && @order.complete?
      session[:order_id] = nil
      redirect_to order_path(@order)
    else
      flash[:error] =  t("payment_fail")
      redirect_to root_url
    end
  end

  def fail
    @order = Order.find_by_id(@payment_params[:payment_no])
    flash.now[:error] = t("payment_fail")
    redirect_to @order.blank? ? root_url : edit_order_checkout_url(@order, :step => "payment")
      return
  end

  private

  # parse params
  def parse_payment_params
    @payment_params = HashWithIndifferentAccess.new
    params.each do |key, value|
      if key.starts_with?('LMI_')
        @payment_params[key.gsub(/^LMI_/, "").downcase] = value
      end
    end
  end


  def valid_payment
    @order =  Order.find_by_id(@payment_params[:payment_no])
    @gateway = @order.payments.first.payment_method

    raise "invalid gateway" unless @gateway
    @secret = @gateway.options[:secret]

    if @payment_params[:prerequest] == "1"
      render :text => "YES"
    elsif  @secret.blank?  # если не указан секретный ключ
      raise ArgumentError.new("WebMoney secret key is not provided")
    elsif !valid_hash?(@payment_params, @secret)
      raise "not valid payment"
    end
  rescue => ex
    Rails.logger.error "not valid payment #{ex.message}"
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

end
