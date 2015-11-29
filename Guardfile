# More info at https://github.com/guard/guard#readme

# guard 'rubocop' do
#   watch(/.+\/.+\.rb$/)
#   watch(/providers\/.+\.rb$/)
#   watch(/recipes\/.+\.rb$/)
#   watch(/resources\/.+\.rb$/)
#   watch('metadata.rb')
# end

guard :rspec, cmd: 'rspec', all_on_start: true, notification: true do
  watch(/^Dockerfile$/)
  watch(/^spec\/(.+)_spec\.rb$/)
  watch(/^spec\/helpers\/(.+)\.rb$/)
  watch(/^spec\/(.+)\/_spec\.rb$/)
  watch('spec/spec_helper.rb') { 'spec' }
end
