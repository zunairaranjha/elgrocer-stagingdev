namespace :cumulative_orders do
  desc "Export retailer orders"
  task export: :environment do

  @days = ENV['days_from'].to_i || 1
  @days_to = ENV['days_to'].to_i
  @retailer_ids = ENV['storeids']

  @startDate = @days.day.ago.to_date
  @endDate = @days_to.day.ago.to_date || Time.now.to_date
  # puts "Fetch retailers #{@retailer_ids}..."
  if @retailer_ids.blank?
    retailers = Retailer.where(is_active: true, is_generate_report: true, report_parent_id: nil) #.order(:id).all
  else
    retailers = Retailer.where(id: @retailer_ids.split(','))
  end
  
  @retailer_headers = ['Store Code','Store Name','Total Orders','Accepted Orders','Cancelled Orders','Total Orders in AED','Total Accepeted Orders in AED','Cancelled Orders in AED','Date From', 'Date To']
  @order_headers = ['Store Code','Store Name','Order ID','Cust. Name','Cust. Email','Cust. Phone','Cust. Order Count','Order Date','Order Time','Address','Area','Order Amount','Payment Method','Acceptance Duration','En-Route Duration','Attending Duration','Special Instructions','Cancel_message', 'Status','Coupon Amount','Paid From Wallet',OrderFeedback.Questions[:delivery],OrderFeedback.Questions[:speed],OrderFeedback.Questions[:accuracy],OrderFeedback.Questions[:price],OrderFeedback.Questions[:comments],'Schedule']
  @order_position_headers = ['OrderID','Barcode','Name','Quantity','Amount','Availability','Store Name']
  @reviews_headers = ['Store Code','Store Name','Cust. Name','Cust. Email','Cust. Phone','Overall Rating', 'Delivery Speed Rating', 'Order Accuracy Rating', 'Quality Rating', 'Price Rating', 'Comments']

  retailers.each do |retailer|
    puts "Fetch orders for retailer_id: #{retailer.id}..."
    excel_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}cumulative.xlsx")
    order_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}cumulative_summary.csv") #Tempfile.new('orders-')
    order_position_path =  "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}cumulative_orderdetail.csv")
    @summary_rows = []
    order_rows = []
    @review_rows = []
    summary_retailers = Retailer.where("id = #{retailer.id} or report_parent_id = #{retailer.id}")
    summary_retailers.each do |ret|
      total_orders = Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).count
      accepted_orders = Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).where.not(status_id: 4).count
      cancelled_orders = Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 4).count
      total_orders_amount = OrderPosition.where(order_id: Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate)).sum('ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)')
      accepted_orders_amount = OrderPosition.where(order_id: Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).where.not(status_id: 4)).sum('ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)')
      cancelled_orders_amount = OrderPosition.where(order_id: Order.where(retailer_id: ret.id).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 4)).sum('ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)')
      @summary_rows.push([ret.id,ret.company_name,total_orders,accepted_orders,cancelled_orders,total_orders_amount,accepted_orders_amount,cancelled_orders_amount, @startDate, @endDate])
    end
    # Get reviews into @review_rows
    store_reviews(summary_retailers, retailer)

    orders = Order.where(retailer_id: summary_retailers).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).order('created_at DESC')
      #.order('created_at DESC')
    #file_csv = CSV.generate do |csv|
    #CSV.open(order_path, "wb") do |csv|
        #csv << order_headers #Order.column_names
    orders.each do |order|
      order_count = Order.where(shopper_id: order.shopper_id, retailer_id: order.retailer_id).count
      # order_amount = OrderPosition.where(order_id: order.id).sum(:shop_price_cents)
      order_amount = order.order_positions.sum('ROUND(ROUND((order_positions.shop_price_dollars + (order_positions.shop_price_cents::numeric / 100)), 2) * order_positions.amount, 2)')
      payment_method = order.payment_type_id == 1 ? 'cash' : 'card'
      shopper_address = "#{order.shopper_address_apartment_number},#{order.shopper_address_building_name},#{order.shopper_address_street},#{order.shopper_address_area}"
      acceptance_duration =  order.accepted_at ? Time.at(order.accepted_at - order.created_at).utc.strftime("%H:%M:%S") : 'NA'
      enroute_duration = order.processed_at ? Time.at(order.processed_at - order.created_at).utc.strftime("%H:%M:%S") : 'NA'
      attending_duration = order.approved_at ? Time.at(order.approved_at - order.created_at).utc.strftime("%H:%M:%S") : 'NA'
      shopper_email = retailer.is_report_add_phone ? order.shopper.email : ''
      shopper_phone = retailer.is_report_add_email ? order.shopper_phone_number : ''
      promotion_discount = order.promotion_discount if order.promotion_code_realization.present?
      # schedule = "#{order.schedule_for}" if order.delivery_slot_id.present? && (order.delivery_slot).present?
      schedule = order.schedule_for
      feedback = order.order_feedback || OrderFeedback.new
      order_rows.push([order.retailer_id,order.retailer_company_name,order.id,order.shopper_name,shopper_email,shopper_phone,order_count,order.created_at,order.created_at,shopper_address,order.shopper_address_area,order_amount,payment_method,acceptance_duration,enroute_duration,attending_duration,order.shopper_note,order.message,order.status,promotion_discount,order.wallet_amount_paid,feedback.delivery_stars,feedback.speed,feedback.accuracy,feedback.price,feedback.comments,schedule]) 
      #order.attributes.values
    end
    #end
    self.insertDataIntoCsv(order_path, @order_headers, order_rows)

    # puts "Fetch order positions"
    position_rows = []
    order_positions = OrderPosition.where(order_id: orders)
    #CSV.open(order_position_path, "wb") do |csv|
    #    csv << order_position_headers #Order.column_names
    order_positions.each do |position|
      # position_amount = ((position.shop_price_dollars + (position.shop_price_cents / 100.0)).round(2) * position.amount).round(2)
      position_rows.push([position.order_id,position.product_barcode,position.product_name,position.amount,position.full_price,position.was_in_shop,position.order.retailer_company_name])
    end
    self.insertDataIntoCsv(order_position_path, @order_position_headers, position_rows)
    #end

    # puts "insert into excel"
    self.insertDataIntoExl(excel_path,order_rows,position_rows)

    # puts "Save into db"
    retailer_report = RetailerReport.new(name: 'orders', retailer_id: retailer.id, export_total: orders.count, from_date: @startDate, to_date: @endDate)
    retailer_report.file1 = File.open(order_path)
    retailer_report.file1.instance_write(:content_type, 'text/csv')
    retailer_report.file2 = File.open(order_position_path)
    retailer_report.file2.instance_write(:content_type, 'text/csv')
    retailer_report.excel = File.open(excel_path)
    retailer_report.excel.instance_write(:content_type, 'application/vnd.ms-excel')
    retailer_report.save!

    puts "OrdersCSV: #{retailer_report.file1.url}"
    puts "PositionsCSV: #{retailer_report.file2.url}"
    puts "Excel: #{retailer_report.excel.url}"

    RetailerMailer.order_report(retailer_report.id).deliver_later if retailer.report_emails.present?
    sleep(1)
    end
  end

  private

  def time_stamped_file(file)
    # file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d%H%M%S')}-#{@endDate.strftime('%Y%m%d%H%M%S')}.") 
    file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d')}-#{@endDate.strftime('%Y%m%d')}.") 
  end

  def self.insertDataIntoCsv(path, headers, data)
    CSV.open(path, "wb") do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

  def self.insertDataIntoExl(path,orders,positions)
    Axlsx::Package.new do |p|
      wb = p.workbook
      wb.styles do |s|
        light_gray =  s.add_style :b => true, :bg_color => "f3f3f3"
        light_blue =  s.add_style :b => true, :bg_color => "c9daf8"
        cell_bold =  s.add_style :b => true
        self.insertExlSheet(wb, 'Summary', @retailer_headers, light_blue, @summary_rows)
        self.insertExlSheet(wb, 'Header', @order_headers, light_blue, orders)
        self.insertExlSheet(wb, 'Line', @order_position_headers, light_blue, positions)
        self.insertExlSheet(wb, 'Reviews', @reviews_headers, light_blue, @review_rows)
      end
      p.serialize(path)
    end
  end

  def self.insertExlSheet(wb, sname, headers, style, rows)
    wb.add_worksheet(:name => sname) do |sheet|
      sheet.add_row headers, :style => style
      rows.each do |row|
        sheet.add_row row
      end
    end
  end

  def store_reviews(summary_retailers, retailer)
    retailer_reviews = RetailerReview.where(retailer_id: summary_retailers).where('date(created_at) BETWEEN ? AND ?', @startDate, @endDate).order('created_at DESC')
    retailer_reviews.each do |review|
      shopper_email = retailer.is_report_add_phone ? review.shopper.email : ''
      shopper_phone = retailer.is_report_add_email ? review.shopper.phone_number : ''
      ['Store Code','Store Name','Cust. Name','Cust. Email','Cust. Phone','Overall Rating', 'Delivery Speed Rating', 'Order Accuracy Rating', 'Quality Rating', 'Price Rating', 'Comments']
      @review_rows.push([review.retailer_id,review.retailer.company_name,review.shopper.name,shopper_email,shopper_phone,review.overall_rating,review.delivery_speed_rating,review.order_accuracy_rating,review.quality_rating,review.price_rating,review.comment]) 
    end
  end
  
end