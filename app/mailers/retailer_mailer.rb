class RetailerMailer < ApplicationMailer
  def password_reset(retailer_id)
    @retailer = Retailer.find(retailer_id)
    mail(to: @retailer.email, subject: 'Password Reset')
  end

  def order_report(report_id)
    @retailerreport = RetailerReport.find(report_id)
    @retailers = Retailer.where("id = #{@retailerreport.retailer_id} or report_parent_id = #{@retailerreport.retailer_id}")
    #@retailer_reviews = RetailerReview.where(retailer_id: @retailers).where('date(created_at) BETWEEN ? AND ?', @retailerreport.from_date, @retailerreport.to_date).order('created_at DESC, retailer_id')
    @order_feedbacks = OrderFeedback.where(order_id: Order.where(retailer: @retailers)).where('date(created_at) BETWEEN ? AND ?', @retailerreport.from_date, @retailerreport.to_date).order('created_at DESC')
    subject = "#{@retailerreport.retailer.company_name} el Grocer Order Report #{@retailerreport.from_date.to_date}"
    subject += " to #{@retailerreport.to_date.to_date}" if @retailerreport.to_date > @retailerreport.from_date
    mail(to: @retailerreport.retailer.report_emails, subject: subject)
  end

  def order_report_new(report_id, from_day, to_day)
    @retailerreport = RetailerReport.find(report_id)
    @retailers = Retailer.where("id = #{@retailerreport.retailer_id} or report_parent_id = #{@retailerreport.retailer_id}")
    #@retailer_reviews = RetailerReview.where(retailer_id: @retailers).where('date(created_at) BETWEEN ? AND ?', @retailerreport.from_date, @retailerreport.to_date).order('created_at DESC, retailer_id')
    @order_feedbacks = OrderFeedback.where(order_id: Order.where(retailer: @retailers).where.not(status_id: -1).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', from_day.day.ago.to_date, to_day.day.ago.to_date)).where('order_feedbacks.delivery IS NOT NULL or order_feedbacks.speed IS NOT NULL or order_feedbacks.accuracy IS NOT NULL or order_feedbacks.price IS NOT NULL or order_feedbacks.comments IS NOT NULL').order('created_at DESC')
    @days_diff = @retailerreport.to_date.yday - @retailerreport.from_date.yday
    subject = if @days_diff.zero?
                'Daily'
              elsif @days_diff == 6
                'Weekly'
              elsif @days_diff >= 27 and @days_diff <= 30
                'Monthly'
              else
                ''
              end
    subject = "elGrocer #{subject} Report - #{@retailerreport.retailer.company_name} - #{@retailerreport.from_date.to_date}"
    subject += " to #{@retailerreport.to_date.to_date}" if @days_diff.positive?
    mail(to: @retailerreport.retailer.report_emails, subject: subject)
  end

  def missing_barcodes(barcodes_na, barcodes_dup, retailer_id)
    @barcodes_na = barcodes_na
    @barcodes_dup = barcodes_dup
    @retailer_id = retailer_id
    mail(to: (Redis.current.get :missing_barcodes_mailers || 'imran@elgrocer.com,Solomon@elgrocer.com,Shylaja@elgrocer.com'), subject: 'Missing Barcodes')
  end

  def union_csv_response(recipients, file_path)
    attachments['union_barcodes_response.csv'] = File.read(file_path)
    mail(to: recipients, body: 'Please find the attach.', subject: 'Union Coop Barcode Status')
  end

  def payment_failed(order_id, response)
    @order_id = order_id
    @response = response
    mail(to: 'tariq@elgrocer.com,zaid@elgrocer.com,ahtesham@elgrocer.com', subject: 'Online Payment Failed')
  end

  def permanently_disabled_products(email, csv)
    attachments["Permanently Disabled Shops #{Date.today}.csv"] = { mime_type: 'text/csv', content: csv }
    mail(to: email, subject: "Permanently Disabled Shops #{Date.today}.csv", body: 'Please find the attached csv of permanently disabled shops.')
  end
end
