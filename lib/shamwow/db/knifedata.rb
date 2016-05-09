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
  end

  class KnifeRole
    include DataMapper::Resource

    property :id,                 Serial
    property :name,               String, length: 100
    property :polltime,           DateTime

    has n, :knife_role_links, :child_key => [ :role_id ]
  end

  class KnifeRoleLink
    include DataMapper::Resource

    belongs_to  :knife, 'KnifeData',  :key => true
    belongs_to  :role,  'KnifeRole',  :key => true
  end

  class KnifeRunlist
    include DataMapper::Resource

    property :id,                 Serial
    property :name,               String, length: 100
    property :polltime,           DateTime

    has n, :knife_runlist_links, :child_key => [ :runlist_id ]
  end

  class KnifeRunlistLink
    include DataMapper::Resource

    belongs_to  :knife, 'KnifeData',  :key => true
    belongs_to  :runlist,  'KnifeRunlist',  :key => true
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
    has n, :knife_role_links, :child_key => [ :knife_id ]
    has n, :knife_runlist_links, :child_key => [ :knife_id ]

    has n, :cookbooks, KnifeCkbk, :through => :knife_ckbk_links, :via => :ckbk
    has n, :runlists, KnifeRunlist, :through => :knife_runlist_links, :via => :runlist
    has n, :runlists, KnifeRole, :through => :knife_role_links, :via => :role
  end


end