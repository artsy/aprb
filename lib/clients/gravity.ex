defmodule Gravity do
  use HTTPoison.Base

  def process_url(url) do
    Application.get_env(:aprb, :gravity_api_url) <> url
  end

  def process_request_headers(headers), do: Enum.into(%{"X-XAPP-TOKEN" => Application.get_env(:aprb, :gravity_api_token)}, [])
  def process_response_body(body), do: Poison.decode!(body)
end
