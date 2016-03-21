require 'data_mapper'

module Shamwow
  class Products
    include DataMapper::Resource

    property :id,               Serial
    property :product_group,    String, :length => 50
    property :host_groups,      String, :length => 2000

  end
end