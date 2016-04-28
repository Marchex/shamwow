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
    db = double('Shamwow::Db')
    h = Shamwow::Http.new(db)
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
    db = double('Shamwow::Db')
    h = Shamwow::Http.new(db)
    #
    # act
    result = h.parse_layer1("a01-tor-a.som1.marchex.com: mgt up MGT
a01-tor-a.som1.marchex.com: port10 up r630a0101_s2_data
a01-tor-a.som1.marchex.com: port11 up r630a0102_s1_stor
as1-a01-admin.som1.marchex.com: gi0/10 up r630a0101_ipmi
as1-a01-admin.som1.marchex.com: gi0/10 up
phl02as04a.phl1.marchex.com: gi0/25 down RSPAN destination interface : Link to phl02asRSPAN
sad01cr01-01.sad.marchex.com: gi10/3 up *UP-LINK Spectrum:sea02cs18a:Gi0/13:CircuitID-SID-4216
sad01cs02.sad.marchex.com: gi3/25 up \"to br2.sea1 ge-1/3/9 via pp15 for zayo e-wan vlan 937 SOM1 to SAD\"
sea02cs18a.sea.marchex.com: gi0/13 up *UP-LINK SPECTRUM:sad01cr01-01:Gi10 /3:Cir-ID-SID-4216
sea02cs18a.sea.marchex.com: v690 up sea02.infr_v690_10.104.254.0-24_network-management
sea02cs18b.sea.marchex.com: gi0/13 up *UP-LINK INTEGRA:sad01cr01-02:Gi10 /2:Cir-ID:ELKFED758894INTG
sea02cs18b.sea.marchex.com: v690 up sea02.infr_v690_10.104.254.0-24_network-management
")
    #
    # asset
    expect(result.count).to eq(12)
    expect(result[0]).not_to eq(nil)
    expect(result[1]).not_to eq(nil)
    expect(result[2]).not_to eq(nil)
    expect(result[3]).not_to eq(nil)
    expect(result[4]).not_to eq(nil)
    expect(result[5]).not_to eq(nil)
    expect(result[6]).not_to eq(nil)
    expect(result[7]).not_to eq(nil)
    expect(result[8]).not_to eq(nil)
    expect(result[9]).not_to eq(nil)
    expect(result[10]).not_to eq(nil)
    expect(result[11]).not_to eq(nil)
  end

  it 'should parse netools layer2 data' do
    #
    # arrange
    db = double('Shamwow::Db')
    h = Shamwow::Http.new(db)
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
