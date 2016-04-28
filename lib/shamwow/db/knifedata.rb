require 'data_mapper'

module Shamwow

  class KnifeCkbk
    include DataMapper::Resource

    property :id,                 Serial
    property :name,               String, length: 100
    property :version,            String
    property :polltime,           DateTime

    has n, :knife_ckbk_links, :child_key => [ :ckbk_id ]
  end

  class KnifeCkbkLink
    include DataMapper::Resource

    belongs_to  :knife, 'KnifeData',  :key => true
    belongs_to  :ckbk,  'KnifeCkbk',  :key => true
    property    :polltime,            DateTime
  end

  class KnifeData
    include DataMapper::Resource

    property :id,                 Serial
    property :name,               String, length: 200
    property :chefenv,            String, length: 100
    property :ip,                 String, length: 15
    property :ohai_time,          DateTime
    property :platform,           String
    property :platform_version,   String
    property :polltime,           DateTime


    has n, :knife_ckbk_links, :child_key => [ :knife_id ]
    has n, :cookbooks, KnifeCkbk, :through => :knife_ckbk_links, :via => :ckbk
  end


end