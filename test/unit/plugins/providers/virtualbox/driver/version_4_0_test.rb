require_relative "../base"

describe VagrantPlugins::ProviderVirtualBox::Driver::Version_4_0 do
  my_uuid = '1234-abcd-5678-efgh'

  let(:uuid) { my_uuid }
  subject { described_class.new(uuid) }

  it_behaves_like "a version 4.x virtualbox driver", uuid: my_uuid
end
