require File.expand_path('../../test_helper', __FILE__)

class MaestranoTest < Test::Unit::TestCase
  setup do
    @config = {
      'environment'       => 'production',
      'app.host'          => 'http://mysuperapp.com',

      'api.id'            => 'app-f54ds4f8',
      'api.key'           => 'someapikey',

      'connec.enabled'    => true,

      'sso.enabled'       => false,
      'sso.slo_enabled'   => false,
      'sso.init_path'     => '/mno/sso/init',
      'sso.consume_path'  => '/mno/sso/consume',
      'sso.creation_mode' => 'real',
      'sso.idm'           => 'http://idp.mysuperapp.com',

      'webhook.account.groups_path'       => '/mno/groups/:id',
      'webhook.account.group_users_path'  => '/mno/groups/:group_id/users/:id',
      'webhook.connec.notifications_path' => 'mno/receive',
      'webhook.connec.subscriptions'      => { organizations: true, people: true }
    }

    Maestrano.configure do |config|
      config.environment = @config['environment']
      config.app.host = @config['app.host']

      config.api.id = @config['api.id']
      config.api.key = @config['api.key']

      config.connec.enabled = @config['connec.enabled']

      config.sso.enabled = @config['sso.enabled']
      config.sso.slo_enabled = @config['sso.slo_enabled']
      config.sso.idm = @config['sso.idm']
      config.sso.init_path = @config['sso.init_path']
      config.sso.consume_path = @config['sso.consume_path']
      config.sso.creation_mode = @config['sso.creation_mode']

      config.webhook.account.groups_path = @config['webhook.account.groups_path']
      config.webhook.account.group_users_path = @config['webhook.account.group_users_path']

      config.webhook.connec.notifications_path = @config['webhook.connec.notifications_path']
      config.webhook.connec.subscriptions = @config['webhook.connec.subscriptions']
    end
  end

  context "new style configuration" do
    should "return the specified parameters" do
      @config.keys.each do |key|
        assert_equal @config[key], Maestrano.param(key)
      end
    end

    should "set the sso.creation_mode to 'real' by default" do
      Maestrano.configs = {'default' => Maestrano::Configuration.new }
      Maestrano.configure { |config| config.app.host = "https://someapp.com" }
      assert_equal 'real', Maestrano.param('sso.creation_mode')
    end

    should "build the api_token based on the app_id and api_key" do
      Maestrano.configure { |config| config.app_id = "bla"; config.api_key = "blo" }
      assert_equal "bla:blo", Maestrano.param('api.token')
    end

    should "assign the sso.idm to app.host if not provided" do
      Maestrano.configs = {'default' => Maestrano::Configuration.new }
      Maestrano.configure { |config| config.app.host = "https://someapp.com" }
      assert_equal Maestrano.param('app.host'), Maestrano.param('sso.idm')
    end

    should "force assign the api.lang" do
      Maestrano.configure { |config| config.api.lang = "bla" }
      assert_equal 'ruby', Maestrano.param('api.lang')
    end

    should "force assign the api.lang_version" do
      Maestrano.configure { |config| config.api.lang_version = "123456" }
      assert_equal "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})", Maestrano.param('api.lang_version')
    end

    should "force assign the api.version" do
      Maestrano.configure { |config| config.api.version = "1245" }
      assert_equal Maestrano::VERSION, Maestrano.param('api.version')
    end

    should "force slo_enabled to false if sso is disabled" do
      Maestrano.configure { |config| config.sso.slo_enabled = true; config.sso.enabled = false }
      assert_false Maestrano.param('sso.slo_enabled')
    end

    context "with environment params" do
      should "return the right test parameters" do
        Maestrano.configure { |config| config.environment = 'test' }

        ['api.host', 'api.base', 'sso.idp', 'sso.name_id_format', 'sso.x509_certificate', 'connec.host', 'connec.base_path'].each do |parameter|
          assert_equal Maestrano::Configuration::EVT_CONFIG['test'][parameter], Maestrano.param(parameter)
        end
      end

      should "return the right production parameters" do
        Maestrano.configure { |config| config.environment = 'production' }

        ['api.host', 'api.base', 'sso.idp', 'sso.name_id_format', 'sso.x509_certificate', 'connec.host', 'connec.base_path'].each do |parameter|
          assert_equal Maestrano::Configuration::EVT_CONFIG['production'][parameter], Maestrano.param(parameter)
        end
      end
    end
  end

  context "new style configuration with presets" do
    setup do
      @preset = 'mypreset'

      @config = {
        'environment'       => 'production',
        'app.host'          => 'http://mysuperapp.com',

        'api.id'            => 'app-f54ds4f8',
        'api.key'           => 'someapikey',

        'connec.enabled'    => true,

        'sso.enabled'       => false,
        'sso.slo_enabled'   => false,
        'sso.init_path'     => '/mno/sso/init',
        'sso.consume_path'  => '/mno/sso/consume',
        'sso.creation_mode' => 'real',
        'sso.idm'           => 'http://idp.mysuperapp.com',

        'webhook.account.groups_path'       => '/mno/groups/:id',
        'webhook.account.group_users_path'  => '/mno/groups/:group_id/users/:id',
        'webhook.connec.notifications_path' => 'mno/receive',
        'webhook.connec.subscriptions'      => { organizations: true, people: true }
      }

      @preset_config = {
        'environment'       => 'production',
        'app.host'          => 'http://myotherapp.com',

        'api.id'            => 'app-553941',
        'api.key'           => 'otherapikey',
      }

      Maestrano.configure do |config|
        config.environment = @config['environment']
        config.app.host = @config['app.host']

        config.api.id = @config['api.id']
        config.api.key = @config['api.key']

        config.connec.enabled = @config['connec.enabled']

        config.sso.enabled = @config['sso.enabled']
        config.sso.slo_enabled = @config['sso.slo_enabled']
        config.sso.idm = @config['sso.idm']
        config.sso.init_path = @config['sso.init_path']
        config.sso.consume_path = @config['sso.consume_path']
        config.sso.creation_mode = @config['sso.creation_mode']

        config.webhook.account.groups_path = @config['webhook.account.groups_path']
        config.webhook.account.group_users_path = @config['webhook.account.group_users_path']

        config.webhook.connec.notifications_path = @config['webhook.connec.notifications_path']
        config.webhook.connec.subscriptions = @config['webhook.connec.subscriptions']
      end

      Maestrano[@preset].configure do |config|
        config.environment = @preset_config['environment']
        config.app.host = @preset_config['app.host']

        config.api.id = @preset_config['api.id']
        config.api.key = @preset_config['api.key']
      end
    end

    should "return the specified parameters" do
      @preset_config.keys.each do |key|
        assert_equal @preset_config[key], Maestrano[@preset].param(key)
      end
    end

    should "set the sso.creation_mode to 'real' by default" do
      Maestrano.configs = {@preset => Maestrano::Configuration.new }
      Maestrano[@preset].configure { |config| config.app.host = "https://someapp.com" }
      assert_equal 'real', Maestrano[@preset].param('sso.creation_mode')
    end

    should "build the api_token based on the app_id and api_key" do
      Maestrano[@preset].configure { |config| config.app_id = "bla"; config.api_key = "blo" }
      assert_equal "bla:blo", Maestrano[@preset].param('api.token')
    end

    should "assign the sso.idm to app.host if not provided" do
      Maestrano.configs = {@preset => Maestrano::Configuration.new }
      Maestrano[@preset].configure { |config| config.app.host = "https://someapp.com" }
      assert_equal Maestrano[@preset].param('app.host'), Maestrano[@preset].param('sso.idm')
    end

    should "force assign the api.lang" do
      Maestrano[@preset].configure { |config| config.api.lang = "bla" }
      assert_equal 'ruby', Maestrano[@preset].param('api.lang')
    end

    should "force assign the api.lang_version" do
      Maestrano[@preset].configure { |config| config.api.lang_version = "123456" }
      assert_equal "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})", Maestrano[@preset].param('api.lang_version')
    end

    should "force assign the api.version" do
      Maestrano[@preset].configure { |config| config.api.version = "1245" }
      assert_equal Maestrano::VERSION, Maestrano[@preset].param('api.version')
    end

    should "force slo_enabled to false if sso is disabled" do
      Maestrano[@preset].configure { |config| config.sso.slo_enabled = true; config.sso.enabled = false }
      assert_false Maestrano[@preset].param('sso.slo_enabled')
    end

    should "allow overwritting connec configuration" do
      Maestrano[@preset].configure { |config| config.connec.host = 'http://mydataserver.org'; config.connec.base_path = '/data' }
      assert_equal 'http://mydataserver.org', Maestrano[@preset].param('connec.host')
      assert_equal '/data', Maestrano[@preset].param('connec.base_path')
    end

    context "with environment params" do
      should "return the right test parameters" do
        Maestrano[@preset].configure { |config| config.environment = 'test' }

        ['api.host','api.base','sso.idp', 'sso.name_id_format', 'sso.x509_certificate', 'connec.host','connec.base_path'].each do |parameter|
          assert_equal Maestrano::Configuration::EVT_CONFIG['test'][parameter], Maestrano[@preset].param(parameter)
        end
      end

      should "return the right production parameters" do
        Maestrano[@preset].configure { |config| config.environment = 'production' }

        ['api.host','api.base','sso.idp', 'sso.name_id_format', 'sso.x509_certificate','connec.host','connec.base_path'].each do |parameter|
          assert_equal Maestrano::Configuration::EVT_CONFIG['production'][parameter], Maestrano[@preset].param(parameter)
        end
      end
    end

    context 'with dynamic dev platform config' do
      context 'with no config' do
        should 'raise error' do
          assert_raise { Maestrano.auto_configure }
        end
      end

      context 'with an invalid config' do
        should 'raise error' do
          assert_raise { Maestrano.auto_configure('test/support/yml/wrong_dev_platform.yml') }
        end
      end

      context 'with a valid config' do
        context 'with no response from dev plateform' do
          should 'raise error' do
            assert_raise { Maestrano.auto_configure('test/support/yml/dev_platform.yml') }
          end
        end

        context 'with bad response from dev plateform' do
          setup do
            RestClient::Request.any_instance.stubs(:execute).returns('<html></html>')
          end

          should 'raise error' do
            assert_raise { Maestrano.auto_configure('test/support/yml/dev_platform.yml') }
          end
        end

        context 'with valid response from dev plateform' do
          setup do
            @new_preset = 'this_awesome_one'

            @new_preset_config = {
              environment: 'uat',
              app: {
                host: 'app_host'
              },
              sso: {
                path: 'sso_path'
              },
              api: {
                host: 'api_host'
              },
              webhook: {
                url: 'webhook_url'
              },
              connec: {
                notif: 'connec_notif'
              }
            }

            @marketplaces = {
              marketplaces: [
                @new_preset_config.merge(marketplace: @new_preset),
                {
                  marketplace: @preset,
                  app: {
                    host: 'http://myotherapp.uat.com'
                  }
                }
              ]
            }

            RestClient::Request.any_instance.stubs(:execute).returns(@marketplaces.to_json)
          end

          should 'creates a new preset' do
            assert_nothing_raised { Maestrano.auto_configure('test/support/yml/dev_platform.yml') }
            @new_preset_config.keys.each do |key|
              assert_equal @new_preset_config[key], Maestrano[@new_preset].param(key).marshal_dump
            end
          end

          should 'overload the exisiting preset (only if it is called after)' do
            assert_nothing_raised { Maestrano.auto_configure('test/support/yml/dev_platform.yml') }
            @preset_config.keys.reject { |k| k == :app }.each do |key|
              assert_equal @preset_config[key], Maestrano[@preset].param(key).marshal_dump
            end
            assert_equal @marketplaces[:marketplaces].last[:app], Maestrano[@preset].param('app')
          end
        end

      end
    end
  end

  context "old style configuration" do
    setup do
      @config = {
        environment: 'production',
        api_key: 'someapikey',
        sso_enabled: false,
        app_host: 'http://mysuperapp.com',
        sso_app_init_path: '/mno/sso/init',
        sso_app_consume_path: '/mno/sso/consume',
        user_creation_mode: 'real',
      }

      Maestrano.configure do |config|
        config.environment = @config[:environment]
        config.api_key = @config[:api_key]
        config.sso_enabled = @config[:sso_enabled]
        config.app_host = @config[:app_host]
        config.sso_app_init_path = @config[:sso_app_init_path]
        config.sso_app_consume_path = @config[:sso_app_consume_path]
        config.user_creation_mode = @config[:user_creation_mode]
      end
    end

    should "build the api_token based on the app_id and api_key" do
      Maestrano.configure { |config| config.app_id = "bla"; config.api_key = "blo" }
      assert_equal "bla:blo", Maestrano.param(:api_token)
    end

    should "assign the sso.idm if explicitly set to nil" do
      Maestrano.configure { |config| config.sso.idm = nil }
      assert_equal Maestrano.param('app.host'), Maestrano.param('sso.idm')
    end

    should "force assign the api.lang" do
      Maestrano.configure { |config| config.api.lang = "bla" }
      assert_equal 'ruby', Maestrano.param('api.lang')
    end

    should "force assign the api.lang_version" do
      Maestrano.configure { |config| config.api.lang_version = "123456" }
      assert_equal "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})", Maestrano.param('api.lang_version')
    end

    should "force assign the api.version" do
      Maestrano.configure { |config| config.api.version = "1245" }
      assert_equal Maestrano::VERSION, Maestrano.param('api.version')
    end

    should "return the specified parameters" do
      @config.keys.each do |key|
        assert Maestrano.param(key) == @config[key]
      end
    end

    context "with environment params" do
      should "return the right test parameters" do
        Maestrano.configure { |config| config.environment = 'test' }

        ['api_host','api_base','sso_name_id_format', 'sso_x509_certificate'].each do |parameter|
          key = Maestrano::Configuration.new.legacy_param_to_new(parameter)
          assert_equal Maestrano::Configuration::EVT_CONFIG['test'][key], Maestrano.param(parameter)
        end
      end

      should "return the right production parameters" do
        Maestrano.configure { |config| config.environment = 'production' }

        ['api_host','api_base','sso_name_id_format', 'sso_x509_certificate'].each do |parameter|
          key = Maestrano::Configuration.new.legacy_param_to_new(parameter)
          assert_equal Maestrano::Configuration::EVT_CONFIG['production'][key], Maestrano.param(parameter)
        end
      end
    end
  end

  context "authenticate" do
    should "return true if app_id and api_key match" do
      assert Maestrano.authenticate(Maestrano.param(:app_id),Maestrano.param(:api_key))
    end

    should "return false otherwise" do
      assert !Maestrano.authenticate(Maestrano.param(:app_id) + 'a',Maestrano.param(:api_key))
      assert !Maestrano.authenticate(Maestrano.param(:app_id),Maestrano.param(:api_key) + 'a')
    end
  end

  context "mask_user_uid" do
    should "return the composite uid if creation_mode is virtual" do
      Maestrano.configure { |c| c.user_creation_mode = 'virtual' }
      assert_equal 'usr-1.cld-1', Maestrano.mask_user('usr-1','cld-1')
    end

    should "not double up the composite uid" do
      Maestrano.configure { |c| c.user_creation_mode = 'virtual' }
      assert_equal 'usr-1.cld-1', Maestrano.mask_user('usr-1.cld-1','cld-1')
    end

    should "return the real uid if creation_mode is real" do
      Maestrano.configure { |c| c.user_creation_mode = 'real' }
      assert_equal 'usr-1', Maestrano.mask_user('usr-1','cld-1')
    end
  end

  context "unmask_user_uid" do
    should "return the right uid if composite" do
      assert_equal 'usr-1', Maestrano.unmask_user('usr-1.cld-1')
    end

    should "return the right uid if non composite" do
      assert_equal 'usr-1', Maestrano.unmask_user('usr-1')
    end
  end

  context "to_metadata" do
    should "should return the right hash" do
      expected = {
        'environment'        => @config['environment'],
        'app' => {
          'host'             => @config['app.host']
        },
        'api' => {
          'id'               => @config['api.id'],
          'version'          => Maestrano::VERSION,
          'verify_ssl_certs' => false,
          'lang'             => 'ruby',
          'lang_version'     => "#{RUBY_VERSION} p#{RUBY_PATCHLEVEL} (#{RUBY_RELEASE_DATE})",
          'host'             => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['api.host'],
          'base'             => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['api.base'],

        },
        'sso' => {
          'enabled'          => @config['sso.enabled'],
          'slo_enabled'      => @config['sso.slo_enabled'],
          'init_path'        => @config['sso.init_path'],
          'consume_path'     => @config['sso.consume_path'],
          'creation_mode'    => @config['sso.creation_mode'],
          'idm'              => @config['sso.idm'],
          'idp'              => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['sso.idp'],
          'name_id_format'   => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['sso.name_id_format'],
          'x509_fingerprint' => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['sso.x509_fingerprint'],
          'x509_certificate' => Maestrano::Configuration::EVT_CONFIG[@config['environment']]['sso.x509_certificate'],
        },
        'webhook' => {
          'account' => {
            'groups_path' => @config['webhook.account.groups_path'],
            'group_users_path' => @config['webhook.account.group_users_path'],
          },
          'connec' => {
            'notifications_path' => 'mno/receive',
            'subscriptions'      => { organizations: true, people: true }
          }
        }
      }

      assert_equal expected, Maestrano.to_metadata
    end
  end

end
