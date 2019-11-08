module Resque
  module Plugins
    module Datadog
      mattr_accessor :statsd
      mattr_accessor :service_name

      def after_enqueue_datadog(*args)
        return unless statsd
        @enqueued_at = Time.now
        statsd.event('Job Enqueued', enqueued_at.to_s, tags: job_tags(args))
      end

      def around_perform_datadog(*args)
        return yield unless statsd

        exc = nil
        result = nil
        start_time = Time.now
        statsd.batch do |s|
          s.event('Job Started', start_time)
          s.timing(
            'resque.jobs.enqueued_duration',
            (start_time - @enqueued_at) * 1000,
            tags: job_tags(args)
          )
        end

        begin
          result = yield
        rescue => e
          exc = e
        end
        end_time = Time.now

        tags = job_tags(args)

        statsd.batch do |s|
          s.increment('resque.jobs.total', tags: tags)
          s.increment("resque.jobs.#{exc.nil? ? 'success' : 'failure'}", tags: tags)
          s.timing('resque.jobs.duration', (end_time - start_time) * 1000, tags: tags)
        end

        raise exc if exc
        result
      end

      private

      def job_tags(args)
        tags = [
          "job_class:#{self.name.to_s}",
          "queue:#{@queue.to_s}"
        ]

        tags << "service:#{service_name}" if service_name.present?
        tags = tags.concat(dd_tags(*args)).uniq if respond_to?(:dd_tags)

        tags
      end
    end
  end
end
