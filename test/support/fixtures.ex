defmodule Aprb.Fixtures do
  def commerce_error_event() do
    %{
      "object" => %{
        "id" => "ApplicationError",
        "display" => "ApplicationError"
      },
      "properties" => %{
        "type" => "validation",
        "code" =>  "invalid_address",
        "data" => %{
          "order_id" => "order1"
        }
      }
    }
  end

  def commerce_offer_order(verb \\ "submitted", state_reason \\ nil), do: commerce_order_event(verb, state_reason, "offer")
  def commerce_order_event(verb \\ "submitted", state_reason \\ nil, mode \\ "buy") do
    %{
      "object" => %{
        "id" => "order123",
        "display" => "Order(1)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => verb,
      "properties" => %{
        "mode" => mode,
        "state_reason" => state_reason,
        "seller_id" => "partner1",
        "seller_type" => "gallery",
        "buyer_id" => "user1",
        "buyer_type" => "user",
        "items_total_cents" => 2000000,
        "total_list_price_cents" => 3000,
        "line_items" => [
          %{
            "id" => "li-1",
            "artwork_id" => "artwork1"
          }
        ]
      }
    }
  end

  def commerce_transaction_event(order \\ nil) do
    %{
      "object" => %{
        "id" => "transaction123",
        "display" => "Transaction(123)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => "created",
      "properties" => %{
        "order" =>  order,
        "failure_code" => "insufficient_funds",
        "failure_message" => ":(",
        "transaction_type" => "capture"
      }
    }
  end

  def commerce_offer_event(verb \\ "submitted", in_response_to \\ nil) do
    %{
      "object" => %{
        "id" => "offer321",
        "display" => "Offer(321)"
      },
      "subject" => %{
        "id" => "user1",
        "display" => "User LastName"
      },
      "verb" => verb,
      "properties" => %{
        "order" => %{
          "mode" => "offer",
          "seller_id" => "partner1",
          "seller_type" => "gallery",
          "buyer_id" => "user1",
          "buyer_type" => "user",
          "items_total_cents" => 2000000,
          "total_list_price_cents" => 3000,
          "line_items" => [
            %{
              "id" => "li-1",
              "artwork_id" => "artwork1"
            }
          ]
        },
        "amount_cents" => 3000,
        "from_participant" => "buyer",
        "in_response_to" => in_response_to
      }
    }
  end
end
