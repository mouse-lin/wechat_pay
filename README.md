# WechatPay

微信支付: https://open.weixin.qq.com/cgi-bin/frame?t=home/pay_tmpl&lang=zh_CN

It contains:

* generate access-token
* App payment
* JS payment
* Native payment (Work In Process)
* verify notify

MRI Ruby 2.0.0 and newer are supported. 1.9.2 should work as well but not tested.

## Installation

Add this line to your application's Gemfile:

    gem 'wechat_pay'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wechat_pay

## Usage

### Config

```ruby
WechatPay.app_id       = 'YOUR_APP_ID'
WechatPay.app_secret   = 'YOUR_APP_SECRET'
WechatPay.pay_sign_key = 'YOUR_PAY_SIGN_KEY'
WechatPay.partner_id   = 'YOUR_PARTNER_ID'
WechatPay.partner_key  = 'YOUR_PARTNER_KEY'
```

### Access Token

```ruby
WechatPay::AccessToken.generate # => { access_token: 'ACCESS_TOKEN', expires_in: 7200 }
```

Your should cache the `access_token`, see [http://mp.weixin.qq.com/wiki/index.php...](http://mp.weixin.qq.com/wiki/index.php?title=%E8%8E%B7%E5%8F%96access_token)

You may wanna do something like this in Rails:

```ruby
Rails.cache.fetch(:wechat_pay_access_token, expires_in: 7200.seconds raw: true) do
  WechatPay::AccessToken.generate[:access_token]
end
```

### App Payment params

```ruby
# Please keep in mind that all key MUST be Symbol
params = {
  body:             'body',
  traceid:          'traceid',      # Your user id
  out_trade_no:     'out_trade_no', # Your order id
  total_fee:        '100',          # 注意：单位是分，不是元
  notify_url:       'http://your_domain.com/notify',
  spbill_create_ip: '192.168.1.1'
}

WechatPay::App.payment('ACCESS_TOKEN', params)
# =>
#   {
#     nonce_str:  'noncestr',
#     package:    'Sign=WXpay',
#     partner_id: 'partner_id',
#     prepay_id:  'prepay_id',
#     timestamp:  '1407165191',
#     sign:       'sign'
#   }
```
### JS Payment params

* In Controller

```ruby
params = {
  body:             'body',
  out_trade_no:     'out_trade_no'
  total_fee:        '100'
  notify_url:       'http://your_domain.com/notify',
  spbill_create_ip: '192.168.1.1'
}

@order_params = WechatPay::JS.payment('ACCESS_TOKEN', params)

# =>
#   {
#     nonceStr:  'noncestr',
#     package:    'Sign=WXpay',
#     partnerId: 'partner_id',
#     prepayId:  'prepay_id',
#     timeStamp:  '1407165191',
#     sign:       'sign'
#   }
```

* In View (slim)
```ruby
= link_to "wechat_payment_btn", "javascript:void(0)", class: "wechatPaymentBtn"

javascript:
  document.addEventListener('WeixinJSBridgeReady', function onBridgeReady() {
    $('.wechatPaymentBtn').click(function(){
      WeixinJSBridge.invoke('getBrandWCPayRequest', "#{@order_params}" %>, function(res){
        if(res.err_msg == "get_brand_wcpay_request:ok" ) {
          alert('pay for success!');
        }else{
          alert(res.err_msg);
        }
      });
    });
  }, false);
```

### Verify notify

```ruby
# Rails example

def app_notify
  # except :controller_name, :action_name, :host, etc.
  notify_params = params.except(*request.path_parameters.keys)

  if WechatPay::Notify.verify?(notify_params)
    # Valid notify status
    if params[:trade_state] == '0'
      # Code your business logic
    end
    render text: 'success'
  else
    render text: 'error'
  end
end
```

### Query Order

```ruby
params = { 
  out_trade_no: "your unique trade number"
}

response = WechatPay::Order.query("access_token", params)
# =>
#  { 
#    errcode: 0, 
#    errmsg:  "ok", 
#    order_info: {
#      ret_code:      0, 
#      ret_msg:       "", 
#      input_charset: "GBK", 
#      trade_state:   "0", 
#      trade_mode:    "1", 
#      partner:       "1123311", 
#      bank_type:     "SPDB_DEBIT", 
#      bank_billno:   "201407173120292906", 
#      total_fee:     "48", 
#      fee_type:      "1", 
#      transaction_id:"123221001201409173175088219", 
#      out_trade_no:  "956", 
#      is_split:      "false", 
#      is_refund:     "false", 
#      attach:        "", 
#      time_end:      "20140717150912", 
#      transport_fee: "0", 
#      product_fee:   "4800", 
#      discount:      "0", 
#      rmb_total_fee: ""
#    }
#  }

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

[WTFPL](http://wtfpl.org)
