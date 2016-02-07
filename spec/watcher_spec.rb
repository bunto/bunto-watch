require 'spec_helper'

describe(Bunto::Watcher) do
  let(:base_opts) do
    {
      'source' => source_dir,
      'destination' => dest_dir
    }
  end

  let(:options) { base_opts }
  let(:site)    { instance_double(Bunto::Site) }
  let(:default_ignored) { [/_config\.yml/, /_site/, /\.bunto\-metadata/] }
  subject { described_class }
  before(:each) do
    FileUtils.mkdir(options['destination']) if options['destination']
  end

  after(:each) do
    FileUtils.rm_rf(options['destination']) if options['destination']
  end

  describe "#watch" do
    let(:listener) { instance_double(Listen::Listener) }

    let(:opts) { { ignore: default_ignored, force_polling: options['force_polling'] } }

    before do
      allow(Listen).to receive(:to).with(options['source'], opts).and_return(listener)

      allow(listener).to receive(:start)

      allow(Bunto::Site).to receive(:new).with(options).and_return(site)
      allow(Bunto.logger).to receive(:info)

      allow(subject).to receive(:sleep_forever)

      subject.watch(options)
    end

    it 'starts the listener' do
      expect(listener).to have_received(:start)
    end

    it 'sleeps' do
      expect(subject).to have_received(:sleep_forever)
    end

    it "ignores the config and site by default" do
      expect(Listen).to have_received(:to).with(anything, hash_including(ignore: default_ignored))
    end

    it "defaults to no force_polling" do
      expect(Listen).to have_received(:to).with(anything, hash_including(force_polling: nil))
    end

    context "with force_polling turned on" do
      let(:options)  { base_opts.merge('force_polling' => true) }

      it "respects the custom value of force_polling" do
        expect(Listen).to have_received(:to).with(anything, hash_including(force_polling: true))
      end
    end
  end

  context "#listen_ignore_paths" do
    let(:ignored) { subject.listen_ignore_paths(options) }
    let(:metadata_path) { Bunto.sanitized_path(options['source'], '.bunto-metadata') }

    before(:each) { FileUtils.touch(metadata_path) }
    after(:each)  { FileUtils.rm(metadata_path) }

    it "ignores config.yml, .bunto-metadata, and _site by default" do
      expect(ignored).to eql(default_ignored)
    end

    context "with something excluded" do
      let(:excluded) { ['README.md', 'LICENSE'] }
      let(:excluded_absolute) { excluded.map { |p| Bunto.sanitized_path(options['source'], p) }}
      let(:options) { base_opts.merge('exclude' => excluded) }
      before(:each) { FileUtils.touch(excluded_absolute) }
      after(:each)  { FileUtils.rm(excluded_absolute) }

      it "ignores the excluded files" do
        expect(ignored).to include(/README\.md/)
        expect(ignored).to include(/LICENSE/)
      end
    end

    context "with a custom destination" do
      let(:default_ignored) { [/_config\.yml/, /_dest/, /\.bunto\-metadata/] }

      context "when source is absolute" do
        context "when destination is absolute" do
          let(:options) { base_opts.merge('destination' => source_dir('_dest')) }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
          end
        end

        context "when destination is relative" do
          let(:options) { base_opts.merge('destination' => 'spec/test-site/_dest') }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
          end
        end
      end

      context "when source is relative" do
        let(:base_opts) { {'source' => Pathname.new(source_dir).relative_path_from(Pathname.new('.').expand_path).to_s } }

        context "when destination is absolute" do
          let(:options) { base_opts.merge('destination' => source_dir('_dest')) }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
          end
        end

        context "when destination is relative" do
          let(:options) { base_opts.merge('destination' => 'spec/test-site/_dest') }
          it "ignores the destination" do
            expect(ignored).to eql(default_ignored)
          end
        end
      end
    end

  end

end
