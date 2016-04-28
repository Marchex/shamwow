require 'net/ssh'
require 'shamwow/db'
require 'json'


module Shamwow
  class Knife
    def initialize(db)
      @db = db
      @nodes = {}
      @cookbooks = {}
      @ckbklinks = {}
      @runlists = {}
      @rllinks = {}
    end

    def get_status(fromhost)
      Net::SSH.start(fromhost, $user) do |ssh|
        ssh.exec!("knife status -F json 'fqdn:*'")
      end
    end

    def load_data
      @nodes     = KnifeData.all
      @cookbooks = KnifeCkbk.all
      @ckbklinks = KnifeCkbkLink.all
    end

    def parse_status(output)
      nowtime = Time.now
      data = JSON.parse(output)
      data.each do |n|
        #p n
        o = KnifeData.first_or_new( { :name => n["name"] })

        o.attributes={ :chefenv => n["chef_environment"],
                       :ip => n["ip"],
                       :ohai_time => Time.at(n["ohai_time"]).to_datetime,
                       :platform => n["platform"],
                       :platform_version => n["platform_version"],
                       :polltime => nowtime }
        o.save
      end
    end

    def get_cookbooks(fromhost)
      Net::SSH.start(fromhost, $user) do |ssh|
        ssh.exec!("knife search node 'fqdn:*' -a cookbooks -Fj")
      end
    end
    # {
    #     "results": 1,
    #     "rows": [
    #       {
    #           "pulleyserver1.sea1.marchex.com": {
    #             "cookbooks": {
    #                 "apt": {
    #                   "version": "1.9.0"
    #                 }
    def parse_cookbooks(output)
      nowtime = Time.now
      data = JSON.parse(output)

      data["rows"].each do |hash|
        (name, obj) = hash.first
        next if obj["cookbooks"].nil?

        o = KnifeData.first_or_new( { :name => name })

        obj["cookbooks"].each do |ckbk, attrs|
          cb = KnifeCkbk.first_or_new({ :name => ckbk, :version => attrs["version"] })
          cb.attributes = {
              :polltime => nowtime
          }
          cb.save
          c = o.knife_ckbk_links.first_or_new({ :knife_id => o.id, :ckbk_id => cb.id })
          c.attributes = { :polltime => nowtime }
          c.save
        end

        o.attributes = { :polltime => nowtime }
        o.save
      end

    end


    def get_node(name)

      @nodes
    end

    def save_records
      nodes.each_value do |o|
        o.save
      end
    end

    def expire_records(expire_time)
      stale = KnifeData.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} KnifeData records"
      stale.destroy
      stale = KnifeCkbk.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} KnifeCkbk records"
      stale.destroy
      stale = KnifeCkbkLink.all(:polltime.lt => Time.at(Time.now.to_i - expire_time))
      puts "#{Time.now} Expiring #{stale.count} KnifeCkbkLink records"
      stale.destroy
    end
  end
end

