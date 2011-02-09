module MCollective
    module Agent
        # A registration agent that places information from the meta
        # registration class into a mysql table.
        #
        # To get this going you need:
        #
        #  - The meta registration plugin everywhere
        #  - A mysql database
        #  - The mysql gem installed
        #
        # The following configuration options exist:
        #  - plugin.registration.mysql.host
        #  - plugin.registration.mysql.port
        #  - plugin.registration.mysql.user
        #  - plugin.registration.mysql.password
        #  - plugin.registration.mysql.database
        #  - plugin.registration.mysql.table
        #
        # The table will need the following columns
        #  - fqdn
        #  - classes
        #  - yaml
        #  - lastseen
        #
        # Released under the terms of the BSD licence
        class Registration
            attr_reader :timeout, :meta

            def initialize
                @meta = {:license => "BSD",
                         :author => "Kiall Mac Innes <kiall@managedit.ie>"}

                require 'mysql'

                @timeout = 2

                @config = Config.instance

                @mysqlhost = @config.pluginconf["registration.mysql.host"] || "localhost"
                @mysqlport = @config.pluginconf["registration.mysql.port"].to_i || 3306
                @mysqluser = @config.pluginconf["registration.mysql.user"] || "root"
                @mysqlpassword = @config.pluginconf["registration.mysql.password"] || ""
                @mysqldatabase = @config.pluginconf["registration.mysql.database"] || "puppet"
                @mysqltable = @config.pluginconf["registration.mysql.table"] || "registration"

                Log.instance.debug("Connecting to mysql @ #{@mysqlhost}:#{@mysqlport} db #{@mysqldatabase} table #{@mysqltable}")

                @dbh = Mysql.real_connect(@mysqlhost, @mysqluser, @mysqlpassword, @mysqldatabase, @mysqlport)
            end

            def handlemsg(msg, connection)
                req = msg[:body]

                classes = req[:classes].join(',')
                
                # Sometimes facter doesnt send a fqdn?!
                if req[:facts]["fqdn"].nil?
                    Log.instance.debug("Got stats without a FQDN in facts")
                    return nil
                end

                @dbh.query("INSERT INTO `#{@mysqltable}` (`fqdn`, `classes`, `yaml`, `lastseen`) VALUES ('#{@dbh.escape_string(req[:facts]["fqdn"])}', '#{@dbh.escape_string(classes)}', '#{@dbh.escape_string(YAML.dump(req))}', UNIX_TIMESTAMP())")

                Log.instance.debug("Adding new data for host #{req["fqdn"]}")

                nil
            end

            def help
            end
        end
    end
end