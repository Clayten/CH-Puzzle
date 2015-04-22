module CH::Puzzles
  module Resettable
    class ResetNotAllowed < RuntimeError ; end

    private

    def reset_name ; self.class.name.split('::').last ; end
    def reset_message ; "The #{reset_name} has been reset" ; end
    def reset_fail_message ; "The #{reset_name} cannot be reset" ; end

    def initializing?
      caller.any? {|c| c =~ /`initialize'/ }
    end

    def count_reset
      @reset_count ||= 0
      @reset_count += 1
    end

    def reset_check
      raise ResetNotAllowed, reset_fail_message unless (initializing? || resettable)
    end

    def reset
      reset_check
      count_reset        unless initializing?
      puts reset_message unless initializing?
    end

    public

    def resettable ; (@resettable != nil) ? @resettable : true ; end
  end
end
