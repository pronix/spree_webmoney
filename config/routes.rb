Rails.application.routes.draw do
  # Add your extension routes here
  namespace :gateway do
    match '/webmoney/:gateway_id/:order_id' => 'webmoney#show', :as => :webmoney
    match '/webmoney/result'  => 'webmoney#result',  :as => :webmoney_result
    match '/webmoney/success' => 'webmoney#success', :as => :webmoney_success
    match '/webmoney/fail'   => 'webmoney#fail',   :as => :webmoney_fail
  end
end
