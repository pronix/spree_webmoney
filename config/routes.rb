Rails.application.routes.draw do
  namespace :payments do
    resources :webmoney, :collection => {
      :payment_result => :any,
      :payment_success => :any,
      :payment_fail => :any
    }
  end
end
