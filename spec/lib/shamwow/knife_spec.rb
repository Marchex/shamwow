require 'rspec'
require 'shamwow/knife'

describe 'Knife' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should parse task strings and return symbols' do
    #
    # Arrange
    dns = Shamwow::Knife.new
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = dns.parse_tasks(['Chef_version','Etc_issue'])
    #
    # Assert
    expect(result).to eq([:Chef_version, :Etc_issue])
  end

end