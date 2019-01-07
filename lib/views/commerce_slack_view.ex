# https://github.com/artsy/exchange/blob/master/app/events/order_event.rb#L1

defmodule Aprb.Views.CommerceSlackView do
  import Aprb.ViewHelper

  def render(event, routing_key) do
    case routing_key do
      "transaction.created" -> failed_transaction_event(event)
      "offer.submitted" -> offer_submitted(event)
      _ -> order_event(event)
    end
  end

  defp failed_transaction_event(event) do
    %{
      text: ":alert: Failed Transaction",
      attachments: [%{
        fields: [
          %{
            title: "Failure Code",
            value: event["properties"]["failure_code"],
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
        ] ,
        "actions": [
          %{
            "type": "button",
            "text": "Admin Link",
            "url": exchange_admin_link(event["properties"]["order"]["id"])
          }
        ]
      }],
      unfurl_links: true
    }
  end

  defp offer_submitted(event) do
    case Map.get(event["properties"], "in_response_to", nil) do
      nil -> nil
      _ -> counter_offer_view(event)
    end
  end

  defp counter_offer_view(event) do
    seller = fetch_info(event["properties"]["order"]["seller_id"], event["properties"]["order"]["seller_type"])
    buyer = fetch_info(event["properties"]["order"]["buyer_id"], event["properties"]["order"]["buyer_type"])
    %{
      text: ":parrotsunnies: Counteroffer submitted",
      attachments: [
        %{
          fields: [
            %{
              title: "Offer Amount",
              value: format_price(event["properties"]["amount_cents"] / 100),
              short: true
            },
            %{
              title: "By",
              value: event["properties"]["from_participant"],
              short: true
            },
            %{
              title: "Counter to",
              value: format_price(event["properties"]["in_response_to"]["amount_cents"] / 100),
              short: true
            },
            %{
              title: "List Price",
              value: format_price(event["properties"]["order"]["total_list_price_cents"] / 100),
              short: true
            },
            %{
              title: "Seller",
              value: seller["name"],
              short: true
            },
            %{
              title: "Buyer",
              value: cleanup_name(buyer["name"]),
              short: true
            }
          ],
          "actions": [
            %{
              "type": "button",
              "text": "Admin Link",
              "url": exchange_admin_link(event["properties"]["order"]["id"])
            }
          ]
        }
      ]
    }
  end

  defp order_event(event) do
    event
      |> get_title
      |> build_message(event)
  end

  defp get_title(event) do
    case {event["verb"], event["properties"]["mode"]} do
      {"submitted", "buy"} -> "🤞 Submitted"
      {"submitted", "offer"} -> "🤞 Offer Submitted"
      {"approved", _} -> ":yes: Approved"
      {"canceled", _} ->
        case event["properties"]["state_reason"] do
          "seller_lapsed" -> ":hourglass: Seller Lapsed"
          "seller_rejected" -> ":soshocked: Rejected"
        end
      {"refunded", _} -> ":sad-parrot: Refunded"
      {"fulfilled", _} -> " :shipitmoveit: Fulfilled"
      {"pending_approval", _} -> ":hourglass: Waiting Approval"
      {"pending_fulfillment", _} -> ":hourglass: Waiting Shipping"
      _ -> nil
    end
  end

  defp build_message(nil, event), do: nil
  defp build_message(title, event) do
    seller = fetch_info(event["properties"]["seller_id"], event["properties"]["seller_type"])
    buyer = fetch_info(event["properties"]["buyer_id"], event["properties"]["buyer_type"])
    %{
      text: "#{title} #{artworks_links_from_line_items(event["properties"]["line_items"])}",
      attachments: order_attachments(event["properties"], event["object"]["id"], seller, buyer),
      unfurl_links: true
    }
  end

  defp order_attachments(order_properties, order_id, seller, buyer) do
    fields = order_attachment_fields(order_properties, seller, buyer)
      |> append_admin(seller["admin"])
      |> append_offer_fields(order_properties["mode"], order_properties)
    [%{
      fields: fields,
      "actions": [
        %{
          "type": "button",
          "text": "Admin Link",
          "url": exchange_admin_link(order_id)
        }
      ]
    }]
  end

  defp append_admin(attachments, nil), do: attachments
  defp append_admin(attachments, admin), do: attachments ++ [%{ title: "Admin", value: admin["name"], short: true}]

  defp append_offer_fields(attachments, "offer", properties), do: attachments ++ [%{title: "List Price", value: format_price(properties["total_list_price_cents"] / 100), short: true}]
  defp append_offer_fields(attachments, _, _), do: attachments

  defp order_attachment_fields(order_properties, seller, buyer) do
    [
      %{
        title: "Code",
        value: order_properties["code"],
        short: true
      },
      %{
        title: "Mode",
        value: order_properties["mode"],
        short: true
      },
      %{
        title: "Buyer",
        value: cleanup_name(buyer["name"]),
        short: true
      },
      %{
        title: "Seller",
        value: seller["name"],
        short: true
      },
      %{
        title: "Total Amount",
        value: format_price(order_properties["items_total_cents"] / 100),
        short: true
      }
    ]
  end

  defp fetch_info(id, "user"), do: Gravity.get!("/users/#{id}").body
  defp fetch_info(id, _), do: Gravity.get!("/v1/partner/#{id}").body

  defp artworks_links_from_line_items(line_items) do
    line_items
      |> Enum.map(fn(li) -> artwork_link(li["artwork_id"]) end)
      |> Enum.map(fn(artwork_link) -> "<#{artwork_link}| >" end)
  end
end
