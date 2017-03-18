require 'rspec'
require 'shamwow'


describe 'Shamwow' do
  before(:context) do
    #
    # Arrange
    @time_now = Time.now
  end

  it 'should return an array of tasks' do
    #
    # Arrange
    #
    r = ["-P", "kittens123", "--ssh", "--sshtasks", 'Chef_version,Etc_issue']
    allow(ARGV).to receive().and_return(r)
    #
    # # Act
    Shamwow
    #
    # Assert
    expect(result).to eq([:Chef_version, :Os_version])
  end

end