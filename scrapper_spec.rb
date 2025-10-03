require 'rspec'
require './scrapper'

describe 'McDonalds Outlet Scrapper' do
  describe '#compose_full_address' do
    it 'joins available address fields with commas' do
      loc = {
        'addressLine1' => '123 Main St',
        'addressLine3' => 'Suite 5',
        'subDivision' => 'NY',
        'postcode' => '10001',
        'addressLine4' => nil
      }
      expect(compose_full_address(loc)).to eq('123 Main St, Suite 5, NY, 10001')
    end
  end

  describe '#retrieve_outlets' do
    it 'returns an array of outlet features from the API' do
      response = double('response', success?: true, code: 200)
      allow(response).to receive(:[]).with('features').and_return([
        { 'properties' => {}, 'geometry' => { 'coordinates' => [1, 2] } }
      ])
      allow(HTTParty).to receive(:get).and_return(response)
      expect(retrieve_outlets).to be_an(Array)
    end

    it 'raises error if API response is unsuccessful' do
      allow(HTTParty).to receive(:get).and_return(double(success?: false, code: 500))
      expect { retrieve_outlets }.to raise_error(/Failed to fetch outlet data/)
    end
  end

  describe '#outlet_info' do
    it 'returns a hash of outlet information' do
      allow(self).to receive(:retrieve_outlets).and_return([
        {
          'properties' => {
            'addressLine1' => 'McD NY',
            'telephone' => '12345',
            'addressLine3' => 'Floor 1',
            'subDivision' => 'NY',
            'postcode' => '10001'
          },
          'geometry' => { 'coordinates' => [1.1, 2.2] }
        }
      ])
      data = outlet_info
      expect(data).to be_a(Hash)
      expect(data['Outlet_1'][:name]).to eq('McD NY')
      expect(data['Outlet_1'][:longitude]).to eq(1.1)
      expect(data['Outlet_1'][:latitude]).to eq(2.2)
      expect(data['Outlet_1'][:contact_number]).to eq('12345')
      expect(data['Outlet_1'][:full_address]).to include('McD NY')
    end
  end
end
