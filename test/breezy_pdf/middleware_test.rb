require "test_helper"

class BreezyPDF::MiddlewareTest < Minitest::Test
  def test_invokes_interceptor
    mock_intercept = MiniTest::Mock.new
    mock_intercept.expect(:intercept!, true)

    mock_interceptor = MiniTest::Mock.new
    mock_interceptor.expect(:new, mock_intercept, [1,2])


    BreezyPDF.stub_const(:Interceptor, mock_interceptor) do
      BreezyPDF::Middleware.new(1).call(2)
    end

    assert mock_interceptor.verify
    assert mock_intercept.verify
  end
end
