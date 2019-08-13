
defmodule Aprb.Views.CommerceTransactionSlackView do
  import Aprb.ViewHelper
  alias Aprb.Views.CommerceHelper
  alias Stripe.PaymentIntent

  def render(event, _routing_key) do
    order = event["properties"]["order"]
    seller = CommerceHelper.fetch_participant_info(order["seller_id"], order["seller_type"])
    buyer = CommerceHelper.fetch_participant_info(order["buyer_id"], order["buyer_type"])

    fields =
      basic_fields(event, buyer)
      |> append_seller_admin(seller)
      |> append_stripe_fields(event["properties"]["external_id"], event["properties"]["external_type"])
      |> append_fulfillment_info(order)

    %{
      text:
        ":alert: <#{stripe_search_link(event["properties"]["order"]["id"])}|#{
          event["properties"]["failure_code"]
        }>",
      attachments: [
        %{
          color: "#6E1FFF",
          author_name: event["properties"]["order"]["code"],
          author_link: exchange_admin_link(event["properties"]["order"]["id"]),
          title: seller["name"],
          title_link: exchange_partner_orders_link(seller["_id"]),
          fields: fields
        }
      ],
      unfurl_links: true
    }
  end

  defp basic_fields(event, buyer) do
    [
      %{
        title: "Purchase Method",
        value: event["properties"]["order"]["mode"],
        short: true
      },
      %{
        title: "Buyer",
        value: cleanup_name(buyer["name"]),
        short: true
      },
      %{
        title: "Failure Message",
        value: event["properties"]["failure_message"],
        short: true
      },
      %{
        title: "Transaction Type",
        value: event["properties"]["transaction_type"],
        short: true
      },
      %{
        title: "Total Amount",
        value: format_price(event["properties"]["order"]["items_total_cents"] / 100),
        short: true
      }
    ]
  end

  defp append_seller_admin(fields, %{"admin" => %{"name" => name}}),
    do: fields ++ [%{title: "Admin", value: name, short: true}]

  defp append_seller_admin(fields, _), do: fields

  defp append_stripe_fields(fields, external_id, "payment_intent") do
    with {:ok, pi} <- PaymentIntent.retrieve(external_id, %{expand: ["payment_method"]}) do
      fields ++ [
        %{
          title: "Card Country",
          value: pi.last_payment_error.payment_method.card.country,
          short: true
        },
        %{
          title: "CVC Check",
          value: pi.last_payment_error.payment_method.card.checks.cvc_check,
          short: true
        },
        %{
          title: "ZIP Check",
          value: pi.last_payment_error.payment_method.card.checks.address_postal_code_check,
          short: true
        }
      ]
    else
      _ -> fields
    end
  end

  defp append_stripe_fields(fields, _, _), do: fields

  defp append_fulfillment_info(fields, order) do
    case order["fulfillment_type"] do
      "ship" ->
        fields ++
          [
            %{title: "Fulfillment Type", value: order["fulfillment_type"], short: true},
            %{title: "Shipping Country", value: order["shipping_country"], short: true},
            %{title: "Shipping Name", value: cleanup_name(order["shipping_name"]), short: true}
          ]

      "pickup" ->
        fields ++ [%{title: "Fulfillment Type", value: order["fulfillment_type"], short: true}]

      _ ->
        fields
    end
  end
end
