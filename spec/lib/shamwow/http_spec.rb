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
as1-a01-admin.som1.marchex.com: gi0/10 up r630a0101_ipmi
as1-a01-admin.som1.marchex.com: gi0/10 up
")
    #
    # asset
    expect(result.count).to eq(5)
    expect(result[0]).not_to eq(nil)
    expect(result[1]).not_to eq(nil)
    expect(result[2]).not_to eq(nil)
    expect(result[3]).not_to eq(nil)
    expect(result[4]).not_to eq(nil)
  end

  it 'should parse netools layer2 data' do
    #
    # arrange
    h = Shamwow::Http.new
    #
    # act
    result = h.parse_layer2(h.remove_header("[ETHSWITCH]: [LOCALINTERFACE] [MACADDRESS] v[VLANID] 		7101 uniqe records
a01-tor-a.som1.marchex.com: port10 5254005df409 v3000
sad01cr01-01.sad.marchex.com: ip,assigned 0019b9c75cb5 v3013
sad01cr01-01.sad.marchex.com: ip,assigned 00225560ef01 v40
a01-tor-a.som1.marchex.com: port10 525400854499 v3000
"))
    #
    # asset
    expect(result.count).to eq(4)
    expect(result[0]).not_to eq(nil)
    expect(result[1]).not_to eq(nil)
    expect(result[2]).not_to eq(nil)
    expect(result[3]).not_to eq(nil)
    #expect(result[4]).not_to eq(nil)
  end
end
