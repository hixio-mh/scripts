
module Y2status
  # Jenkins server
  class JenkinsServer
    include Downloader
    include Reporter

    attr_reader :base_url, :label, :error

    def initialize(label, base_url)
      @label = label
      @base_url = base_url
    end

    def error?
      error && !error.empty?
    end

    def success?
      !jobs.any?(&:failure?)
    end

    def issues
      jobs.count(&:failure?)
    end

    def jobs
      @jobs ||= download
    end

  private

    def status_url
      "#{base_url}/api/json?pretty=true"
    end

    def download
      body = download_url(status_url)

      if body.empty?
        @error = "Cannot download #{status_url}"
        print_error(error)
        return []
      end

      data = JSON.parse(body)

      # a single job
      if (data.is_a?(Hash))
        return [JenkinsJob.new(self, data["name"], data["color"])]
      end

      # list of jobs
      data["jobs"].map do |s|
        JenkinsJob.new(self, s["name"], s["color"])
      end
    end
  end
end
