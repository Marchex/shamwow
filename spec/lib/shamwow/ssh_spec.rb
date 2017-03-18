require 'rspec'
require 'shamwow/ssh'

describe 'Ssh' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should parse task strings and return symbols' do
    #
    # Arrange
    ssh = Shamwow::Ssh.new
    allow(Time).to receive(:now).and_return(@time_now)
    #
    # # Act
    result = ssh.parse_tasks(['Chef_version','Etc_issue'])
    #
    # Assert
    expect(result).to eq([:Chef_version, :Os_version])
  end

end
