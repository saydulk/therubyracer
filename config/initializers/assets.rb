# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
Rails.application.config.assets.precompile.concat(
  %w[
    admin.css
    api_v2.css
    market.css
    admin.js
    api_v2.js
    funds.js
    html5.js
    market.js
    dirPagination.js
    landing.js
    node_modules/bootstrap/dist/css/bootstrap.min.css
    css/style.scss
    js/bootstrap.min.js
    js/owl.carousel.min.js
    jquery/dist/jquery.min.js
    newdesign.css
    global.css
    css/main.css
    js/jquery.min.js
    css/owl.carousel.min.css
    css/easy-responsive-tabs.css
    js/easyResponsiveTabs.js
    js/particles.min.js
    js/particle_app.js
    global/css/style.scss
    js/jquery.cookie
    css/trade.css
    font-awesome/css/font-awesome.min.css
    css/bootstrap.min.css
    css/terms.css
    css/contactus.css
    css/funds.scss
    charting_library/charting_library.min.js
    datafeeds/udf/dist/polyfills.js
    datafeeds/udf/dist/bundle.js
    angular-datepicker
    angular-datepicker.css
  ]
)

# Precompile all available locales
Rails.application.config.assets.precompile.concat(
  Dir.glob(Rails.root.join('app/assets/javascripts/locales/*.js.erb'))
     .map { |f| File.join('locales', File.basename(f, '.erb')) }
)
