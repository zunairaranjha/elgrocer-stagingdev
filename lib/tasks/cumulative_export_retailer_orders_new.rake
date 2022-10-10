namespace :cumulative_delivered_orders do
  desc 'Export retailer orders'
  task export: :environment do

    @days = ENV['days_from'].to_i || 1
    @days_to = ENV['days_to'].to_i
    @retailer_ids = ENV['storeids']
    @report_type = ENV['report_type'] || 'd' #d=daily,w=weekly,m=monethly

    @days = 7 if @report_type.downcase == 'w'
    @days = 1.day.ago.to_date.day if @report_type.downcase == 'm'

    @startDate = @days.day.ago.to_date
    @endDate = @days_to.day.ago.to_date || Time.now.to_date
    # puts "Fetch retailers #{@retailer_ids}..."
    retailers =
      if @retailer_ids.blank?
        Retailer.where(is_active: true, is_generate_report: true).where('report_parent_id = id') #.order(:id).all
      else
        Retailer.where(id: @retailer_ids.split(','))
      end

    @retailer_headers = ['Store Code', 'Store Name', 'Date', 'Total Orders', 'Total Sales', 'Cancelled Orders', 'Cancelled Sales', 'En Route & Delivered Orders', 'En Route & Delivered Sales', 'Online Orders', 'Online Sales', 'Accepted Orders', 'Accepted Sales', 'In Substitution Orders', 'In Substitution Sales', 'Pending Orders', 'Pending Sales']
    @order_headers = ['Store Code', 'Store Name', 'Order ID', 'Status', 'Cust. Name', 'Cust. Order Count', 'Order Date', 'Schedule', 'Order Amount', 'Payment Method', 'Acceptance Duration', 'En-Route Duration', 'Special Instructions', 'Cancel_message', 'Coupon Amount', 'Paid From Wallet']
    @order_position_headers = ['OrderID', 'Barcode', 'Name', 'Quantity', 'Amount', 'Availability', 'Store Name']
    @reviews_headers = ['Store Code', 'Store Name', OrderFeedback.Questions[:delivery], OrderFeedback.Questions[:speed], OrderFeedback.Questions[:accuracy], OrderFeedback.Questions[:price], OrderFeedback.Questions[:comments]]
    @online_order_headers = ['OrderID', 'Order Date', 'Checkout Date', 'Checkout Time', 'Transaction Id', 'Receipt Id', 'Original Amount', 'Final Amount']

    retailers.each do |retailer|
      puts "Fetch orders for retailer_id: #{retailer.id}..."
      excel_path = "#{Rails.root.to_s}/tmp/" + time_stamped("#{retailer.company_name.gsub("'", "")}.xlsx")
      order_path = "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}cumulative_summary.csv") #Tempfile.new('orders-')
      order_position_path = "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}cumulative_orderdetail.csv")
      online_orders_path = "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}online_orders_detail.csv")
      retailer_review_path = "#{Rails.root.to_s}/tmp/" + time_stamped_file("#{retailer.id}retailer_review.csv")
      @summary_rows = []
      order_rows = []
      online_orders_row = []
      @review_rows = []
      summary_retailers = Retailer.where("id = #{retailer.id} or report_parent_id = #{retailer.id}")
      summary_retailers.each do |ret|
        total_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where.not(status_id: -1).count
        total_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).sum('total_value + service_fee + delivery_fee')
        pending_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 0).count
        pending_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 0).sum('total_value + service_fee + delivery_fee')
        accepted_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 1).count
        accepted_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 1).sum('total_value + service_fee + delivery_fee')
        substituting_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 6).count
        substituting_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 6).sum('total_value + service_fee + delivery_fee')
        processed_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: [2, 3, 5]).count
        processed_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: [2, 3, 5]).sum('total_value + service_fee + delivery_fee')
        cancelled_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 4).count
        cancelled_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(status_id: 4).sum('total_value + service_fee + delivery_fee')
        if DRIVER_PILOT_RETAILER_IDS.include?(ret.id)
          online_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where('payment_type_id in (1,2,3)').count
          online_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where('payment_type_id in (1,2,3)').sum('total_value + service_fee + delivery_fee')
        else
          online_orders = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(payment_type_id: 3).count
          online_orders_amount = Order.where(retailer_id: ret.id).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where(payment_type_id: 3).sum('total_value + service_fee + delivery_fee')
        end
        @summary_rows.push([ret.id, ret.company_name, @startDate, total_orders, total_orders_amount, cancelled_orders, cancelled_orders_amount, processed_orders, processed_orders_amount, online_orders, online_orders_amount, accepted_orders, accepted_orders_amount, substituting_orders, substituting_orders_amount, pending_orders, pending_orders_amount])
      end
      # Get reviews into @review_rows
      # store_reviews(summary_retailers, retailer)

      orders = Order.where(retailer_id: summary_retailers).where('date(orders.estimated_delivery_at) BETWEEN ? AND ?', @startDate, @endDate).where.not(status_id: -1).order('created_at DESC')

      orders.each do |order|
        order_count = Order.where(shopper_id: order.shopper_id, retailer_id: order.retailer_id).where.not(status_id: -1).count
        order_amount = (order.total_value.to_f + order.delivery_fee.to_f + order.service_fee.to_f)
        acceptance_duration = order.accepted_at ? Time.at(order.accepted_at - order.created_at).utc.strftime('%H:%M:%S') : 'NA'
        enroute_duration = order.processed_at ? Time.at(order.processed_at - order.created_at).utc.strftime('%H:%M:%S') : 'NA'
        promotion_discount = order.promotion_discount if order.promotion_code_realization.present?
        schedule = order.schedule_for
        payment_method = order.payment_type
        if DRIVER_PILOT_RETAILER_IDS.include?(order.retailer_id) && [1,2,3].include?(payment_method)
          payment_method = 'Online Payment'
          trans_id = []
          trans_amount = 0
          check_out_time = nil
          payment_logs = Analytic.where(owner: order, event_id: [21, 24])
          if payment_logs.length.positive?
            payment_logs.each do |log|
              check_out_time = log.created_at
              detail = JSON(log.detail.gsub('=>', ':'))
              trans_id.push("'#{detail['fort_id']}")
              trans_amount += (detail['amount'].to_i / 100.0)
            end
            online_orders_row.push([order.id, order.created_at, check_out_time, Time.at(check_out_time).utc.strftime('%H:%M:%S'), trans_id.join(', '), order.receipt_no, (order.total_value.to_f + order.delivery_fee.to_f + order.service_fee.to_f), trans_amount])
          end
        end
        order_rows.push([order.retailer_id, order.retailer_company_name, order.id, order.status, order.shopper_name, order_count, order.created_at, schedule, order_amount, payment_method, acceptance_duration, enroute_duration, order.shopper_note, order.message, promotion_discount, order.wallet_amount_paid])
      end

      self.insertDataIntoCsv(order_path, @order_headers, order_rows)

      # orders.where(payment_type_id: 3).each do |order|
      #   trans_id = []
      #   trans_amount = 0
      #   check_out_time = nil
      #   payment_logs = Analytic.where(owner: order, event_id: [21, 24])
      #   if payment_logs.length.positive?
      #     payment_logs.each do |log|
      #       check_out_time = log.created_at
      #       detail = JSON(log.detail.gsub('=>', ':'))
      #       trans_id.push("'#{detail['fort_id']}")
      #       trans_amount += (detail['amount'].to_i / 100.0)
      #     end
      #     online_orders_row.push([order.id, order.created_at, check_out_time, Time.at(check_out_time).utc.strftime('%H:%M:%S'), trans_id.join(', '), order.receipt_no, (order.total_value.to_f + order.delivery_fee.to_f + order.service_fee.to_f), trans_amount])
      #   end
      # end

      self.insertDataIntoCsv(online_orders_path, @online_order_headers, online_orders_row)

      # puts "Fetch order positions"
      position_rows = []
      order_positions = OrderPosition.joins(:order).select('order_positions.order_id, order_positions.product_barcode, order_positions.product_name, order_positions.amount, order_positions.shop_price_dollars, order_positions.shop_price_cents, order_positions.was_in_shop, order_positions.promotional_price, orders.retailer_company_name as retailer_name').where(order_id: orders)
      order_positions.each do |position|
        position_rows.push([position.order_id, position.product_barcode, position.product_name, position.amount, position.full_price, position.was_in_shop, position.retailer_name])
      end
      order_substitutions = OrderSubstitution.joins(:order).select('order_substitutions.id, order_substitutions.substitute_detail, orders.retailer_company_name as retailer_name').where(order_id: orders, is_selected: true).where.not(substitute_detail: nil)
      order_substitutions.each do |substitution|
        op = OrderPosition.new(substitution.substitute_detail)
        position_rows.push([op.order_id, op.product_barcode, op.product_name, op.amount, op.full_price, op.was_in_shop, substitution.retailer_name])
      end

      self.insertDataIntoCsv(order_position_path, @order_position_headers, position_rows)

      reviews_rows = []
      retailer_reviews = OrderFeedback.joins(:order).select('order_feedbacks.*, orders.retailer_id as retailer_id, orders.retailer_company_name as retailer_name').where(order_id: orders)
      retailer_reviews.each do |review|
        reviews_rows.push([review.retailer_id, review.retailer_name, review.delivery_stars, review.speed, review.accuracy, review.price, review.comments])
      end
      self.insertDataIntoCsv(retailer_review_path, @reviews_headers, reviews_rows)

      self.insertDataIntoExcel(excel_path, order_rows, position_rows, online_orders_row, reviews_rows)

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

      RetailerMailer.order_report_new(retailer_report.id, @days, @days_to).deliver_later if retailer.report_emails.present?
      sleep(1)
    end
  end

  private

  def time_stamped_file(file)
    # file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d%H%M%S')}-#{@endDate.strftime('%Y%m%d%H%M%S')}.")
    file.gsub(/\./, "_#{@startDate.strftime('%Y%m%d')}-#{@endDate.strftime('%Y%m%d')}.")
  end

  def time_stamped(file)
    # file.gsub(/\./,"_#{@startDate.strftime('%Y%m%d%H%M%S')}-#{@endDate.strftime('%Y%m%d%H%M%S')}.")
    (@days == @days_to) ? file.gsub(/\./, " #{@startDate.strftime('%Y-%m-%d')} elGrocer.") : file.gsub(/\./, " #{@startDate.strftime('%Y-%m-%d')} to #{@endDate.strftime('%Y-%m-%d')} elGrocer.")
  end

  def self.insertDataIntoCsv(path, headers, data)
    CSV.open(path, 'wb') do |csv|
      csv << headers
      data.each do |row|
        csv << row
      end
    end
  end

  def self.insertDataIntoExcel(path, orders, positions, online_orders, reviews)
    Axlsx::Package.new do |p|
      wb = p.workbook
      wb.styles do |s|
        light_gray = s.add_style :b => true, :bg_color => 'f3f3f3'
        light_blue = s.add_style :b => true, :bg_color => 'c9daf8'
        cell_bold = s.add_style :b => true
        self.insertSheet(wb, 'Summary', @retailer_headers, light_blue, @summary_rows)
        self.insertSheet(wb, 'Order Details & Status', @order_headers, light_blue, orders)
        self.insertSheet(wb, 'Online Orders', @online_order_headers, light_blue, online_orders)
        self.insertSheet(wb, 'Item & OOS details', @order_position_headers, light_blue, positions)
        self.insertSheet(wb, 'Reviews', @reviews_headers, light_blue, reviews)
      end
      p.serialize(path)
    end
  end

  def self.insertSheet(wb, sname, headers, style, rows)
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
      ['Store Code', 'Store Name', 'Cust. Name', 'Cust. Email', 'Cust. Phone', 'Overall Rating', 'Delivery Speed Rating', 'Order Accuracy Rating', 'Quality Rating', 'Price Rating', 'Comments']
      @review_rows.push([review.retailer_id, review.retailer.company_name, review.shopper.name, shopper_email, shopper_phone, review.overall_rating, review.delivery_speed_rating, review.order_accuracy_rating, review.quality_rating, review.price_rating, review.comment])
    end
  end

end