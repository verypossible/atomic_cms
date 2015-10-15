shared_examples 'media upload' do
  it { should have_attached_file :file }
end
