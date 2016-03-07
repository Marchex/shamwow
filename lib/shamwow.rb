require "shamwow/version"
require 'pg'

module Shamwow
  class Db

      puts "hello"

      def foo(a)
        puts "hello init #{a}"
      end

      def bar
        conn = PG.connect( dbname: 'shamwow' )
        conn.exec( "SELECT * FROM pg_stat_activity" ) do |result|
          puts "     PID | User             | Query"
          result.each do |row|
            puts " %7d | %-16s | %s " % row.values_at('pid', 'usename', 'query')
          end
        end
      end

  end
end


