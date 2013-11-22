require_relative "../base"

describe "VagrantPlugins::ProviderVirtualBox::Driver::Base" do
  include_context "virtualbox"

  let(:described_class) {
    # trigger autoload of Meta, which will load Base
    VagrantPlugins::ProviderVirtualBox::Driver.const_get('Meta')
    # then we can reference Base happily
    VagrantPlugins::ProviderVirtualBox::Driver::Base
  }
  subject { described_class.new }

  describe "read_guest_property" do
    it "reads the guest property of the machine referenced by the UUID" do
      uuid = "1234-abcd-5678-efgh"
      key  = "/Foo/Bar"

      subprocess.should_receive(:execute).
        with("VBoxManage", "guestproperty", "get", uuid, key, an_instance_of(Hash)).
        and_return(subprocess_result(stdout: "Value: Baz\n"))

      subject.read_guest_property(uuid, key).should == "Baz"
    end

    it "raises a virtualBoxGuestPropertyNotFound exception when the value is not set" do
      uuid = "1234-abcd-5678-efgh"
      key  = "/Not/There"

      subprocess.should_receive(:execute).
        with("VBoxManage", "guestproperty", "get", uuid, key, an_instance_of(Hash)).
        and_return(subprocess_result(stdout: "No value set!"))

      expect { subject.read_guest_property(uuid, key) }.
        to raise_error Vagrant::Errors::VirtualBoxGuestPropertyNotFound
    end
  end
end

