shared_context "virtualbox" do
  let(:subprocess) { double("Vagrant::Util::Subprocess") }
  before { stub_const("Vagrant::Util::Subprocess", subprocess) }

  def subprocess_result(options={})
    defaults = {exit_code: 0, stdout: "", stderr: ""}
    double("subprocess_result", defaults.merge(options))
  end

  let(:vbox_version) { "4.3.4" }

  before do
    # drivers will blow up on instantiation if they cannot determine the
    # virtualbox version, so wire this stub in automatically
    subprocess.stub(:execute).
      with("VBoxManage", "--version", an_instance_of(Hash)).
      and_return(subprocess_result(stdout: vbox_version))
  end
end
