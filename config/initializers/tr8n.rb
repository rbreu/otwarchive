Rails.configuration.after_initialize do 
 
  class Tr8n::Config
    
    def self.user_name(user)
      current_user.default_pseud.id.to_s
    end
 
    def self.user_admin(user)
      current_user.translation_admin?
    end

    def self.user_guest(user)
      !logged_in?
    end

      
  end
 
end
