require_relative "test_helper"

class StreamShutdownTest < Minitest::Test
  def setup
    # Reset internal flags between tests to avoid leakage.
    Jetski::Stream.reset_shutdown!
    Jetski::Stream.instance_variable_set(:@shutdown_requested, false)
  end

  def test_signal_and_shutdown_flags
    refute Jetski::Stream.shutdown_signaled?
    Jetski::Stream.signal_shutdown
    assert Jetski::Stream.shutdown_signaled?

    refute Jetski::Stream.shutdown?
    Jetski::Stream.shutdown!
    assert Jetski::Stream.shutdown?

    Jetski::Stream.reset_shutdown!
    refute Jetski::Stream.shutdown?
  end

  def test_wait_for_shutdown_times_out_and_then_succeeds
    refute Jetski::Stream.wait_for_shutdown(0.001)

    Jetski::Stream.shutdown!
    assert Jetski::Stream.wait_for_shutdown(0.001)
  end
end
