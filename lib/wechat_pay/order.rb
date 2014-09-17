module WechatPay
  module Order

    def self.query(access_token, params)
      query_order_api_url, query_datas = init_params access_token, params
      post_request query_order_api_url, query_datas
    end

    private

      def self.init_params access_token, params
        package = params.merge!({ partner: WechatPay.partner_id }).map do |p|
          p.join("=") 
        end.join("&") + "&sign=#{Sign.md5_with_partner_key(params)}"

        sign_attrs = { 
          appid:     WechatPay.app_id,
          appkey:    WechatPay.pay_sign_key,
          package:   package,
          timestamp: Time.now.to_i.to_s
        }
        pay_sign = Sign.sha1(sign_attrs)

        query_order_api_url = "https://api.weixin.qq.com/pay/orderquery?access_token=#{access_token}"
        query_datas = { 
          appid:         sign_attrs[:appid],
          package:       package,
          timestamp:     sign_attrs[:timestamp],
          app_signature: pay_sign, 
          sign_method:   "sha1",
        }
        [query_order_api_url, query_datas]
      end

      def self.post_request query_order_api_url, query_datas
        res = RestClient.post query_order_api_url, query_datas.to_json.gsub(/\\u([0-9a-z]{4})/) {|s| [$1.to_i(16)].pack("U")}
        JSON.parse res
      end

  end
end
