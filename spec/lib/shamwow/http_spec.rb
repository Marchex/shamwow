require 'rspec'
require 'shamwow/http'

describe 'Http' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should remove the header line' do
    #
    # Arrange
    h = Shamwow::Http.new
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = h.remove_header("[ETHSWITCH]: [LOCALINTERFACE] [LINKSTATE] [DESCRIPTION]\t\t11638 uniqe records\na01-tor-a.som1.marchex.com: mgt up MGT \n")
    #
    # Assert
    expect(result).to eq("a01-tor-a.som1.marchex.com: mgt up MGT \n")
  end

  it 'should parse netools layer1 data' do
    #
    # arrange
    h = Shamwow::Http.new
    #
    # act
    result = h.parse_layer1("a01-tor-a.som1.marchex.com: mgt up MGT
a01-tor-a.som1.marchex.com: port10 up r630a0101_s2_data
a01-tor-a.som1.marchex.com: port11 up r630a0102_s1_stor
")
    #
    # asset
    #execpt(result).to
  end

end
