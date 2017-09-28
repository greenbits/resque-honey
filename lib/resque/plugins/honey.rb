module Resque
  module Plugins
    module Honey
      mattr_accessor :write_key
      mattr_accessor :dataset_name

      def around_perform_honey(*args)
        return yield unless write_key && dataset_name

        client = Libhoney::Client.new(writekey: write_key,
                                      dataset:  dataset_name)
        exc = nil
        result = nil
        start_time = Time.now
        begin
          result = yield
        rescue => e
          exc = e
        end
        end_time = Time.now

        data = {
          duration_ms: (end_time - start_time) * 1000,
          job_type:    self.name.to_s,
          success:     exc.nil?,
          worker_host: `hostname`.chomp
        }
        client.send_now(data)

        client.close(true)

        raise exc if exc
        result
      end

      def hostname
        @_hostname ||= `hostname`.chomp
      end
    end
  end
end
