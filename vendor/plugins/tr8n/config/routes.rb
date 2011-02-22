ActionController::Routing::Routes.draw do |map|
  [:chart, :dashboard, :language_cases, 
   :language, :phrases, :translations, :translator, :login].each do |ctrl|   
    map.connect "tr8n/#{ctrl}/:action", :controller => "tr8n/#{ctrl}"
  end

  [:chart, :clientsdk, :language, :translation, :translation_key, :translator, :domain].each do |ctrl|   
    map.connect "tr8n/admin/#{ctrl}/:action", :controller => "tr8n/admin/#{ctrl}"
  end
  
  [:language, :translation, :translator].each do |ctrl|   
    map.connect "tr8n/api/v1/#{ctrl}/:action", :controller => "tr8n/api/v1/#{ctrl}"
  end
  
end
