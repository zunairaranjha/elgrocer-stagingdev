require 'resque/errors'
require 'open-uri'
require 'csv'

class DigestUnionBarcodesJob
  @queue = :union_csv_queue
  def self.perform(csv_link, emails)

    csv = open(csv_link, "r:utf-8").read

    @csv_response_path = "#{Rails.root.to_s}/tmp/union_csv_response.csv"

    csvResponseRows = []

    csvResponseHeaders = ['barcode','branch_code','response']

    @proxy = URI(ENV["PROXY_URL"])
    @client = HTTPClient.new(@proxy)
    @client.set_proxy_auth(@proxy.user, @proxy.password)
    partner = PartnerIntegration.find_by(integration_type: 1)

    csvObj = CSV.parse(csv, headers: true, header_converters: -> (f) { f.delete(' ').downcase })
    csvObj.each do |row|
      barcode = row['barcode'].tr("'",'')
      branch_code = row['branch_code'].to_i
      partner = partner.try(:branch_code).to_i == branch_code ? partner : PartnerIntegration.find_by(branch_code: branch_code, integration_type: 1)

      if partner
        headers = {'username': partner.user_name, 'password': partner.password, 'Content-Type': "multipart/form-data"}
        host_url = partner.api_url
        body = {
            'barcode' => barcode,
            'branch_code' => branch_code
        }
        response = @client.post host_url + '/onlinepartners/api/getProPriceInv', body, headers
        response = JSON(response.body)
      else
        response = "Partner not found"
      end
      csvResponseRows.push([barcode.insert(0,"'"), branch_code, response])
    end

    self.insertDataIntoCsv(@csv_response_path, csvResponseHeaders, csvResponseRows)
    
    RetailerMailer.union_csv_response(emails, @csv_response_path).deliver_later

  end

  private

  def self.insertDataIntoCsv(path, headers, data)
    CSV.open(path, "wb") do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

end

