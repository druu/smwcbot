defmodule SMWCBot do

  use TMI.Handler

    @impl true
    def handle_message("!" <> command, _sender, chat, sender) do
      case command do
        "hack waiting " <> rest -> SMWCBot.search_hack(rest, "waiting", chat, sender)
        "hack " <> rest -> SMWCBot.search_hack(rest, "", chat, sender)
      end
    end

    def handle_message(message, sender, chat, sender) do
      Logger.debug("Message in #{chat} from #{sender}: #{message}")
    end

    def search_hack(hack, waiting, chat, sender) do
      base_uri =
        case waiting do
          "waiting" -> "https://www.smwcentral.net/?p=section&s=smwhacks&u=1&"
          _ -> "https://www.smwcentral.net/?p=section&s=smwhacks&"
      end

      filter = URI.encode_query(%{"f[name]" => hack})

      search_uri = "#{base_uri}#{filter}"

      Logger.debug( "Uri = #{search_uri}")

      result_page = HTTPoison.get! "#{base_uri}#{filter}"
      {:ok, document} = Floki.parse_document(result_page.body)



      Floki.find(document, "div#list_content table tr")
      |> SMWCBot.parse_result_table(search_uri)
      |> SMWCBot.send_response(chat, sender)

    end


    def parse_result_table(table, search_uri) do
      case length(table) do
        1 -> Logger.debug('Nothing') #{:name -> "No Results Found", :href }
        2 -> Enum.at(table, 1)
          Floki.find(table, "td.cell1 a")

        _ -> search_uri
      end
    end

    def send_response(result, chat, sender) do
      result
      #message = "@#{sender}: #{result}"
      # Logger.debug(message)
      # TMI.message(chat, message)
    end
end
