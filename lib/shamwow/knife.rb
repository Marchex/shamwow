require 'net/ssh'
require 'shamwow/db'
require 'json'


module Shamwow
  class Knife
    def initialize(db)
      @db = db
      @nodes = {}
      @cookbooks = {}
      @runlists = {}
      @roles = {}
    end

    def get_status(fromhost)
      if fromhost == 'localhost'
        foo = exec("knife status -F json 'fqdn:*'") # this exex doesnt behave like ssh.exec!
      else
        Net::SSH.start(fromhost, $user) do |ssh|
          foo = ssh.exec!("knife status -F json 'fqdn:*'")
        end
      end
      foo
    end

    def load_data
      @nodes     = KnifeData.all
      puts "#{Time.now} Loaded #{@nodes.count} KnifeData records"
      @cookbooks = KnifeCkbk.all
      puts "#{Time.now} Loaded #{@cookbooks.count} KnifeCkbk records"
      @roles     = KnifeRole.all
      puts "#{Time.now} Loaded #{@roles.count} KnifeRole records"
      @runlists  = KnifeRunlist.all
      puts "#{Time.now} Loaded #{@runlists.count} KnifeRunlist records"
    end

    def parse_status(output)
      nowtime = Time.now
      data = JSON.parse(output)
      data.each do |n|
        #p n
        o = @nodes.first_or_new( { :name => n["name"] })

        o.attributes={ :chefenv => n['chef_environment'],
                       :ip => n['ip'],
                       :ohai_time => Time.at(n['ohai_time']).to_datetime,
                       :platform => n['platform'],
                       :platform_version => n['platform_version'],
                       :polltime => nowtime }
        o.save
      end
    end

    def get_attributes(fromhost)
      Net::SSH.start(fromhost, $user) do |ssh|
        ssh.exec!("knife search node 'fqdn:*' -a cookbooks -a roles -a run_list -Fj")
      end
    end
    # {
    #     "results": 1,
    #     "rows": [
    #       {  <--- hostobj
    #           "pulleyserver1.sea1.marchex.com": {
    #             "cookbooks": {
    #                 "apt": {
    #                   "version": "1.9.0"
    #                 }
    def parse_attributes(output)
      nowtime = Time.now
      data = JSON.parse(output)

      data['rows'].each do |hostobj|
        (name, obj) = hostobj.first

        if obj['cookbooks']
          parse_cookbooks(name, nowtime, obj['cookbooks'])
        end

        if obj['roles']
          parse_roles(name, nowtime, obj['roles'])
        end

        if obj['run_list']
          parse_runlists(name, nowtime, obj['run_list'])
        end

      end

    end

    def parse_cookbooks(host, time, data)
      node = @nodes.first_or_new( { :name => host })

      old_set = Hash[node.knife_ckbk_links.all.map {|o| [o.ckbk_id, o.ckbk_id] } ]
      new_set = get_cookbooks(data)

      # Find new links, link them
      new_set.each do |id, label|
        if old_set[id].nil?
          @db.save_log('knife_cookbook', host, 'create', "Creating link to ckbk #{label}")
          node.knife_ckbk_links.first_or_new({ :ckbk_id => id })
        end
      end
      # Find stale links, unlink them
      old_set.each do |id, v|
        if new_set[id].nil?
          ckbk = @cookbooks.first(:id => v)
          @db.save_log('knife_cookbook', host, 'delete', "Deleting link to ckbk #{ckbk.name}-#{ckbk.version}")
          node.knife_ckbk_links.first({ :ckbk_id => id }).destroy
        end
      end

      node.attributes = { :polltime => time }
      node.save
    end

    def parse_roles(host, time, data)
      node = @nodes.first_or_new( { :name => host })

      old_set = Hash[node.knife_role_links.all.map {|o| [o.role_id, o.role_id] } ]
      new_set = get_roles(data)

      # Find new links, link them
      new_set.each do |id, label|
        if old_set[id].nil?
          @db.save_log('knife_role', host, 'create', "Creating link to role #{label}")
          node.knife_role_links.first_or_new({ :role_id => id })
        end
      end
      # Find stale links, unlink them
      old_set.each do |id, v|
        if new_set[id].nil?
          role = roles.first(:id => v)
          @db.save_log('knife_role', host, 'delete', "Deleting link to role #{role.name}-#{role.version}")
          node.knife_role_links.first({ :role_id => id }).destroy
        end
      end

      node.attributes = { :polltime => time }
      node.save
    end

    def parse_runlists(host, time, data)
      node = @nodes.first_or_new( { :name => host })

      old_set = Hash[node.knife_runlist_links.all.map {|o| [o.runlist_id, o.runlist_id] } ]
      new_set = get_runlists(data)

      # Find new links, link them
      new_set.each do |id, label|
        if old_set[id].nil?
          @db.save_log('knife_runlist', host, 'create', "Creating link to runlist #{label}")
          o = node.knife_runlist_links.first_or_new({ :runlist_id => id })
          o.save
        end
      end
      # Find stale links, unlink them
      old_set.each do |id, v|
        if new_set[id].nil?
          rl = @runlists.first(:id => v)
          @db.save_log('knife_runlist', host, 'delete', "Deleting link to runlist #{rl.name}-#{rl.version}")
          node.knife_runlist_links.first({ :runlist_id => id }).destroy
        end
      end

      node.attributes = { :polltime => time }
      node.save

    end

    def get_cookbooks(data)
      set = {}
      data.each do |ckbk, attrs|
        cb = @cookbooks.first_or_create({ :name => ckbk, :version => attrs['version'] })
        cb.attributes = { :polltime => Time.now }
        cb.save
        set[cb.id] = ckbk + '-' + attrs['version']
      end
      set
    end

    def get_roles(data)
      set = {}
      data.each do |role|
        r = @roles.first_or_create({ :name => role })
        r.attributes = { :polltime => Time.now }
        r.save
        set[r.id] = role
      end
      set
    end

    def get_runlists(data)
      set = {}
      data.each do |runlist|
        r = @runlists.first_or_create({ :name => runlist })
        r.attributes = { :polltime => Time.now }
        r.save
        set[r.id] = runlist
      end
      set
    end

    def get_node(name)

      @nodes
    end

    def save_records
      puts 'Saving '
      nodes.each_value do |o|
        o.save
        puts '.'
      end
    end

    def expire_records(expire_time)
      stale = @nodes.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      stale.each do |n|
        @db.save_log('knife_node', n['name'], 'expire', 'Expiring node from knife status')
      end
      stale.destroy!
      #
      #
      stale = @cookbooks.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      stale.each do |n|
        @db.save_log('knife_cookbook', n['name'], 'expire', 'Expiring cookbook from knife search node')
      end
      stale.destroy!
      #
      #
      stale = @roles.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} KnifeRole records"
      stale.each do |n|
        @db.save_log('knife_role', n['name'], 'expire', 'Expiring role from knife search node')
      end
      stale.destroy!
      #
      #
      stale = @runlists.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      stale.each do |n|
        @db.save_log('knife_runlist', n['name'], 'expire', 'Expiring runlist from knife search node')
      end
      stale.destroy!
    end
  end
end

