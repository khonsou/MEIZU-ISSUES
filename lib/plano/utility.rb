module Plano
  module Utility
    def self.resolve_distribution_list(email)
      result = nil
      AuthSourceLdap.all.each do |auth_source_ldap|
        result = resolve_distribution_list_with_auth_source_ldap(email, auth_source_ldap) rescue nil
        if result && ! result.empty?
          break
        end
      end
      result.nil? ? [] : result
    end

    # this is a quick implementation. we may update it to work for any active directory/ldap scheme in the future
    def self.resolve_distribution_list_with_auth_source_ldap(email, auth_source_ldap)
      ldap = Net::LDAP.new
      ldap.host = auth_source_ldap.host
      ldap.port = auth_source_ldap.port

      ldap.auth auth_source_ldap.account, auth_source_ldap.account_password
      unless ldap.bind
        raise "failed to bind"
      end

      filter = Net::LDAP::Filter.eq("mail", email)
      members = []

      ldap.search(:base => auth_source_ldap.base_dn, :filter => filter) do |entry|
        entry.each do |attribute, values|
          if attribute == :member
            values.each do |value|
              if value =~ /^CN=([^,]+),/
                members << $1
              end
            end
          end
        end
      end
      if email =~ /\@(.*)$/
        domain = $1
      else
        raise "failed to get email domain"
      end
      members.map{|m| "#{m}@#{domain}"}
    end
  end
end
