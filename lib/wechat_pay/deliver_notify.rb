require 'json'
require 'rest_client'

module WechatPay
  module DeliverNotify
    def self.request(access_token, params)
      url = "https://api.weixin.qq.com/pay/delivernotify?access_token=#{access_token}"

      sign_attrs = {
        appid:             WechatPay.app_id,
        appkey:            WechatPay.pay_sign_key,
        openid:            params[:openid],
        transid:           params[:transid],
        deliver_msg:       params[:deliver_msg],
        out_trade_no:      params[:out_trade_no],
        deliver_status:    params[:deliver_status],
        deliver_timestamp: params[:deliver_timestamp]
      }
      app_signature = Sign.sha1(sign_attrs)

      data = {
        appid:             WechatPay.app_id,
        openid:            params[:openid],
        transid:           params[:transid],
        sign_method:       "sha1",
        deliver_msg:       params[:deliver_msg],
        out_trade_no:      params[:out_trade_no],
        app_signature:     app_signature,
        deliver_status:    params[:deliver_status],
        deliver_timestamp: params[:deliver_timestamp]
      }

      RestClient.post(url, JSON.generate(data)) do |response|
        JSON.parse(response.body, symbolize_names: true)
      end
    end
  end
end
