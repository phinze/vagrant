module VagrantPlugins
  module GuestDebian
    module Cap
      class ChangeHostName
        def self.change_host_name(machine, name)
          machine.communicate.tap do |comm|
            old = get_current_hostname(comm)

            unless old == name
              update_hostname(comm, name)
              update_etc_hosts(comm, old, name)
              refresh_hostname_service(comm)
              renew_dhcp(comm)
            end
          end
        end

        def self.get_current_hostname(comm)
          comm.sudo "hostname -f" do |type, data|
            return data.chomp if type == :stdout
          end
          nil
        end

        def self.update_hostname(comm, name)
          comm.sudo("sed -i 's/^.*$/#{name.split('.').first}/' /etc/hostname")
        end

        # /etc/hosts should resemble:
        # 127.0.0.1   localhost
        # 127.0.1.1   host.fqdn.com host.fqdn host
        def self.update_etc_hosts(comm, old, name)
          ip_address = '([0-9]{1,3}\.){3}[0-9]{1,3}'
          search     = "^(#{ip_address})\\s+#{old}\\b.*$"
          replace    = "\\1\\t#{hostname_with_aliases(name)}"
          expression = ['s', search, replace, 'g'].join('@')

          comm.sudo("sed -ri '#{expression}' /etc/hosts")
        end

        # given 'host.fqdn.com'
        # returns 'host.fqdn.com host.fqdn host'
        def self.hostname_with_aliases(hostname)
          hostname.split('.').inject([]) do |aliases, part|
            aliases << (aliases.last.to_s.split('.') << part).join('.')
          end.reverse.join(' ')
        end

        def self.refresh_hostname_service(comm)
          comm.sudo("hostname -F /etc/hostname")
        end

        def self.update_mailname(comm)
          comm.sudo("hostname --fqdn > /etc/mailname")
        end

        def self.renew_dhcp(comm)
          comm.sudo("ifdown -a; ifup -a; ifup eth0")
        end
      end
    end
  end
end
