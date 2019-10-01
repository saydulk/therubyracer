module ApplicationHelper
  def document_to(key: nil, title: nil, &block)
    if title
      link_to(title, '', :data => {:remote => "#{main_app.document_path(key)}", :toggle => "modal", :target => '#document_modal'})
    elsif block
      link_to('', :data => {:remote => "#{main_app.document_path(key)}", :toggle => "modal", :target => '#document_modal'}, &block)
    end
  end

  def show_errors(object, field_name)
    if object.errors.any?
      if !object.errors.messages[field_name].blank?
        object.errors.messages[field_name].join(", ")
      end
    end
  end

  def detail_section_tag(title)
    content_tag('span', title, :class => 'detail-section') + \
    tag('hr')
  end

  def detail_tag(obj, title: 'detail', field: nil, cls: '', clip: nil)
    if field.present?
      field = field.to_s
      val = obj.instance_eval(field)
      display = val || 'N/A'
      content_tag('span', :class => "#{field} detail-item #{val ? nil : 'empty'}" + cls, :data => {:title => obj.class.han(field)}) do
        if clip and val
          content_tag('i', display, :class => 'fa fa-copy', :data => {:'clipboard-text' => display})
        else
          content_tag('span', display)
        end
      end
    else
      content_tag('span', obj, :class => 'detail-item ' + cls, :data => {title: title})
    end
  end

  def cs_link
    link_to t('helpers.action.customer_service'), "javascript:void(0);", :onclick => "olark('api.box.expand')"
  end

  def check_active(klass)

    if !params[:action].include?'index'
       data_statistic = ((klass.is_a?String and klass == 'statistic' and params[:controller].include?'statistic') ? true : false)
      return  ( data_statistic ? 'active' : (request.path == klass ? 'active' : ''))
    elsif klass.is_a? String
      return 'active' unless (controller.controller_path.exclude?(klass.singularize))
    else
      return 'active' if (klass.model_name.singular == controller.controller_name.singularize)
    end

  end

  def qr_tag(text)
    return if text.blank?
    content_tag :div, '', 'class'       => 'qrcode-container img-thumbnail',
                          'data-width'  => 272,
                          'data-height' => 272,
                          'data-text'   => text
  end

  def rev_category(type)
    type.to_sym == :bid ? :ask : :bid
  end

  def orders_json(orders)
    Jbuilder.encode do |json|
      json.array! orders do |order|
        json.id order.id
        json.bid order.bid
        json.ask order.ask
        json.category order.kind
        json.volume order.volume
        json.price order.price
        json.origin_volume order.origin_volume
        json.at order.created_at.to_i
      end
    end
  end

  def top_nav(link_text, link_path, link_icon, links = nil, controllers: [])
    if links && links.length > 1
      top_dropdown_nav(link_text, link_path, link_icon, links, controllers: controllers)
    else
      top_nav_link(link_text, link_path, link_icon, controllers: controllers)
    end
  end

  def top_market_link(market, current_market)
    class_name = ((market.id == current_market.id) ? 'active' : nil)

    content_tag(:li, :class => class_name) do
      link_to market_path(market.id)  do
        content_tag(:span, market.name)
      end
    end
  end

  def top_nav_link(link_text, link_path, link_icon, controllers: [], counter: 0, target: '')
    merged = (controllers & controller_path.split('/'))
    class_name = current_page?(link_path) ? 'active' : nil
    class_name ||= merged.empty? ? nil : 'active'

    content_tag(:li, :class => class_name) do
      link_to link_path, target: target do
        content_tag(:i, :class => "fa fa-#{link_icon}") do
          content_tag(:span, counter,class: "counter") if counter != 0
        end +
        content_tag(:span, link_text)
      end
    end
  end

  def top_dropdown_nav(link_text, link_path, link_icon, links, controllers: [])
    class_name = current_page?(link_path) ? 'active' : nil
    class_name ||= (controllers & controller_path.split('/')).empty? ? nil : 'active'

    content_tag(:li, class: "dropdown #{class_name}") do
      link_to(link_path, class: 'dropdown-toggle', 'data-toggle' => 'dropdown') do
        concat content_tag(:i, nil, class: "fa fa-#{link_icon}")
        concat content_tag(:span, link_text)
        concat content_tag(:b, nil, class: 'caret')
      end +
      content_tag(:ul, class: 'dropdown-menu') do
        links.collect do |link|
          concat content_tag(:li, link_to(*link))
        end
      end
    end
  end

  def history_links
    [ [t('header.order_history'), order_history_path],
      [t('header.trade_history'), trade_history_path],
      [t('header.account_history'), account_history_path] ]
  end

  def simple_vertical_form_for(record, options={}, &block)
    result = simple_form_for(record, options, &block)
    result = result.gsub(/#{SimpleForm.default_form_class}/, "simple_form").html_safe
    result.gsub(/col-xs-\d/, "").html_safe
  end

  def panel(name: 'default-panel', key: nil, &block)
    key ||= "guides.#{i18n_controller_path}.#{action_name}.#{name}"

    content_tag(:div, :class => 'panel panel-default') do
      content_tag(:div, :class => 'panel-heading') do
        content_tag(:h3, :class => 'panel-title') do
          I18n.t(key)
        end
      end +
      content_tag(:div, :class => 'panel-body') do
        capture(&block)
      end
    end
  end

  def locale_name
    I18n.locale.to_s.downcase
  end

  def time_zone_chart
    (set_timezone.class == ActiveSupport::TimeZone) ? JSON.parse(set_timezone.to_json)['tzinfo']['identifier'] : 'Etc/UTC'
  end

  def set_timezone
    Time.zone =  browser_timezone ||  ENV['TIMEZONE']
  end

  def browser_timezone
    @browser_timezone ||= begin
      ActiveSupport::TimeZone[-cookies[:tz].to_i.minutes]
    end if cookies[:tz].present?
  end

  def body_id
    "#{controller_name}-#{action_name}"
  end

  def balance_panel(member: nil)
    member ||= current_user
    panel name: 'balance-pannel', key: 'guides.panels.balance' do
      render partial: 'private/shared/balances', locals: {member: member}
    end
  end

  def guide_panel_title
    @guide_panel_title || t("guides.#{i18n_controller_path}.#{action_name}.panel", default: t("guides.#{i18n_controller_path}.panel"))
  end

  def guide_title
    @guide_title || t("guides.#{i18n_controller_path}.#{action_name}.title", default: t("guides.#{i18n_controller_path}.panel"))
  end

  def guide_intro
    @guide_intro || t("guides.#{i18n_controller_path}.#{action_name}.intro", default: t("guides.#{i18n_controller_path}.intro", default: ''))
  end

  def i18n_controller_path
    @i18n_controller_path ||= controller_path.gsub(/\//, '.')
  end

  def language_path(lang=nil)
    lang ||= I18n.locale
    asset_path("/languages/#{lang}.png")
  end

  def i18n_meta(key)
    t("#{i18n_controller_path}.#{action_name}.#{key}", default: :"layouts.meta.#{key}")
  end

  def description_for(name, &block)
    content_tag :dl, class: "dl-horizontal dl-#{name}" do
      capture(&block)
    end
  end

  def item_for(model_or_title, name='', value = nil, &block)
    if model_or_title.is_a? String or model_or_title.is_a? Symbol
      title = model_or_title
      capture do
        if block_given?
          content_tag(:dt, title.to_s) +
            content_tag(:dd, capture(&block))
        else
          value = name
          content_tag(:dt, title.to_s) +
            content_tag(:dd, value)
        end
      end
    else
      model = model_or_title
      capture do
        if block_given?
          content_tag(:dt, model.class.human_attribute_name(name)) +
            content_tag(:dd, capture(&block))
        else
          value ||= model.try(name)
          value = value.localtime if value.is_a? DateTime
          value = I18n.t(value) if value.is_a? TrueClass

          content_tag(:dt, model.class.human_attribute_name(name)) +
            content_tag(:dd, value)
        end
      end
    end
  end

  def yesno(val)
    if val
      content_tag(:span, 'YES', class: 'label label-success')
    else
      content_tag(:span, 'NO', class: 'label label-danger')
    end
  end

  def format_currency(number, currency, n: nil, symbol: true)
    currency_obj = Currency.find_by_code(currency.to_s)
    digit = n || currency_obj.decimal_digit
    decimal = (number || 0).to_d.round(0, digit)
    decimal = number_with_precision(decimal, precision: digit, delimiter: ',')
    if symbol
      "<span class='decimal'><small>#{currency_obj.symbol}</small>#{decimal}</span>"
    else
      "<span class='decimal'>#{decimal}</span>"
    end

  end

  def exchange_client(exchange)
    ("#{exchange.capitalize}::Api").constantize.new(ENV["#{exchange}_API_KEY"], ENV["#{exchange}_SECRET_KEY"])
  end

  def exchange_member(email)
    Member.find_by_email(email)
  end

  def user_activity_status(member_id)
    member = Member.find(member_id)
    "<label for='email'> Email : </label> <span class='member_activity' name='email'>#{member.email}</span> <label for='status'> Verified: </label> <span name='status'> #{yesno(member.id_document_verified?)} </span>"
  end

  alias_method :d, :format_currency

  def root_url_with_port_from_request
    port  = request.env['SERVER_PORT']
    parts = [request.protocol, request.domain]
    unless port.blank?
      parts << if request.ssl?
                 port == '443' ? '' : ":#{port}"
               else
                 port == '80' ? '' : ":#{port}"
               end
    end
    parts.join('')
  end

  def custom_stylesheet_link_tag_for(layout)
    if File.file?(Rails.root.join('public/custom-stylesheets', "#{layout}.css"))
      tag :link, \
        rel:   'stylesheet',
          media: 'screen',
          href:  "/custom-stylesheets/#{layout}.css"
    end
  end

  def currency_change_percentage(p1, p2)
    p1 = p1.to_f
    p2 = p2.to_f
    percent =  (p1 && p1 > 0) ? (100*(p2-p1)/p1).round(2) : 0
    formatted_val = sprintf('%.2f', percent)
    "#{p1 > p2 ? '':'+'}#{formatted_val}%"
  end

  def decimal_select(code)
    content_tag(:select, class:'slct_box') do
      raw 5.times.map { |n| content_tag(:option, value: n) { "Option #{1}" } }.join
    end
  end

  def calculate_commission(currency, modifiable_type, commission_list)
    result = commission_list.where(currency: currency , modifiable_type: modifiable_type)
    if result.present?
      return result.first.total_commission
    else
      return 0
    end
  end

  def get_currency_precision(object)
    currency = Currency.find_by_code(object.currency)
    [currency.precision, currency.quick_withdraw_min]
  end

  def central_address(object)
    Wallet.find_by_currency_id(object.currency)&.address.to_s
  end

  def enum_options_for_select(class_name, enum)
    gender_list = ['Male','Female','Other']
    gender_collection = {}
    gender_list.each_with_index do |key,index|
      gender_collection[index] = enum_i18n(class_name, enum, key)
    end
    gender_collection
  end

  # Returns the i18n version the models current enum key
  # Example usage:
  # enum_l(user, :approval_state)
  def enum_l(model, enum)
    enum_i18n(model.class, enum, model.send(enum))
  end

  # Returns the i18n string for the enum key
  # Example usage:
  # enum_i18n(User, :approval_state, :unprocessed)
  def enum_i18n(class_name, enum, key)
    I18n.t("activerecord.enums.#{class_name.model_name.i18n_key}.#{enum.to_s}.#{key}")
  end

  def step_number(market)
    (10**(market.ask["fixed"]* -1)).to_f
  end

  def domain_url(keys = {})
    domain_url = "#{ENV.fetch('URL_SCHEME', 'http')}://#{ENV['URL_HOST']}"
    keys.each_with_index do |(key, val), index|
      opt = (index == 0) ? '?' : '&'
      domain_url +="#{opt}#{key}=#{val}"
    end
    domain_url
  end

  def formate_date(created_at)
    created_at.strftime("%Y/%m/%d %I:%M %p")
  end

  def mobile_device
    agent = request.user_agent
    return "tablet" if agent =~ /(tablet|ipad)|(android(?!.*mobile))/i
    return "mobile" if agent =~ /Mobile/
    return "desktop"
  end

end
