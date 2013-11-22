shared_examples "a version 4.x virtualbox driver" do |options|
  let(:uuid) do
    raise ArgumentError, "Must pass :uuid to the shared example." if !(options && options[:uuid])
    options[:uuid]
  end

  describe "read_guest_ip" do
    it "reads the guest property for the provided adapter number using the uuid" do
      subject.should_receive(:read_guest_property).
        with(uuid, "/VirtualBox/GuestInfo/Net/1/V4/IP")
      subject.read_guest_ip(1)
    end
  end
end
